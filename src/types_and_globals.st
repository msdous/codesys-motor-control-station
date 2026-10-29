// ===== E_FaultCode =====

{attribute 'qualified_only'}
{attribute 'strict'}
TYPE E_FaultCode :
(
    NONE     := 0,
    ESTOP    := 1,   // Emergency stop pressed or circuit broken
    OVERLOAD := 2    // Thermal overload relay tripped
) UINT;
END_TYPE

{attribute 'qualified_only'}
{attribute 'strict'}
TYPE E_FaultCode :
(
    NONE     := 0,
    ESTOP    := 1,   // Emergency stop pressed or circuit broken
    OVERLOAD := 2    // Thermal overload relay tripped
) UINT;
END_TYPE

// ===== E_StationState =====

{attribute 'qualified_only'}
{attribute 'strict'}
TYPE E_StationState :
(
    IDLE     := 0,   // Stopped, ready to start
    STARTING := 1,   // Soft-start ramp running
    RUNNING  := 2,   // At speed setpoint
    STOPPING := 3,   // Soft-stop ramp running
    FAULT    := 4    // Fault latched, outputs off
) UINT;
END_TYPE

// ===== ST_Config =====

TYPE ST_Config :
STRUCT
    tRampUp           : TIME := T#5S;    // Soft-start duration (0 Hz to setpoint)
    tRampDown         : TIME := T#5S;    // Soft-stop duration (setpoint to 0 Hz)
    rSpeedMin_Hz      : REAL := 5.0;     // Lowest allowed setpoint
    rSpeedMax_Hz      : REAL := 50.0;    // Highest allowed setpoint
    rSpeedSetpoint_Hz : REAL := 40.0;    // Operator target speed
END_STRUCT
END_TYPE

// ===== GVL_HMI =====

{attribute 'qualified_only'}
VAR_GLOBAL
    xStart        : BOOL;   // Momentary: TRUE while START is pressed
    xStop         : BOOL;   // Momentary: TRUE while STOP is pressed
    xReset        : BOOL;   // Momentary: TRUE while RESET is pressed
    xEStop        : BOOL;   // Latching switch: TRUE = E-stop pressed
    xOverloadTrip : BOOL;   // Latching switch: TRUE = overload tripped
    xSetpointUp   : BOOL;   // Momentary: setpoint +5 Hz
    xSetpointDown : BOOL;   // Momentary: setpoint -5 Hz
END_VAR

// ===== GVL_IO =====

{attribute 'qualified_only'}
VAR_GLOBAL
    // ---------- Inputs ----------
    iEStop_OK       : BOOL;   // NC contact: TRUE = healthy, FALSE = E-stop pressed or wire broken
    iStop_PB        : BOOL;   // NC contact: TRUE = released, FALSE = pressed
    iStart_PB       : BOOL;   // NO contact: TRUE = pressed
    iOverload_OK    : BOOL;   // NC contact: TRUE = healthy, FALSE = overload tripped
    iFaultReset_PB  : BOOL;   // NO contact: TRUE = pressed

    // ---------- Outputs ----------
    qContactor_KM1  : BOOL;   // Main contactor coil
    qDriveRun       : BOOL;   // Run command to the VFD
    qSpeedRef_Hz    : REAL;   // Speed reference sent to the VFD (analog output, in Hz)
    qLamp_Ready     : BOOL;   // White: station ready
    qLamp_Run       : BOOL;   // Green: motor running or ramping
    qLamp_Fault     : BOOL;   // Red: fault latched
END_VAR

// ===== GVL_SIM =====

{attribute 'qualified_only'}
VAR_GLOBAL
    xEnable       : BOOL := TRUE;   // TRUE = simulation writes the GVL_IO inputs

    // Simulated input conditions
    xEStop_OK     : BOOL := TRUE;   // TRUE = E-stop circuit healthy
    xStop_PB      : BOOL := TRUE;   // TRUE = Stop button released
    xStart_PB     : BOOL := FALSE;  // TRUE = Start button pressed
    xOverload_OK  : BOOL := TRUE;   // TRUE = overload circuit healthy
    xFaultReset_PB : BOOL := FALSE; // TRUE = reset button pressed
END_VAR


// ===== GVL_STATION =====

{attribute 'qualified_only'}
VAR_GLOBAL
    stConfig       : ST_Config;                                  // Tunable parameters
    eState         : E_StationState := E_StationState.IDLE;      // Current state machine state
    eFault         : E_FaultCode    := E_FaultCode.NONE;         // Active fault cause
    xFaultLatched  : BOOL;                                       // TRUE until reset
    xSafeToRun     : BOOL;                                       // TRUE only when no fault and all safety inputs healthy
    xRunLatched    : BOOL;                                       // Start/stop seal-in memory
    rSpeedRef_Hz   : REAL;                                       // Ramp output (feeds qSpeedRef_Hz)
    xAtSetpoint    : BOOL;                                       // Ramp has reached the setpoint
    xAtZero        : BOOL;                                       // Ramp has reached 0 Hz
    rRunHours      : REAL;                                       // Run time in hours (for display)
END_VAR

VAR_GLOBAL PERSISTENT RETAIN
    nRunSeconds    : UDINT;                                      // Drive-on time in seconds, survives power cycles
END_VAR
