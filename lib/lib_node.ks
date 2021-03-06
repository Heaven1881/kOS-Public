// A library of functions to execute node related tasks
// Compatible with KSP 1.0 and kOS 0.17
// Version: 1.6

//@lazyglobal off.

// ------------------------------------------------------------------------------------------------

// Execute the next node in sequence
// The function exnode is taken from http://ksp-kos.github.io/KOS_DOC/tutorials/exenode.html
// With minor revisions

function exnode 
{
	// Get a copy of the next node in line
	set nd TO nextnode.

	//print out node's basic parameters - ETA and deltaV
    print "Node in: " + round(nd:eta) + ", DeltaV: " + round(nd:deltav:mag).

    //calculate ship's max acceleration
    set max_acc to ship:maxthrust/ship:mass.
    set max_acc TO ship:maxthrust/ship:mass.

    // Now we just need to divide deltav:mag by our ship's max acceleration
    // to get the estimated time of the burn.
    //
    // Please note, this is not exactly correct.  The real calculation
    // needs to take into account the fact that the mass will decrease
    // as you lose fuel during the burn.  In fact throwing the fuel out
    // the back of the engine very fast is the entire reason you're able
    // to thrust at all in space.  The proper calculation for this
    // can be found easily enough online by searching for the phrase
    //   "Tsiolkovsky rocket equation".
    // This example here will keep it simple for demonstration purposes,
    // but if you're going to build a serious node execution script, you
    // need to look into the Tsiolkovsky rocket equation to account for
    // the change in mass over time as you burn.
    //
    set burn_duration to nd:deltav:mag/max_acc.
    print "Crude Estimated burn duration: " + round(burn_duration) + "s".

	// Wait until we are near the node, with 60 seconds grace
	// This way we can wait in the current orientation, e.g. panels facing sun, until the last moment
	PRINT "Waiting TO align at T- " + ROUND(burn_duration/2 + 60).
	WAIT UNTIL nd:eta <= (burn_duration/2 + 60).

	// Point to node, keeping roll the same. We have about 60 seconds to do this
	// Large, unwieldy craft may fail without RCS, oscillating either side of the node
	PRINT "Rotating towards node".
	set np TO nd:deltav. //points to node, don't care about the roll direction.
    lock steering TO nd:deltav.

    //now we need to wait until the burn vector and ship's facing are aligned
    wait until vang(np, ship:facing:vector) < 0.25.

    //the ship is facing the right direction, let's wait for our burn time
    wait until nd:eta <= (burn_duration/2).

	PRINT "Executing node".

	//we only need to lock throttle once to a certain variable in the beginning of the loop, and adjust only the variable itself inside it
    set tset TO 0.
    lock throttle TO tset.

    set done TO False.
    //initial deltav
    set dv0 TO nd:deltav.
    until done
    {
        //recalculate current max_acceleration, as it changes while we burn through fuel
        set max_acc TO ship:maxthrust/ship:mass.
        SET v_angle_cos TO vdot(nd:deltav, steering) / (nd:deltav:mag * steering:mag).
        SET v_angle_cos TO max(v_angle_cos, 0).
        
        //throttle is 100% until there is less than 1 second of time left TO burn
        //when there is less than 1 second - decrease the throttle linearly
        SET tset TO min(nd:deltav:mag / max_acc * v_angle_cos * v_angle_cos, 1).

        //here's the tricky part, we need TO cut the throttle as soon as our nd:deltav and initial deltav start facing opposite directions
        //this check is done via checking the dot product of those 2 vectors
        if v_angle_cos < 0.8 OR vdot(nd:deltav, dv0) / (nd:deltav:mag * dv0:mag) < 0.5
        {
            print "#1 End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
            print "v_angle_cos = " + v_angle_cos + ", vdot = " + vdot(nd:deltav, dv0) / (nd:deltav:mag * dv0:mag).
            lock throttle TO 0.
            break.
        }

        //we have very little left TO burn, less then 0.1m/s
        if nd:deltav:mag < 0.1
        {
            //print "Finalizing burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
            //we burn slowly until our node vector starts TO drift significantly from initial vector
            //this usually means we are on point
            //wait until vdot(dv0, nd:deltav) < 0.5.

            lock throttle TO 0.
            print "#2 End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
            set done TO True.
        }
        
        WAIT 0.1.
    }
    
    
    
    unlock steering.
    unlock throttle.
    wait 1.

    //we no longer need the maneuver node
    remove nd.


	// Set throttle TO 0 just in case.
	SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
}
// ------------------------------------------------------------------------------------------------

// Creating a Circularisation Node by being clever
function circle 
{
	LOCAL ov TO 0.
	LOCAL av TO 0.
	
	// Calculate Orbital Velocity
	SET ov TO Orbital_velocity().
	
	// Get the predicted orbital velocity at apoapsis. This will be the MAGnitude of our orbital vector
	SET av TO VELOCITYAT(SHIP, TIME:SECONDS+ETA:APOAPSIS):ORBIT:MAG.
	
	// Calculate how much more velocity we need based on the required speed and our predicted speed
	LOCAL dv TO ov - av.
	
	// Create a node and add it TO the flight plan
	// Add the required deltaV TO prograde (assume all we want TO do is go faster in our current direction)
	LOCAL cnode TO NODE(TIME:SECONDS+ETA:APOAPSIS,0,0,dv).
	ADD cnode.
}