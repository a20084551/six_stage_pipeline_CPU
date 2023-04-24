module ALU(
  input [31:0] ALU_in1,ALU_in2,
  input [31:0] EX_pc,EX_imm, 
  input [6 :0] aluop,
 
  output logic [31:0] ALU_result,
  output logic [31:0] ALU_pc_add_imm,
  output logic ALU_zero
);
assign ALU_pc_add_imm = EX_pc + EX_imm; 

always_comb begin
    case(aluop)
        7'd1 : ALU_result = ALU_in1 + ALU_in2; //ADD
        7'd2 : ALU_result = ALU_in1 - ALU_in2; //SUB
        7'd3 : ALU_result = ALU_in1 << ALU_in2[4:0]; //SLL 

        7'd4 : begin //SLT
            if( $signed(ALU_in1) < $signed(ALU_in2) ) begin 
              ALU_result = 32'd1;
            end else begin 
              ALU_result = 32'd0;
            end  
        end              	

        7'd5 : begin //SLTU
            if(ALU_in1 < ALU_in2) begin 
              ALU_result = 32'd1;
            end else begin 
              ALU_result = 32'd0;
            end
        end   

        7'd6 : ALU_result = ALU_in1 ^ ALU_in2;                 //XOR
        7'd7 : ALU_result = ALU_in1 >> ALU_in2[4:0];           //SRL
        7'd8 : ALU_result = $signed(ALU_in1) >>> ALU_in2[4:0]; //SRA	  
        7'd9 : ALU_result = ALU_in1 | ALU_in2;                 //OR
        7'd10 : ALU_result = ALU_in1 & ALU_in2;                //AND  

        7'd11 : begin //BEQ 
            if(ALU_in1 == ALU_in2) begin 
              ALU_result = 32'd1;
            end else begin 
              ALU_result = 32'd0;
            end
        end

        default : ALU_result = 32'd0;      
    endcase
  end
    
always_comb begin
    if(ALU_result == 0) begin
      ALU_zero = 1'd1;
    end else begin
      ALU_zero = 1'd0;
    end
end  
    
    
    
    
    
    
    
    
    
    
    
    
    
    
endmodule
