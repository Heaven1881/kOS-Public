// Script to automatically launch SSTO spaceplanes to orbit. Tested with the Ascension.
// File: ssto.ks  From: https://github.com/lordcirth/kOS-Public
// Made for spaceplanes which use purely RAPIER engines to get to orbit.
// The following flight path parameters, customized to craft,
// 	should be set in the script that calls this.  Or pasted in here.
//	Ascension numbers given as examples
// takeoffSpeed   = 110 - Takeoff speed in m/s
// climbDeg  = 25  - Angle for initial climb in degrees
// sprintAoA = 6   - AoA that maintains level flight at beginning of sprint. ie 6 deg.
// boostDeg  = 30  - Angle for rocket ascent
// Accel     = 12  - Temporary hack, m/s^2 at full throttle at Ap.

PARAMETER takeoffSpeed.
PARAMETER climbDeg.
PARAMETER climbToHeight.
PARAMETER speedingDeg.
PARAMETER speedingToHeight.
PARAMETER boostDeg.
PARAMETER boostToAp.

RunOncePath ("0:/lib/lib_safe"). //Declare SAFE_QUIT()
RunOncePath ("0:/lib/lib_text"). //Declare PrintHUD()
RunOncePath ("0:/lib/lib_rapier"). //Import RAPIER engine handling functions
RunOncePath ("0:/lib/lib_physics").
RunOncePath ("0:/lib/lib_node").

//Check if we're landed, otherwise skip ahead
IF (Ship:Status = "LANDED") OR (Ship:Status = "PRELAUNCH") {

    //Make sure the engine is in air breathing mode
    SetRapiersMode("AirBreathing").

    //Disable gimbal - it makes the plane twitchy
    SetRapiersGimbal("Off").

    LOCK Throttle TO 1.
    
    //If we didn't reboot on runway
    IF Ship:GroundSpeed < 3 { 
        BRAKES ON.
        PrintHUD("Taking off in 5 seconds ...").
        WAIT 5.  //Spin up the engine
    }.//Otherwise skip spinup

    SetRapiersOn().
}. //End LANDED IF

LOCK Steering TO Heading(90, 0).

// == Taking off == //
PrintHUD("Taking off ...").
LOCK Throttle TO 1.
BRAKES OFF. 

WAIT UNTIL Ship:GroundSpeed > takeoffSpeed.
LOCK Steering TO Heading(90, 10).

WAIT UNTIL Alt:Radar > 100.  //100 meters off the ground

//Retract landing gear
GEAR OFF.

LOCK Steering TO Heading(90, climbDeg).

PrintHUD("Taking off complete, climbing at " + climbDeg + " Deg").

WAIT UNTIL ALTITUDE > climbToHeight.
PrintHUD("Leveling off to build up speed.").
LOCK Steering TO HEADING(90,(climbDeg + speedingDeg) / 2).
WAIT 5.  //Turn in two equal parts, gentler
LOCK Steering TO HEADING(90, speedingDeg).  //Build up speed

WAIT UNTIL ALTITUDE > speedingToHeight.  //Approx airbreathing ceiling
PrintHUD("Sprint complete.  Beginning boost phase.").
LOCK Steering TO HEADING(90,(speedingDeg + boostDeg ) / 2).  //Gentle turn in two parts
WAIT 10.  //Use as much jet Isp as possible
LOCK Steering TO HEADING(90, boostDeg).


// == Boost == //
PrintHUD("Boosting ...").
SetRapiersMode("ClosedCycle").
SetRapiersGimbal("On").  //Control surfaces will be useless soon.

WAIT UNTIL ALT:Apoapsis > 80000.
LOCK THROTTLE TO 0. //Coast to Apoapsis
LOCK STEERING TO PROGRADE.  //Minimize drag
PrintHUD("Boost phase complete.  Coasting.").

WAIT UNTIL Altitude > 70000. //Out of atmosphere

//====================
// In Space
//====================

circle().

exnode().

PrintHUD("Circularization complete. Releasing controls.").

SAFE_QUIT(). //Safely release controls
