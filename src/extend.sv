module extend(
  input [31:0] inst,
  input [6: 0] opcode,

  output logic [31:0] ID_imm
);

always_comb begin
    case(opcode)
        7'b0010011 : ID_imm = {{20{inst[31]}} , inst[31:20]};                                 //I-type : general
        7'b0000011 : ID_imm = {{20{inst[31]}} , inst[31:20]};                                 //I-type : load type
        7'b1100111 : ID_imm = {{20{inst[31]}} , inst[31:20]};                                 //I-type : JALR
        7'b0100011 : ID_imm = {{20{inst[31]}} , inst[31:25] , inst[11:7]};                    //S-type 
        7'b1100011 : ID_imm = {{20{inst[31]}} , inst[7] , inst[30:25] , inst[11:8] , 1'b0};   //B-type
        7'b0010111 : ID_imm = {inst[31:12] , {12{1'b0}}};                                     //U-type : AUIPC
        7'b0110111 : ID_imm = {inst[31:12] , {12{1'b0}}};                                     //U-type : LUI
        7'b1101111 : ID_imm = {{12{inst[31]}} , inst[19:12] , inst[20] , inst[30:21] , 1'b0}; //J-type
        default : ID_imm = 32'd0;
    endcase
end

endmodule