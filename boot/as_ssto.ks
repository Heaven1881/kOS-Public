// Boot script for SSTO with R.A.P.I.E.R.

SWITCH TO 0.

SET takeoffSpeed TO 130.
SET climbDeg TO 20.
SET climbToHeight TO 10000.
SET speedingDeg TO 8.
SET speedingToHeight TO 23000.
SET boostDeg TO 15.
SET boostToAp TO 80000.

WHEN Ship:Altitude > 70000 THEN {
    TOGGLE AG10.
}

runpath("ssto", takeoffSpeed, climbDeg, climbToHeight, speedingDeg, speedingToHeight, boostDeg, boostToAp).

//Delete boot script (this file) from bootloader
SET CORE:BOOTFILENAME TO "".