PROGRAM PLC_PRG
VAR
    nHeartbeat : UINT;
END_VAR

nHeartbeat := nHeartbeat + 1;   // Proves the task is scanning

PRG_InputSim();                 // 1. Copy simulated and HMI controls to inputs
PRG_Safety();                   // 2. Safety chain
PRG_Station();                  // 3. State machine and outputs
PRG_Ramp();                     // 4. Speed reference ramp
PRG_RunHours();                 // 5. Run-time counter
PRG_HMI();                      // 6. Screen texts and setpoint buttons