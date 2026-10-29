PROGRAM PRG_InputSim
// When enabled, merge the simulator controls and the HMI controls into the project inputs.
// NC contacts (E-stop, Stop, Overload): healthy only if the simulator says healthy AND the HMI is not pressing.
// NO contacts (Start, Reset): active if either source presses.
IF GVL_Sim.xEnable THEN
    GVL_IO.iEStop_OK      := GVL_Sim.xEStop_OK     AND NOT GVL_HMI.xEStop;
    GVL_IO.iStop_PB       := GVL_Sim.xStop_PB      AND NOT GVL_HMI.xStop;
    GVL_IO.iStart_PB      := GVL_Sim.xStart_PB     OR  GVL_HMI.xStart;
    GVL_IO.iOverload_OK   := GVL_Sim.xOverload_OK  AND NOT GVL_HMI.xOverloadTrip;
    GVL_IO.iFaultReset_PB := GVL_Sim.xFaultReset_PB OR GVL_HMI.xReset;
END_IF