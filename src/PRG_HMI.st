PROGRAM PRG_HMI
VAR CONSTANT
    rSetpointStep_Hz : REAL := 5.0;     // Change per button click
END_VAR
VAR
    sState   : STRING(30);              // State text for the screen
    sFault   : STRING(30);              // Fault text for the screen
    fbSpUp   : R_TRIG;                  // Edge detect: setpoint up
    fbSpDown : R_TRIG;                  // Edge detect: setpoint down
END_VAR

// ---------- State text ----------
CASE GVL_Station.eState OF
    E_StationState.IDLE:     sState := 'IDLE';
    E_StationState.STARTING: sState := 'STARTING (RAMP UP)';
    E_StationState.RUNNING:  sState := 'RUNNING';
    E_StationState.STOPPING: sState := 'STOPPING (RAMP DOWN)';
    E_StationState.FAULT:    sState := 'FAULT';
END_CASE

// ---------- Fault text ----------
CASE GVL_Station.eFault OF
    E_FaultCode.NONE:     sFault := 'NONE';
    E_FaultCode.ESTOP:    sFault := 'EMERGENCY STOP';
    E_FaultCode.OVERLOAD: sFault := 'MOTOR OVERLOAD';
END_CASE

// ---------- Setpoint buttons (one step per click, kept inside min/max) ----------
fbSpUp  (CLK := GVL_HMI.xSetpointUp);
fbSpDown(CLK := GVL_HMI.xSetpointDown);

IF fbSpUp.Q THEN
    GVL_Station.stConfig.rSpeedSetpoint_Hz := LIMIT(GVL_Station.stConfig.rSpeedMin_Hz,
                                                    GVL_Station.stConfig.rSpeedSetpoint_Hz + rSetpointStep_Hz,
                                                    GVL_Station.stConfig.rSpeedMax_Hz);
END_IF

IF fbSpDown.Q THEN
    GVL_Station.stConfig.rSpeedSetpoint_Hz := LIMIT(GVL_Station.stConfig.rSpeedMin_Hz,
                                                    GVL_Station.stConfig.rSpeedSetpoint_Hz - rSetpointStep_Hz,
                                                    GVL_Station.stConfig.rSpeedMax_Hz);
END_IF