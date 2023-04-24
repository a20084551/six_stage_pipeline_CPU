module controller(
	input [2:0] funct3,
	input [6:0] funct7,
	input [6:0] opcode,
	
	output logic RegWrite,ALUSrc,MemRead,branch,jump,JALR,branch_type2,Utype_rd,
	output logic [2:0] store,load,
	output logic [3:0] MemWrite,
	output logic [1:0] Memforward,
	output logic [1:0] resultSel,
	output logic [6:0] aluop
);
	
always_comb begin
    case(opcode)
		7'b0110011: begin //R-type
			jump = 1'd0;               
			branch = 1'd0;              
			JALR = 1'd0;        

			MemRead = 1'd0;              
			MemWrite = 4'b1111;        
			ALUSrc = 1'd0;               
			RegWrite = 1'd1;  

			Memforward = 2'd0;   

			resultSel = 2'd0;      

			load = 3'd0;   
			store = 3'd0;

			Utype_rd = 1'd0;   

			branch_type2 = 1'd0;          
			
			case(funct3) 
                3'b000 : aluop = (funct7 == 7'b0000000) ? 7'd1 : 7'd2;    	//ADD=1;SUB=2
                3'b001 : aluop = 7'd3;                                 		//SLL=3
                3'b010 : aluop = 7'd4;                                 		//SLT=4
                3'b011 : aluop = 7'd5;                                 		//SLTU=5
                3'b100 : aluop = 7'd6;                                 		//XOR=6
                3'b101 : aluop = (funct7 == 7'b0000000) ? 7'd7 : 7'd8;    	//SRL=7;SRA=8
                3'b110 : aluop = 7'd9;                                 		//OR=9  
                3'b111 : aluop = 7'd10;                                		//AND=10
                	//full case , default is not required
            endcase

	  end

	  	7'b0010011: begin //I-type : general (without LW load JALR)
			jump = 1'd0;                 
			branch = 1'd0;              
			JALR = 1'd0;     

			MemRead = 1'd0;             
			MemWrite = 4'b1111;          
			ALUSrc = 1'd1;             
			RegWrite = 1'd1;   

			Memforward = 2'd0;

			resultSel = 2'd0;    

			load = 3'd0;  
			store = 3'd0;    

			Utype_rd = 1'd0;   

			branch_type2 = 1'd0;        
			
			case(funct3) 
				3'b000 : aluop = 7'd1; //ADDI=1
				3'b010 : aluop = 7'd4; //SLTI=3
				3'b011 : aluop = 7'd5; //SLTIU=5
				3'b100 : aluop = 7'd6; //XORI=6
				3'b110 : aluop = 7'd9; //ORI=9
				3'b111 : aluop = 7'd10;//ANDI=10
				3'b001 : aluop = 7'd3; //SLLI=3
				3'b101 : aluop = (funct7 == 7'b0000000) ? 7'd7 : 7'd8; //SRLI=7;SRAI=8
				//full case , default is not required
			endcase
		end

		7'b0000011: begin //LW(I-type)
			jump = 1'd0;                  
			branch = 1'd0;                
			JALR = 1'd0;                  

			MemRead = 1'd1;               
			MemWrite = 4'b1111;         	
			ALUSrc = 1'd1;                
			RegWrite = 1'd1;      

			Memforward = 2'd2;        
             	
			resultSel = 2'd1;                

			store = 3'd0;	

			case(funct3) 
				3'b010 : load = 3'd0; //LW
				3'b000 : load = 3'd1; //load
				3'b001 : load = 3'd2; //LH
				3'b100 : load = 3'd3; //LHU
				3'b101 : load = 3'd4; //loadU
				default : load = 3'd0;
			endcase

			Utype_rd = 1'd0;            
			branch_type2 = 1'd0;            	
			
			aluop = 7'd1;	
		end

		7'b1100111: begin //JALR (I-type)
			jump = 1'd0;                 
			branch = 1'd0;               
			JALR = 1'd1;                
			
			MemRead = 1'd0;               
			MemWrite = 4'b1111;         
			ALUSrc = 1'd1;               
			RegWrite = 1'd1;     

			Memforward = 2'd2;                     
			
			resultSel = 2'd2;     

			load = 3'd0;    
			store = 3'd0;      

			Utype_rd = 1'd0;   

			branch_type2 = 1'd0;         
		
			aluop = 7'd1;
		end	

		7'b0100011: begin //S-type
			jump = 1'd0;               
			branch = 1'd0;               
			JALR = 1'd0;    

			MemRead = 1'd0;               				
			MemWrite = 4'b0000; 
			ALUSrc = 1'd1;                
			RegWrite = 1'd0;     

			Memforward = 2'd0;  

			resultSel = 2'd0;     

			load = 3'd0;  

			case(funct3) 
				3'b010 : store = 3'd0; //SW
				3'b000 : store = 3'd1; //store
				3'b001 : store = 3'd2; //SH
				default : store = 3'd0;
			endcase

			Utype_rd = 1'd0;     

			branch_type2 = 1'd0;           	

			aluop = 7'd1;

		end

		7'b1100011: begin //B-type
			jump = 1'd0;                 
			branch = 1'd1;              
			JALR = 1'd0;                 

			MemRead = 1'd0;               
			MemWrite = 4'b1111;         
			ALUSrc = 1'd0;                
			RegWrite = 1'd0; 

			Memforward = 2'd0;

			resultSel = 2'd0;   

			load = 3'd0;   
			store = 3'd0;    

			Utype_rd = 1'd0;           

			case(funct3)
				3'b000 : branch_type2 = 1'd1; //BEQ
				3'b001 : branch_type2 = 1'd0; //BNE
				3'b100 : branch_type2 = 1'd1; //BLT
				3'b101 : branch_type2 = 1'd0; //BGE
				3'b110 : branch_type2 = 1'd1;	//BLTU
				3'b111 : branch_type2 = 1'd0; //BGEU
				default : branch_type2 = 1'd1; //None
			endcase	

			case (funct3)
				3'b000 : aluop = 7'd11;
				3'b001 : aluop = 7'd11;
				3'b100 : aluop = 7'd4;
				3'b101 : aluop = 7'd4;
				3'b110 : aluop = 7'd5;
				3'b111 : aluop = 7'd5;
				default :  aluop = 7'd0;
			endcase

		end

		7'b0010111: begin //AUIpc (U-type)
			jump = 1'd0;                  
			branch = 1'd0;                
			JALR = 1'd0;                 
			
			MemRead = 1'd0;              
			MemWrite = 4'b1111;          
			ALUSrc = 1'd0;              
			RegWrite = 1'd1;     

			Memforward = 2'd1;                      	
			
			resultSel = 2'd3;    

			load = 3'd0;  
			store = 3'd0;   

			Utype_rd = 1'd1;  

			branch_type2 = 1'd0;           
			
			aluop = 7'd0;
		end

		7'b0110111: begin //LUI (U-type)
			jump = 1'd0;                 
			branch = 1'd0;               
			JALR = 1'd0;                 

			MemRead = 1'd0;              
			MemWrite = 4'b1111;           
			ALUSrc = 1'd0;               
			RegWrite = 1'd1;       

			Memforward = 2'd1;                  	

			resultSel = 2'd3;               
			
			load = 3'd0;                
			store = 3'd0;

			Utype_rd = 1'd0;   

			branch_type2 = 1'd0;            

			aluop = 7'd0;
		end
	   
		7'b1101111: begin //J-type
			jump = 1'd1;                 
			branch = 1'd0;              
			JALR = 1'd0;                 

			MemRead = 1'd0;              
			MemWrite = 4'b1111;           
			ALUSrc = 1'd0;               
			RegWrite = 1'd1;       

			Memforward = 2'd2;                    

			resultSel = 2'd2;               
			
			load = 3'd0;                	
			store = 3'd0;

			Utype_rd = 1'd1;    

			branch_type2 = 1'd0;           

			aluop = 7'd0;
		end	  

		default: begin //None
			jump = 1'd0;                  
			branch = 1'd0;                
			JALR = 1'd0;                  

			MemRead = 1'd0;              
			MemWrite = 4'b1111;           
			ALUSrc = 1'd0;              
			RegWrite = 1'd0;  

			Memforward = 2'd0;

			resultSel = 2'd0;  

			load = 3'd0;
			store = 3'd0;

			Utype_rd = 1'd0; 

			branch_type2 = 1'd0;          
			
			aluop = 7'd0;
		end

	endcase
end
  
endmodule  
