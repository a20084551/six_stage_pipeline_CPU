wvRestoreSignal -win $_nWave1 "/home/host/temp/N26091623/build/add.rc" \
           -overWriteAutoAlias on -appendSignals on
wvZoomIn -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomOut -win $_nWave1
wvSetCursor -win $_nWave1 11596346.618194 -snap {("WB" 2)}
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvSetCursor -win $_nWave1 11587967.907490 -snap {("ID" 0)}
wvSetCursor -win $_nWave1 11587967.907490 -snap {("ID" 2)}
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvSetCursor -win $_nWave1 11595683.436933 -snap {("MEM" 2)}
wvSetCursor -win $_nWave1 11595748.677643 -snap {("MEM" 3)}
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvSetCursor -win $_nWave1 11588813.034514 -snap {("EX" 1)}
wvZoom -win $_nWave1 11567936.007382 11584637.629087
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvSetCursor -win $_nWave1 11595844.430408 -snap {("EX" 2)}
wvSetCursor -win $_nWave1 11595686.495451 -snap {("EX" 2)}
wvZoomIn -win $_nWave1
wvSetCursor -win $_nWave1 11574773.274887 -snap {("ID" 1)}
wvSetCursor -win $_nWave1 11580564.223311 -snap {("ID" 4)}
wvSetCursor -win $_nWave1 11576115.722022 -snap {("ID" 1)}
wvSetCursor -win $_nWave1 11595639.114966 -snap {("ID" 6)}
wvSetCursor -win $_nWave1 11594086.087888 -snap {("ID" 6)}
wvSetCursor -win $_nWave1 11592769.963247 -snap {("ID" 6)}
wvSetCursor -win $_nWave1 11597060.529579 -snap {("ID" 1)}
wvSetCursor -win $_nWave1 11598639.879149 -snap {("MEM" 1)}
wvSetCursor -win $_nWave1 11600257.396334 -snap {("MEM" 2)}
wvSetCursor -win $_nWave1 11598704.369256 -snap {("MEM" 2)}
wvSetCursor -win $_nWave1 11597203.987165 -snap {("MEM" 1)}
wvSetCursor -win $_nWave1 11574698.255789 -snap {("ID" 3)}
wvSetCursor -win $_nWave1 11582200.166247 -snap {("ID" 7)}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/top_tb/TOP/cpu"
wvGetSignalSetSignalFilter -win $_nWave1 "*WB_pc"
wvSetPosition -win $_nWave1 {("WB" 2)}
wvSetPosition -win $_nWave1 {("WB" 2)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"IF" \
{/top_tb/TOP/clk} \
{/top_tb/TOP/rst} \
{/top_tb/TOP/cpu/pc1/pc\[31:0\]} \
{/top_tb/TOP/cpu/register1/RegWrite} \
}
wvAddSignal -win $_nWave1 -group {"ID" \
{/top_tb/TOP/cpu/ID_pc\[31:0\]} \
{/top_tb/TOP/cpu/ID_inst\[31:0\]} \
{/top_tb/TOP/cpu/ID_funct7\[6:0\]} \
{/top_tb/TOP/cpu/ID_funct3\[2:0\]} \
{/top_tb/TOP/cpu/ID_opcode\[6:0\]} \
{/top_tb/TOP/cpu/register1/regs\[5\]\[31:0\]} \
{/top_tb/TOP/cpu/register1/regs\[6\]\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"EX" \
{/top_tb/TOP/cpu/forward1/forward_A\[1:0\]} \
{/top_tb/TOP/cpu/forward1/forward_B\[1:0\]} \
}
wvAddSignal -win $_nWave1 -group {"MEM" \
{/top_tb/TOP/cpu/MEM_pc\[31:0\]} \
{/top_tb/TOP/cpu/DM_A\[13:0\]} \
{/top_tb/TOP/cpu/MEM_store\[2:0\]} \
{/top_tb/TOP/cpu/MEM_MemWrite\[3:0\]} \
{/top_tb/TOP/cpu/store_data\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"WB" \
{/top_tb/TOP/cpu/WB_ALU_result\[31:0\]} \
{/top_tb/TOP/cpu/MEM_DM_DO\[31:0\]} \
{/top_tb/TOP/cpu/WB_Utype_rd_result\[31:0\]} \
{/top_tb/TOP/cpu/WB_pc_add4\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G6" \
}
wvSetPosition -win $_nWave1 {("WB" 2)}
wvGetSignalSetSignalFilter -win $_nWave1 "*"
wvSetPosition -win $_nWave1 {("WB" 2)}
wvSetPosition -win $_nWave1 {("WB" 2)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"IF" \
{/top_tb/TOP/clk} \
{/top_tb/TOP/rst} \
{/top_tb/TOP/cpu/pc1/pc\[31:0\]} \
{/top_tb/TOP/cpu/register1/RegWrite} \
}
wvAddSignal -win $_nWave1 -group {"ID" \
{/top_tb/TOP/cpu/ID_pc\[31:0\]} \
{/top_tb/TOP/cpu/ID_inst\[31:0\]} \
{/top_tb/TOP/cpu/ID_funct7\[6:0\]} \
{/top_tb/TOP/cpu/ID_funct3\[2:0\]} \
{/top_tb/TOP/cpu/ID_opcode\[6:0\]} \
{/top_tb/TOP/cpu/register1/regs\[5\]\[31:0\]} \
{/top_tb/TOP/cpu/register1/regs\[6\]\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"EX" \
{/top_tb/TOP/cpu/forward1/forward_A\[1:0\]} \
{/top_tb/TOP/cpu/forward1/forward_B\[1:0\]} \
}
wvAddSignal -win $_nWave1 -group {"MEM" \
{/top_tb/TOP/cpu/MEM_pc\[31:0\]} \
{/top_tb/TOP/cpu/DM_A\[13:0\]} \
{/top_tb/TOP/cpu/MEM_store\[2:0\]} \
{/top_tb/TOP/cpu/MEM_MemWrite\[3:0\]} \
{/top_tb/TOP/cpu/store_data\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"WB" \
{/top_tb/TOP/cpu/WB_ALU_result\[31:0\]} \
{/top_tb/TOP/cpu/MEM_DM_DO\[31:0\]} \
{/top_tb/TOP/cpu/WB_Utype_rd_result\[31:0\]} \
{/top_tb/TOP/cpu/WB_pc_add4\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G6" \
}
wvSetPosition -win $_nWave1 {("WB" 2)}
wvGetSignalClose -win $_nWave1
wvSetCursor -win $_nWave1 11580673.461663 -snap {("ID" 6)}
wvExit
