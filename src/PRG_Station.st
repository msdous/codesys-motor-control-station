PROGRAM PRG_Station
VAR CONSTANT
    tContactorDelay : TIME := T#500MS;   // Wait after KM1 closes before the drive gets its run command
    tBlinkHalf      : TIME := T#500MS;   // Half period of the lamp blinker
END_VAR
VAR
    fbStartTrig   : R_TRIG;   // Rising edge of the Start button
    fbDriveDelay  : TON;      // Contactor pull-in delay
    fbBlink       : TON;      // Blink generator
    xBlink        : BOOL;     // 1 Hz blink signal
    xMotorPowered : BOOL;     // TRUE when the contactor should be closed
END_VAR

// ---------- 1. Start/stop seal-in ----------
// Start: NO button, accepted only in IDLE on a rising edge.
// Stop: NC button (TRUE = released). Stop and safety always win.
fbStartTrig(CLK := GVL_IO.iStart_PB);

GVL_Station.xRunLatched := (   (fbStartTrig.Q AND (GVL_Station.eState = E_StationState.IDLE))
                            OR GVL_Station.xRunLatched )
                           AND GVL_IO.iStop_PB
                           AND GVL_Station.xSafeToRun;

// ---------- 2. State machine ----------
IF NOT GVL_Station.xSafeToRun THEN
    GVL_Station.eState := E_StationState.FAULT;
ELSE
    CASE GVL_Station.eState OF

        E_StationState.FAULT:
            // Safety is healthy again (fault was reset)
            GVL_Station.eState := E_StationState.IDLE;

        E_StationState.IDLE:
            IF GVL_Station.xRunLatched THEN
                GVL_Station.eState := E_StationState.STARTING;
            END_IF

        E_StationState.STARTING:
            IF NOT GVL_Station.xRunLatched THEN
                GVL_Station.eState := E_StationState.STOPPING;
            ELSIF GVL_Station.xAtSetpoint THEN
                GVL_Station.eState := E_StationState.RUNNING;
            END_IF

        E_StationState.RUNNING:
            IF NOT GVL_Station.xRunLatched THEN
                GVL_Station.eState := E_StationState.STOPPING;
            END_IF

        E_StationState.STOPPING:
            IF GVL_Station.xAtZero THEN
                GVL_Station.eState := E_StationState.IDLE;
            END_IF

    END_CASE
END_IF

// ---------- 3. Contactor and drive run command ----------
xMotorPowered := (GVL_Station.eState = E_StationState.STARTING)
              OR (GVL_Station.eState = E_StationState.RUNNING)
              OR (GVL_Station.eState = E_StationState.STOPPING);

GVL_IO.qContactor_KM1 := xMotorPowered;

fbDriveDelay(IN := xMotorPowered, PT := tContactorDelay);
GVL_IO.qDriveRun := fbDriveDelay.Q;

// ---------- 4. Lamps ----------
// Blink generator: the TON restarts itself, giving one pulse every tBlinkHalf
fbBlink(IN := NOT fbBlink.Q, PT := tBlinkHalf);
IF fbBlink.Q THEN
    xBlink := NOT xBlink;
END_IF

GVL_IO.qLamp_Ready := (GVL_Station.eState = E_StationState.IDLE);

GVL_IO.qLamp_Run   := (GVL_Station.eState = E_StationState.RUNNING)
                      OR ( xBlink AND (    (GVL_Station.eState = E_StationState.STARTING)
                                        OR (GVL_Station.eState = E_StationState.STOPPING) ) );

GVL_IO.qLamp_Fault := GVL_Station.xFaultLatched;