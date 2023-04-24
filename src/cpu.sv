`include "pc.sv"
`include "controller.sv"
`include "register.sv"
`include "extend.sv"
`include "hazard.sv"
`include "ALU.sv"
`include "forward.sv"
module cpu(
	input clk,rst,
	input [31:0]IM_DO,DM_DO,

	output logic IM_CS,IM_OE,DM_CS,DM_OE,
	output logic [3 :0]IM_WEB,DM_WEB,
	output logic [13:0]IM_A,DM_A,
	output logic [31:0]DM_DI
);

logic [31:0] pc_add4,pc; //IF
reg [31:0] inst;
logic [31:0] pc_delay,pc_add4_delay,ID_pc_add4,ID_pc,ID_inst; 

logic [4 :0] ID_rs1,ID_rs2; //ID
logic [4 :0] ID_rd;
logic [6 :0] ID_opcode;
logic [2 :0] ID_funct3;
logic [6 :0] ID_funct7;
logic [2 :0] ID_load;
logic [2 :0] ID_store;
logic [31:0] ID_imm;
logic ID_jump,ID_branch,ID_MemRead;
logic ID_ALUSrc,ID_RegWrite,ID_Utype_rd,ID_JALR,ID_branch_type2;
logic [1 :0] ID_resultSel;
logic [3 :0] ID_MemWrite;
logic [31:0] ID_reg_data1,ID_reg_data2;
logic [6 :0] aluop;
logic [1 :0] ID_Memforward; 
logic stall;
logic stall_delay;

logic EX_jump,EX_branch,EX_MemRead; //EX
logic EX_ALUSrc,EX_RegWrite,EX_Utype_rd,EX_JALR,EX_branch_type2;  
logic branch_enable;
logic branch_enable1;
logic [31:0] EX_reg_data1,EX_reg_data2;
logic [31:0] EX_imm,EX_pc_add4,EX_pc;
logic [1 :0] EX_resultSel;
logic [3 :0] EX_MemWrite;
logic [4 :0] EX_rd;
logic [2 :0] EX_funct3;
logic [6 :0] EX_funct7;
logic [31:0] ALU_pc_add_imm;
logic [31:0] ALU_in1,ALU_in2,EX_ALU_result;
logic [31:0] ALU_in2_1;
logic ALU_zero;
logic [4 :0] EX_rs1,EX_rs2;
logic [1 :0] forward_A,forward_B;
logic flush,flush_delay;
logic [6 :0] EX_aluop;
logic [1 :0] EX_Memforward; 
logic [2 :0] EX_load;
logic [2 :0] EX_store;
logic [31:0] reg_data1,reg_data2;
logic forward_reg1,forward_reg2;
logic [1 :0] forward_sw;
logic [31:0] MEM_ALU_in2;

logic MEM_MemRead; //MEM 
logic MEM_RegWrite,MEM_Utype_rd;
logic [1 :0] MEM_resultSel;
logic [3 :0] MEM_MemWrite;
logic [31:0] MEM_ALU_result,MEM_pc_add_imm,MEM_pc_add4,MEM_imm,MEM_reg_data2;
logic [4 :0] MEM_rd;
logic [31:0] MEM_Utype_rd_result;
logic [31:0] MEM_DM_DO;
logic [31:0] MEM_forward_alu;
logic [31:0] MEM_pc;
logic [2 :0] MEM_load;
logic [2 :0] MEM_store;
logic [1 :0] MEM_Memforward; 
logic [3 :0] MEM_store_MemWrite;
logic [31:0] store_data;
logic [1 :0] alu_2bit;

logic WB_RegWrite; //WB 
logic [31:0] WB_result;
logic [1 :0] WB_resultSel;
logic [4 :0] WB_rd;
logic WB_MemRead;
logic [31:0] WB_pc_add4,WB_Utype_rd_result,WB_DM_DO,WB_ALU_result;
logic [31:0] DM_Data;
logic [2:0] WB_load;

/**************************debug***********************/ //debug
/*
logic main;
assign main = (pc==32'h00000148) ? 1 : 0; 

logic mem_hazard;
assign mem_hazard = ((ID_rs1 == WB_rd ) & WB_RegWrite) ? 1 : 0;

logic addr;
assign addr = (DM_A == 8192) ? 1 : 0;

logic [20:0] cnt;
always_ff @ (posedge clk , posedge rst) begin 
	if(rst) begin 
		cnt <= 0;
	end else begin 
		if(DM_A == 8192) begin 
			cnt <= cnt + 1;
		end else begin 
			cnt <= cnt;
		end
	end
end
*/

logic pc_fig;
assign pc_fig = (pc == 32'h128) ? 1'd1 : 1'd0; 

logic rstx; //use to pass synthesis error
always_ff @ (posedge clk) begin //can't posedge rst : postsim error!!! 
	rstx <= rst;
end
/**************************IF**************************/
pc pc1(
	.clk				(clk),
	.rst 				(rstx),
	.branch_enable		(branch_enable),
	.jump				(EX_jump),
	.JALR				(EX_JALR),
	.stall 				(stall),
	.pc_add_imm			(ALU_pc_add_imm),
	.imm_add_rs1		(EX_ALU_result),
	.ID_pc				(ID_pc),

	.pc 				(pc),
	.pc_add4			(pc_add4)
);

//assign IM_A = pc[15:2]; //IM
always_comb begin //if rst IM_A is unknown , postsim have MEM_error : unknown value in IM_A
	if(rst | rstx) begin 
		IM_A = 0;
	end else begin 
		IM_A = pc[15:2];	
	end
end

assign IM_WEB = 4'b1111;
assign IM_CS = 1'd1;
assign IM_OE = 1'd1;


always_comb begin
  if(flush | stall_delay | rstx | rst) begin 
	  inst = 32'd0;
  end else begin 
	  inst = IM_DO;
  end
end


/**************************IF/ID*************************/
always_ff @ (posedge clk , posedge rstx) begin //pc should delay 1 cycle to wait inst //superlint : reg have to set or reset
	if(rstx)begin
    	pc_delay <= 32'd0;
		pc_add4_delay <= 32'd0;
  	end else if(flush | stall)begin
    	pc_delay <= 32'd0;
		pc_add4_delay <= 32'd0;
  	end else begin
    	pc_delay <= pc;
		pc_add4_delay <= pc_add4;	
	end
end

always_ff @ (posedge clk , posedge rstx) begin 
	if(rstx)begin
		ID_pc_add4 <= 32'd0;
		ID_pc <= 32'd0;
	end else begin
		if (flush | stall)begin
			ID_pc_add4 <= 32'd0;
			ID_pc <= 32'd0;
		end else begin
			ID_pc_add4 <= pc_add4_delay;
			ID_pc <= pc_delay;
		end
	end
end


always_ff @ (posedge clk , posedge rstx) begin
	if(rstx)begin
		ID_inst <= 32'd0;
	end else begin
		if(flush_delay | stall)begin
			ID_inst <= 32'd0;	
		end else begin
			ID_inst <= inst;
		end
	end
end


/**************************ID*************************/ 
assign ID_funct7 = ID_inst[31:25]; //decode
assign ID_rs2 = ID_inst[24:20];
assign ID_rs1 = ID_inst[19:15];
assign ID_funct3 = ID_inst[14:12];
assign ID_rd = ID_inst[11:7];
assign ID_opcode = ID_inst[6:0];


extend extend1(
	.inst				(ID_inst),
	.opcode				(ID_opcode),

	.ID_imm				(ID_imm)
);

controller controller1(
	.funct3				(ID_funct3),
	.funct7             (ID_funct7),
	.opcode				(ID_opcode),

	.jump				(ID_jump),  //output signal : 14
	.branch				(ID_branch), 
	.JALR				(ID_JALR),
	.branch_type2		(ID_branch_type2),
	.MemRead			(ID_MemRead), 
	.MemWrite			(ID_MemWrite), 
	.ALUSrc				(ID_ALUSrc), 
	.RegWrite			(ID_RegWrite), 
	.load				(ID_load),
	.store				(ID_store),
	.Utype_rd			(ID_Utype_rd), 
	.resultSel			(ID_resultSel), 
	.aluop 				(aluop),
	.Memforward 		(ID_Memforward)
);

hazard hazard1(
	.EX_MemRead		(EX_MemRead),
	.rs1			(ID_rs1),
	.rs2			(ID_rs2),
	.rd				(EX_rd),

	.stall			(stall)
);

always_ff @ (posedge clk , posedge rst) begin //stall inst (inst delay 1 cycle)
	if(rst)
		stall_delay <= 1'd0;
	else begin
		stall_delay <= (stall) ? stall : 1'd0;
	end 
end

register register1(
	.clk			(clk),
	.rst			(rst),
	.RegWrite		(WB_RegWrite),  
	.Read_Reg1		(ID_rs1),
	.Read_Reg2		(ID_rs2),
	.Write_Reg		(WB_rd),
	.WB_result		(WB_result),

	.reg_data1		(ID_reg_data1),
	.reg_data2		(ID_reg_data2)
);


always_comb begin 
	if(forward_reg1) begin 
		reg_data1 = WB_result;
	end else begin 
		reg_data1 = ID_reg_data1;
	end
end

always_comb begin 
	if(forward_reg2) begin 
		reg_data2 = WB_result;
	end else begin 
		reg_data2 = ID_reg_data2;
	end
end

/**************************ID/EX*************************/
always_ff @ (posedge clk , posedge rst) begin
	if(rst)begin
		EX_jump <= 1'd0;                 
		EX_branch <= 1'd0;               
		EX_JALR <= 1'd0;                 
		EX_MemRead <= 1'd0;              
		EX_MemWrite <= 4'd0;             
		EX_ALUSrc <= 1'd0;               
		EX_RegWrite <= 1'd0;                        
		EX_resultSel <= 2'd0;            
		EX_load <= 3'd0;  
		EX_store <= 3'd0;	
		EX_Utype_rd <= 1'd0;
		EX_branch_type2 <= 1'd0;	
		EX_aluop <= 7'd0;
		EX_Memforward <= 2'd0;
	end else begin
		if(flush | stall)begin
			EX_jump <= 1'd0;                 
			EX_branch <= 1'd0;               
			EX_JALR <= 1'd0;                 
			EX_MemRead <= 1'd0;              
			EX_MemWrite <= 4'd0;             
			EX_ALUSrc <= 1'd0;               
			EX_RegWrite <= 1'd0;                         
			EX_resultSel <= 2'd0;            
			EX_load <= 3'd0;  
			EX_store <= 3'd0;	
			EX_Utype_rd <= 1'd0;
			EX_branch_type2 <= 1'd0;	
			EX_aluop <= 7'd0;
			EX_Memforward <= 2'd0;
		end else begin
			EX_jump <= ID_jump;                 
			EX_branch <= ID_branch;               
			EX_JALR <= ID_JALR;                 
			EX_MemRead <= ID_MemRead;              
			EX_MemWrite <= ID_MemWrite;             
			EX_ALUSrc <= ID_ALUSrc;               
			EX_RegWrite <= ID_RegWrite;                        
			EX_resultSel <= ID_resultSel;            
			EX_load <= ID_load; 
			EX_store <= ID_store;		
			EX_Utype_rd <= ID_Utype_rd;  
			EX_branch_type2 <= ID_branch_type2;
			EX_aluop <= aluop;
			EX_Memforward <= ID_Memforward;; 
		end
	end
end

//logic [31:0] EX_inst; //debug

always_ff @ (posedge clk , posedge rst) begin 
	if(rst) begin 
		EX_rs1 <= 5'd0;
		EX_rs2 <= 5'd0;
		EX_pc_add4 <= 32'd0;
		EX_pc <= 32'd0;
		EX_funct3 <= 3'd0;
		EX_funct7 <= 7'd0;
		EX_reg_data1 <= 32'd0; 
		EX_reg_data2 <= 32'd0;
		EX_imm <= 32'd0;	
		EX_rd <= 5'd0;
		//EX_inst <= 0;
	end else begin 
		if(flush | stall) begin 
			EX_rs1 <= 5'd0;
			EX_rs2 <= 5'd0;
			EX_pc_add4 <= 32'd0;
			EX_pc <= 32'd0;
			EX_funct3 <= 3'd0;
			EX_funct7 <= 7'd0;
			EX_reg_data1 <= 32'd0; 
			EX_reg_data2 <= 32'd0;
			EX_imm <= 32'd0;	
			EX_rd <= 5'd0;
			//EX_inst <= 0;
		end else begin 
			EX_rs1 <= ID_rs1;
			EX_rs2 <= ID_rs2;
			EX_pc_add4 <= ID_pc_add4;
			EX_pc <= ID_pc;
			EX_funct3 <= ID_funct3;
			EX_funct7 <= ID_funct7;
			EX_reg_data1 <= reg_data1; 
			EX_reg_data2 <= reg_data2;
			EX_imm <= ID_imm;    
			EX_rd <= ID_rd;
			//EX_inst <= ID_inst;
		end
	end
end

/**************************EX*************************/
assign branch_enable1 = (EX_branch_type2) ? (!ALU_zero) : ALU_zero;
assign branch_enable = EX_branch & branch_enable1;

always_comb begin
  if(branch_enable | EX_JALR | EX_jump) begin
	  flush = 1'd1;
  end else begin 
	  flush = 1'd0;
  end 
end

always_ff @ (posedge clk , posedge rst)begin //let ID_inst = ID_pc
	if(rst) begin 
		flush_delay <= 1'd0;
	end else begin 
		flush_delay <= (flush) ? flush : 1'd0;
	end
end 

forward forward1(   
	.EX_rs1			(EX_rs1),
	.EX_rs2			(EX_rs2),
	.ID_rs1			(ID_rs1),
	.ID_rs2			(ID_rs2),
	.MEM_rd			(MEM_rd),
	.WB_rd			(WB_rd),
	.MEM_RegWrite	(MEM_RegWrite),
	.WB_RegWrite	(WB_RegWrite),

	.forward_A		(forward_A),
	.forward_B		(forward_B),
	.forward_reg1 	(forward_reg1),
	.forward_reg2	(forward_reg2)
);

always_comb begin //ALU_in1 mux (forward)
	case(forward_A)
		2'd0 : ALU_in1 = EX_reg_data1; //superlint : case statement should met operation bits
		2'd1 : ALU_in1 = MEM_forward_alu;
		2'd2 : ALU_in1 = WB_result;
		default : ALU_in1 = 32'd0;
	endcase
end

always_comb begin //ALU_in2 mux1 (forward)
	case(forward_B)
		2'd0 : ALU_in2_1 = EX_reg_data2;
		2'd1 : ALU_in2_1 = MEM_forward_alu;
		2'd2 : ALU_in2_1 = WB_result;
		default : ALU_in2_1 = 32'd0;  
	endcase
end

assign ALU_in2 = (EX_ALUSrc) ? EX_imm : ALU_in2_1; //ALU_in2 mux2 (forward)

ALU alu(
	.ALU_in1		(ALU_in1),
	.ALU_in2		(ALU_in2),
	.aluop          (EX_aluop),
	.EX_pc 			(EX_pc),
	.EX_imm 		(EX_imm),

	.ALU_result		(EX_ALU_result),
	.ALU_pc_add_imm	(ALU_pc_add_imm),
	.ALU_zero		(ALU_zero)
);

/**************************EX/MEM*************************/
always@(posedge clk , posedge rst) begin
	if(rst)begin                                         
		MEM_MemRead <= 1'd0;              
		MEM_MemWrite <= 4'd0;                         
		MEM_RegWrite <= 1'd0;                        
		MEM_resultSel <= 2'd0;            
		MEM_load <= 3'd0;    
		MEM_store <= 3'd0;      	
		MEM_Utype_rd <= 1'd0;		
		MEM_Memforward <= 2'd0;	
  	end else begin                                       
		MEM_MemRead <= EX_MemRead;              
		MEM_MemWrite <= EX_MemWrite;                         
		MEM_RegWrite <= EX_RegWrite;                       
		MEM_resultSel <= EX_resultSel;            
		MEM_load <= EX_load;
        MEM_store <= EX_store;		
		MEM_Utype_rd <= EX_Utype_rd;	
		MEM_Memforward <= EX_Memforward;		
	end
end

//logic [31:0] MEM_inst; //debug
//logic [31:0] MEM_pc;

always@(posedge clk , posedge rst) begin 
	if(rst)begin
		MEM_ALU_result <= 32'd0;
		MEM_pc_add_imm <= 32'd0;
		MEM_pc_add4 <= 32'd0;
		MEM_imm <= 32'd0;
		MEM_reg_data2 <= 32'd0;
		MEM_rd <= 5'd0;
		MEM_pc <= 32'd0;
		MEM_ALU_in2 <= 32'd0;
		//MEM_inst <= 0;
		//MEM_pc <= 0;
  	end else begin
		MEM_ALU_result <= EX_ALU_result;
		MEM_pc_add_imm <= ALU_pc_add_imm;
		MEM_pc_add4 <= EX_pc_add4;
		MEM_imm <= EX_imm;
		MEM_reg_data2 <= EX_reg_data2;
		MEM_rd <= EX_rd;  
		MEM_pc <= EX_pc;
		MEM_ALU_in2 <= ALU_in2_1;
		//MEM_inst <= EX_inst;
		//MEM_pc <= EX_pc;
  end
end

/**************************MEM*************************/
assign MEM_Utype_rd_result = (MEM_Utype_rd) ? MEM_pc_add_imm : MEM_imm;
assign alu_2bit = MEM_ALU_result[1:0];

always_comb begin
	case(MEM_Memforward)
		2'd0 : MEM_forward_alu = MEM_ALU_result;			
		2'd1 : MEM_forward_alu = MEM_Utype_rd_result; 	
		default : MEM_forward_alu = 0;
	endcase
end

always_comb begin 
	case(MEM_store) 
		3'd0 : begin //SW
			store_data = MEM_ALU_in2;
			MEM_store_MemWrite = MEM_MemWrite; //use to debug
		end

		3'd1 : begin //SB
			case(alu_2bit)
				2'b00 : begin 
					store_data = {24'd0 , MEM_ALU_in2[7:0]};
					MEM_store_MemWrite = 4'b1110;
				end

				2'b01 : begin 
					store_data = {16'd0 , MEM_ALU_in2[7:0] , 8'd0};
					MEM_store_MemWrite = 4'b1101;
				end

				2'b10 : begin 
					store_data = {8'd0 , MEM_ALU_in2[7:0] , 16'd0};
					MEM_store_MemWrite = 4'b1011;
				end

				2'b11 : begin 
					store_data = {MEM_ALU_in2[7:0] , 24'd0};
					MEM_store_MemWrite = 4'b0111;
				end

				//full case , default is not required
				
			endcase	
		end

		3'd2 : begin //SH
			case(alu_2bit)
				2'b00 : begin 
					store_data = {16'd0 , MEM_ALU_in2[15:0]};
					MEM_store_MemWrite = 4'b1100;
				end

				2'b01 : begin 
					store_data = {8'd0 , MEM_ALU_in2[15:0] , 8'd0};
					MEM_store_MemWrite = 4'b1001;
				end

				2'b10 : begin 
					store_data = {MEM_ALU_in2[15:0] , 16'd0};
					MEM_store_MemWrite = 4'b0011;
				end

				default : begin 
					store_data = 0;
					MEM_store_MemWrite = 4'b1111;
				end

			endcase
		end

		default : begin 
			store_data = 32'd0;
			MEM_store_MemWrite = 4'd0;
		end

	endcase
end

assign DM_A = MEM_ALU_result[15:2]; //DM
assign DM_DI = store_data;
assign DM_OE = WB_MemRead;
assign DM_CS = 1'd1;
assign DM_WEB = MEM_store_MemWrite; //use to debug

/**************************MEM/WB*************************/
always_ff @ (posedge clk , posedge rst) begin
	if(rst)begin                                                                                               
		WB_resultSel <= 2'd0;             
		WB_RegWrite <= 1'd0;
		WB_MemRead <= 1'd0;
		WB_load <= 3'd0;
  	end else begin      
		WB_resultSel <= MEM_resultSel;            
		WB_RegWrite <= MEM_RegWrite;
		WB_MemRead <= MEM_MemRead;
		WB_load <= MEM_load;
 	end
end

//logic [31:0] WB_inst; //debug
//logic [31:0] WB_pc;

always_ff @ (posedge clk , posedge rst) begin
	if(rst)begin	
		WB_pc_add4 <= 32'd0;
		WB_Utype_rd_result <= 32'd0;
		WB_rd <= 5'd0; 
		WB_ALU_result <= 32'd0;
		//WB_inst <= 0;
		//WB_pc <= 0;
  	end else begin
		WB_pc_add4 <= MEM_pc_add4;          
		WB_Utype_rd_result <= MEM_Utype_rd_result;    
		WB_rd <= MEM_rd; 
		WB_ALU_result <= MEM_ALU_result;	
		//WB_inst <= MEM_inst;
		//WB_pc <= MEM_pc;
  	end
end

/**************************WB*************************/
always_comb begin 
	case(WB_load) 
		3'd0 : MEM_DM_DO = DM_DO; //LW

		3'd1 : begin //LB
			case(alu_2bit)
				2'b00 : MEM_DM_DO = { {24{DM_DO[7]}} ,  DM_DO[7:0]};
				2'b01 : MEM_DM_DO = { {24{DM_DO[15]}} , DM_DO[15:8]};
				2'b10 : MEM_DM_DO = { {24{DM_DO[23]}} , DM_DO[23:16]};
				2'b11 : MEM_DM_DO = { {24{DM_DO[31]}} , DM_DO[31:24]};
			endcase
		end

		3'd2 : begin //LH
			case(alu_2bit)
				2'b00 : MEM_DM_DO = { {16{DM_DO[15]}} , DM_DO[15:0]};
				2'b01 : MEM_DM_DO = { {16{DM_DO[23]}} , DM_DO[23:8]};
				2'b10 : MEM_DM_DO = { {16{DM_DO[31]}} , DM_DO[31:16]};
				2'b11 : MEM_DM_DO = 0;
			endcase
		end 

		3'd3 : begin //LBU
			case(alu_2bit)
				2'b00 : MEM_DM_DO = { 24'd0 , DM_DO[7 :0]};
				2'b01 : MEM_DM_DO = { 24'd0 , DM_DO[15:8]};
				2'b10 : MEM_DM_DO = { 24'd0 , DM_DO[23:16]};
				2'b11 : MEM_DM_DO = { 24'd0 , DM_DO[31:24]};
			endcase
		end 

		3'd4 : begin //LHU
			case(alu_2bit)
				2'b00 : MEM_DM_DO = { 16'd0 , DM_DO[15:0]};
				2'b01 : MEM_DM_DO = { 16'd0 , DM_DO[23:8]};
				2'b10 : MEM_DM_DO = { 16'd0 , DM_DO[31:16]};
				2'b11 : MEM_DM_DO = 0;
			endcase
		end

		default : MEM_DM_DO = 0;
	endcase
end

always_comb begin 
	case(WB_resultSel)
		2'd0 : WB_result = WB_ALU_result;
		2'd1 : WB_result = MEM_DM_DO;
		2'd2 : WB_result = WB_pc_add4;
		2'd3 : WB_result = WB_Utype_rd_result;
		//full case , default is not required
  	endcase
end

endmodule


