LIST engines IN eng.
SET jets TO List(). 
SET rapiers TO List(). 
SET nervs TO List(). 
SET rockets TO List(). 

SET jetMinThrust TO 70. //Point at which jets are considered done.

//TODO: Figure out how to exclude payload engines
for e in eng {
	if (e:name = "RAPIER") {rapiers:ADD(e).}.
	else if (e:name = "nuclearEngine") {nervs:ADD(e).}.

	//TODO detect jet/rocket generally?.
	else if (e:name = "turboFanEngine") {jets:ADD(e).}.
	//Matches many liquid rocket engines, not all
	else if (e:name:contains("Liquid")) {rockets:ADD(e).}.

	else {Print "Error: Unclassified engine " + e:name + " will be ignored".}.
}.

Function RapierSet {
//List of rapier engines, bool air
parameter air.
	for r in rapiers {
		if NOT (air = r:PrimaryMode) { r:togglemode(). }.
	}.
}.


Function EngineSet {
//Pass a list of engines, and a bool, on
parameter eList, on.
	if on {
		for e in eList {e:Activate.}.
	}.
	else {
		for e in eList {e:Shutdown.}.
	}.
}.


for r in rapiers {
	set r:autoswitch to false.
}.
