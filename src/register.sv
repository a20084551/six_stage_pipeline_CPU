module register(
input logic clk,rst,
input logic RegWrite,
input logic [4 :0] Read_Reg1,Read_Reg2,Write_Reg,
input logic [31:0] WB_result,

output logic[31:0] reg_data1,reg_data2
);

integer i; 
logic [31:0] regs [0:31];

always_ff @ (posedge clk , posedge rst) begin
    if(rst)begin
		for(i = 0 ; i < 31 ; i = i + 1) begin 
			regs[i] <= 32'd0;
		end

    end else begin 
		if( (RegWrite) & (Write_Reg != 0) )begin //must Write_Reg != 0
			regs[Write_Reg] <= WB_result;
		end else begin 
			regs[Write_Reg] <= regs[Write_Reg];
		end
    end
end
    
assign reg_data1 = regs[Read_Reg1];
assign reg_data2 = regs[Read_Reg2];


endmodule
