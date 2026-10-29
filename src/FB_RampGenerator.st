FUNCTION_BLOCK FB_RampGenerator
VAR_INPUT
    xEnable    : BOOL;              // TRUE = ramp up to target and hold, FALSE = ramp down to 0 Hz
    xForceZero : BOOL;              // TRUE = output jumps to 0 Hz immediately (fault)
    rTarget_Hz : REAL;              // Speed to ramp up to
    tRampUp    : TIME;              // Time to go from 0 Hz to target
    tRampDown  : TIME;              // Time to go from target to 0 Hz
    tCycle     : TIME := T#10MS;    // Task cycle time (must match MainTask)
END_VAR
VAR_OUTPUT
    rOutput_Hz  : REAL;             // Ramped speed reference
    xAtSetpoint : BOOL;             // Enabled and output equals target
    xAtZero     : BOOL;             // Output is 0 Hz
END_VAR
VAR
    rTargetSafe : REAL;             // Target limited to 0 Hz or more
    rGoal       : REAL;             // Where the output is heading right now
    rStepUp     : REAL;             // Hz added per scan while accelerating
    rStepDown   : REAL;             // Hz removed per scan while decelerating
END_VAR
VAR CONSTANT
    rTolerance  : REAL := 0.001;    // Comparison tolerance in Hz
    rMinStep    : REAL := 0.001;    // Smallest allowed step, so a ramp always finishes
END_VAR

// ---------- 1. Goal ----------
rTargetSafe := MAX(rTarget_Hz, 0.0);

IF xEnable THEN
    rGoal := rTargetSafe;
ELSE
    rGoal := 0.0;
END_IF

// ---------- 2. Step sizes per scan ----------
IF tRampUp > T#0S THEN
    rStepUp := MAX(rTargetSafe * TIME_TO_REAL(tCycle) / TIME_TO_REAL(tRampUp), rMinStep);
ELSE
    rStepUp := MAX(rTargetSafe, rMinStep);      // Ramp time 0 = instant
END_IF

IF tRampDown > T#0S THEN
    rStepDown := MAX(rTargetSafe * TIME_TO_REAL(tCycle) / TIME_TO_REAL(tRampDown), rMinStep);
ELSE
    rStepDown := MAX(rTargetSafe, rMinStep);
END_IF

// ---------- 3. Move the output toward the goal ----------
IF xForceZero THEN
    rOutput_Hz := 0.0;
ELSIF rOutput_Hz < rGoal THEN
    rOutput_Hz := MIN(rOutput_Hz + rStepUp, rGoal);
ELSIF rOutput_Hz > rGoal THEN
    rOutput_Hz := MAX(rOutput_Hz - rStepDown, rGoal);
END_IF

// ---------- 4. Status flags ----------
xAtSetpoint := xEnable AND NOT xForceZero AND (ABS(rOutput_Hz - rTargetSafe) <= rTolerance);
xAtZero     := (rOutput_Hz <= rTolerance);