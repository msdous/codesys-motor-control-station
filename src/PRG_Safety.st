PROGRAM PRG_Safety
VAR
    fbResetTrig     : R_TRIG;   // Detects the rising edge of the reset button
    xEStopActive    : BOOL;     // TRUE while E-stop circuit is open
    xOverloadActive : BOOL;     // TRUE while overload relay is tripped
    xResetAllowed   : BOOL;     // TRUE when a latched fault may be cleared
END_VAR

// ---------- 1. Raw conditions (NC inputs: FALSE means a problem) ----------
xEStopActive    := NOT GVL_IO.iEStop_OK;
xOverloadActive := NOT GVL_IO.iOverload_OK;

// ---------- 2. Fault latch (E-stop has priority over overload) ----------
IF xEStopActive THEN
    GVL_Station.xFaultLatched := TRUE;
    GVL_Station.eFault        := E_FaultCode.ESTOP;
ELSIF xOverloadActive AND NOT GVL_Station.xFaultLatched THEN
    GVL_Station.xFaultLatched := TRUE;
    GVL_Station.eFault        := E_FaultCode.OVERLOAD;
END_IF

// ---------- 3. Fault reset (edge-triggered, only when the cause is gone) ----------
fbResetTrig(CLK := GVL_IO.iFaultReset_PB);
xResetAllowed := GVL_Station.xFaultLatched AND NOT xEStopActive AND NOT xOverloadActive;

IF fbResetTrig.Q AND xResetAllowed THEN
    GVL_Station.xFaultLatched := FALSE;
    GVL_Station.eFault        := E_FaultCode.NONE;
END_IF

// ---------- 4. Permissive for the rest of the program ----------
GVL_Station.xSafeToRun := NOT GVL_Station.xFaultLatched
                          AND NOT xEStopActive
                          AND NOT xOverloadActive;