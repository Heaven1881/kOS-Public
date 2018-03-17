//Library for dealing with Rapier engines
//All function calls should operate on all Rapiers on the craft.

//Get handles for Rapier engines

SET rapierEngines TO SHIP:PARTSNAMED("RAPIER"). //Get list

//===========================================
//Setup complete.  Begin declaring functions.
//===========================================

FUNCTION SetRapiersOn {
	FOR e IN rapierEngines {
		e:Activate().
	}.
}
FUNCTION SetRapiersOff {
	FOR e IN rapierEngines {
		e:Shutdown().
	}.
}.

FUNCTION SetRapiersMode { 
parameter mode.		//Pass "AirBreathing" or "ClosedCycle"
	LOCAL newPrimaryMode Is True.
	IF mode = "AirBreathing" {
		SET newPrimaryMode TO True.
	}. ELSE IF mode = "ClosedCycle" {
		SET newPrimaryMode TO False.
	}. ELSE {
		PRINT "SetRapiersMode: Pass 'AirBreathing' or 'ClosedCycle'".
		RETURN.
	}
	
	FOR e IN rapierEngines {
		SET e:PrimaryMode TO newPrimaryMode. 
	}
}.

FUNCTION SetRapiersGimbal {
parameter new.		//Pass "On" or "Off", since True/False is unclear here
	LOCAL newLockState IS True.
	IF new = "On" {
		SET newLockState TO False.
	}. ELSE IF new = "Off" {
		SET newLockState TO True.
	}. ELSE {
		PRINT "SetRapiersGimbal: Pass 'On' or 'Off'".
		RETURN.
	}
	
	FOR e IN rapierEngines {
		SET e:Gimbal:Lock TO newLockState.
	}
}.
