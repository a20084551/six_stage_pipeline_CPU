`include "cpu.sv"
`include "SRAM_wrapper.sv"
module top(
    input clk,rst
);

logic IM_CS,IM_OE,DM_CS,DM_OE;
logic [3 :0] IM_WEB,DM_WEB;
logic [13:0] IM_A;
logic [13:0] DM_A;
logic [31:0] DM_DI;
logic [31:0] IM_DO,DM_DO;

cpu cpu(
    .clk            (clk),
    .rst            (rst),
    .IM_DO          (IM_DO),
    .DM_DO          (DM_DO),

    .IM_CS          (IM_CS),
    .IM_OE          (IM_OE),
    .DM_CS          (DM_CS),
    .DM_OE          (DM_OE),
    .IM_WEB         (IM_WEB),
    .DM_WEB         (DM_WEB),
    .IM_A           (IM_A),
    .DM_A           (DM_A),
    .DM_DI          (DM_DI)
);

SRAM_wrapper IM1(
    .CK         (clk),
    .CS         (IM_CS),
    .OE         (IM_OE),
    .WEB        (IM_WEB),
    .A          (IM_A),
    .DI         (32'h0), //useless (IM is ROM)

    .DO         (IM_DO)
);

SRAM_wrapper DM1(
    .CK         (clk),
    .CS         (DM_CS),
    .OE         (DM_OE),
    .WEB        (DM_WEB),
    .A          (DM_A),
    .DI         (DM_DI),

    .DO         (DM_DO)
);

endmodule
