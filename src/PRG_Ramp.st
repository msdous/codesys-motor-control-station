PROGRAM PRG_Ramp
VAR CONSTANT
    tTaskCycle : TIME := T#10MS;    // Must equal the MainTask interval
END_VAR
VAR
    fbRamp     : FB_RampGenerator;
    rTarget_Hz : REAL;              // Setpoint limited to the allowed range
END_VAR

// Keep the operator setpoint inside the allowed range
rTarget_Hz := LIMIT(GVL_Station.stConfig.rSpeedMin_Hz,
                    GVL_Station.stConfig.rSpeedSetpoint_Hz,
                    GVL_Station.stConfig.rSpeedMax_Hz);

fbRamp(
    xEnable    := GVL_Station.xRunLatched AND GVL_IO.qDriveRun,   // Ramp starts once the drive has its run command
    xForceZero := NOT GVL_Station.xSafeToRun,                     // Any fault: 0 Hz immediately
    rTarget_Hz := rTarget_Hz,
    tRampUp    := GVL_Station.stConfig.tRampUp,
    tRampDown  := GVL_Station.stConfig.tRampDown,
    tCycle     := tTaskCycle
);

// Publish results
GVL_Station.rSpeedRef_Hz := fbRamp.rOutput_Hz;
GVL_Station.xAtSetpoint  := fbRamp.xAtSetpoint;
GVL_Station.xAtZero      := fbRamp.xAtZero;

// Analog output to the VFD
GVL_IO.qSpeedRef_Hz := GVL_Station.rSpeedRef_Hz;