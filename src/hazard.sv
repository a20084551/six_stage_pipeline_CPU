module hazard(
  input EX_MemRead,
  input[4:0] rs1,rs2,
  input[4:0] rd,

  output logic stall
);
	
always_comb begin
    if(EX_MemRead)begin
        if( (rs1 == rd) | (rs2 == rd)) begin 
          stall = 1'd1;
        end else begin 
          stall = 1'd0;
        end
    end else begin 
      stall = 1'd0;
    end
end	

endmodule	
	

