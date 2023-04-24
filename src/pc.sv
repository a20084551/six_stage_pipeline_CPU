module pc(
    input clk,rst,
    input branch_enable,jump,JALR,stall,
    input [31:0] pc_add_imm,imm_add_rs1,ID_pc,

    output logic [31:0] pc,
    output logic [31:0] pc_add4 //use to U-type forward ALU signal
);

logic [31:0] pc_src1 , pc_src2;

always_comb begin //PCSrc(mux1) : deal with branch (branch、jump、JALR、pc_add4)
    case( {branch_enable , jump , JALR} )
        3'b100 : pc_src1 = pc_add_imm;
        3'b001 : pc_src1 = imm_add_rs1;
        3'b010 : pc_src1 = pc_add_imm;
        default : pc_src1 = pc_add4;
    endcase
end

always_comb begin //mux2 : deal with stall (fetch ID_pc back)
    if(stall) begin 
        pc_src2 = ID_pc;
    end else begin 
        pc_src2 = pc_src1;
    end
end

always_ff @ (posedge clk , posedge rst) begin 
    if(rst) begin 
        pc <= 32'd0;
    end else begin 
        pc <= pc_src2;
    end
end

assign pc_add4 = pc + 4;

endmodule
