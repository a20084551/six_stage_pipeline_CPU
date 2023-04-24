module forward(
  input [4:0] EX_rs1,
  input [4:0] EX_rs2,
  input [4:0] ID_rs1,
  input [4:0] ID_rs2,
  input [4:0] MEM_rd,
  input [4:0] WB_rd,
  input MEM_RegWrite,WB_RegWrite,

  output logic [1:0] forward_A,
  output logic [1:0] forward_B,
  output logic forward_reg1,forward_reg2
);

always_comb begin 
    if((MEM_RegWrite) & (MEM_rd != 0) & (EX_rs1 == MEM_rd) ) begin 
        forward_A = 2'd1;
    end else if ((WB_RegWrite) & (WB_rd != 0) & (EX_rs1 == WB_rd) ) begin 
        forward_A = 2'd2;
    end else begin 
        forward_A = 2'd0;
    end
end

always_comb begin
    if((MEM_RegWrite) & (MEM_rd != 0) & (EX_rs2 == MEM_rd) ) begin 
        forward_B = 2'd1;
    end else if ((WB_RegWrite) & (WB_rd != 0) & (EX_rs2 == WB_rd) ) begin 
        forward_B = 2'd2;
    end else begin 
        forward_B = 2'd0;
    end
end

always_comb begin 
    if(WB_RegWrite & (ID_rs1 == WB_rd) ) begin 
      forward_reg1 = 1'd1;
    end else begin 
      forward_reg1 = 1'd0;
    end
end

always_comb begin 
    if(WB_RegWrite & (ID_rs2 == WB_rd)) begin 
      forward_reg2 = 1'd1;
    end else begin 
      forward_reg2 = 1'd0;
    end
end

endmodule