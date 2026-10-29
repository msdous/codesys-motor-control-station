PROGRAM PRG_RunHours
VAR CONSTANT
    nTaskCycle_ms : UDINT := 10;    // Must equal the MainTask interval
END_VAR
VAR
    nMilliseconds : UDINT;          // Partial second, carried over between runs
END_VAR

// Count time while the VFD run command is active (includes the stop ramp)
IF GVL_IO.qDriveRun THEN
    nMilliseconds := nMilliseconds + nTaskCycle_ms;

    IF nMilliseconds >= 1000 THEN
        nMilliseconds := nMilliseconds - 1000;
        GVL_Station.nRunSeconds := GVL_Station.nRunSeconds + 1;
    END_IF
END_IF

GVL_Station.rRunHours := UDINT_TO_REAL(GVL_Station.nRunSeconds) / 3600.0;