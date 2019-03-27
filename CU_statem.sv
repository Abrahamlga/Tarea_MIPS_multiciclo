// Control unit state machine
// Jesus Abraham Lizarraga Banuelos
// Mar-22-2018
// CU_statem.sv
//

timeunit 1ns;
timeprecision 100ps;

module CU_statem
#(
    parameter BIT_WIDTH=32,
    parameter BIT_SEL=3,
    parameter BIT_CTRL=6
)
(
 input logic clk, rst,
 input logic [BIT_CTRL-1:0] Op,Funct,
 output logic [BIT_WIDTH-1:0] Branch, PCWrite,
 output logic RegWrite,
 output logic MemWrite,
 output logic IorD,
 output logic PCSrc,
 output logic [1:0] ALUSrcA,
 output logic [1:0] ALUSrcB,
 output logic MemtoReg,
 output logic RegDst,
 output logic IRWrite,
 output logic [BIT_SEL:0] ALUControl
);

localparam I_FETCH=4'd0,I_DECODE= 4'd1,
	   EXE_LUI= 4'd2,WRITE_BACK= 4'd3,
           EXE_ORI= 4'd4, WRITE_SW= 4'd5,
           EXE_ADDI= 4'd6, EXE_SLL= 4'd7,
	   EXE_SW= 4'd8, EXE_BNE= 4'd9,
	   EXE_BNE1= 4'd10, EXE_BNE2= 4'd11;

logic [3:0] state, nstate;
logic flag_state;
logic f_Op_or_Funct;

assign f_Op_or_Funct=|Op; //if 1 =Op, 0=Funct

always_comb
begin
 case (state)
  I_FETCH: nstate = flag_state? I_DECODE: I_FETCH;
  EXE_LUI: nstate = flag_state? WRITE_BACK: EXE_LUI;
  EXE_ORI: nstate = flag_state? WRITE_BACK: EXE_ORI;
  EXE_ADDI: nstate = flag_state? WRITE_BACK: EXE_ADDI;
  EXE_SW: nstate = flag_state? WRITE_SW: EXE_SW;
  EXE_SLL: nstate = flag_state? WRITE_BACK: EXE_SLL;
  EXE_BNE: nstate = flag_state? EXE_BNE1: EXE_BNE;
  EXE_BNE1: nstate = flag_state? EXE_BNE2: EXE_BNE1;
  EXE_BNE2: nstate = flag_state? I_FETCH: EXE_BNE2;
  WRITE_SW: nstate = flag_state? I_FETCH: WRITE_SW;

  WRITE_BACK: nstate = flag_state? I_FETCH: WRITE_BACK;
  I_DECODE: begin 
   if(flag_state & f_Op_or_Funct) begin //Op 
    case(Op)
     5: nstate= EXE_BNE; //BNE
     8: nstate= EXE_ADDI; //ADDI
     13: nstate= EXE_ORI; //ORI
     15: nstate= EXE_LUI; //LUI
     43: nstate= EXE_SW; //SW
     default : nstate= EXE_ADDI;
    endcase
   end  else if(flag_state | ~f_Op_or_Funct) begin // Funct
    case (Funct)
     0: nstate= EXE_SLL; //SLL
     default : nstate= EXE_SLL;
    endcase// Funct
   end //else if
   else begin
    nstate = I_DECODE;
   end //else
  end // case I_DECODE
 endcase //state
end

always_ff @(posedge clk, negedge rst)
begin
 if (!rst)
  begin
    state<= I_FETCH;
  end
  else
  begin
   state<=nstate;
  end 
end

always_comb
begin
 flag_state=0;
 Branch=1'b0; 
 PCWrite=1'b0;
 RegWrite=1'b0;
 MemWrite=1'b0;
 IorD=1'b0;
 PCSrc=1'b0; //0
 ALUSrcA=2'd0;
 ALUSrcB=2'd0;
 ALUControl= 4'd0;
 MemtoReg=1'b0; 
 RegDst=1'b0; 
 IRWrite=1'b0;

 case (state)
  I_FETCH: begin
   Branch=1'b0; 
   PCWrite=1'b1;
   RegWrite=1'b0;
   MemWrite=1'b0;
   IorD=1'b0;
   PCSrc=1'b0; //0
   ALUSrcA=2'd0;
   ALUSrcB=2'd1;
   ALUControl= 4'd0;
//   MemtoReg=1'b0; //no need to modify
//   RegDst=1'b0; // no need to modify
   IRWrite=1'b1;
   flag_state=1'b1;
  end //I_FETCH case

  I_DECODE: begin
   Branch=1'b0; 
   PCWrite=1'b0;
   RegWrite=1'b0;
   MemWrite=1'b0;
//   IorD=1'b0;
//   PCSrc=1'b0;
//   ALUSrcA=2'd0;
//   ALUSrcB=2'd0;
//   MemtoReg=1'b0; //no need to modify
//   RegDst=1'b0; // no need to modify
   IRWrite=1'b0;
   flag_state=1'b1;
  end //  case I_DECODE
  
   //// This instruction works for lui
  EXE_LUI: begin
   ALUSrcA=2'd1;
   ALUSrcB=2'd2;
   ALUControl= 4'd14;
   flag_state=1'b1;
  end // case EXE_LUI

   //// This instruction works for ori
  EXE_ORI: begin
   ALUSrcA=2'd1;
   ALUSrcB=2'd2;
   ALUControl= 4'd3;
   flag_state=1'b1;
  end // case EXE_ORI

   //// This instruction works for ADDI
  EXE_ADDI: begin
   ALUSrcA=2'd1;
   ALUSrcB=2'd2;
   ALUControl= 4'd0;
   flag_state=1'b1;
  end // case EXE_ADDI

   //// This instruction works for SW
  EXE_SW: begin
   ALUSrcA=2'd1;
   ALUSrcB=2'd0;
   ALUControl= 4'd13;
   flag_state=1'b1;
  end // case EXE_SW

   //// This instruction works for SLL
  EXE_SLL: begin
   ALUSrcA=2'd2;
   ALUSrcB=2'd0;
   ALUControl= 4'd5;
   flag_state=1'b1;
  end // case EXE_SLL

  EXE_BNE: begin
   Branch=1'b0; 
   PCWrite=1'b0;
   RegWrite=1'b0;
   MemWrite=1'b0;
   ALUSrcB=2'd3;
   IRWrite=1'b0;
   flag_state=1'b1;
  end //  case EXE_BNE

  EXE_BNE1: begin
   Branch=1'b1;
   PCSrc=1'b1;
   ALUSrcA=2'd1;
   ALUSrcB=2'd0;
   ALUControl= 4'd11;
   flag_state=1'b1;
  end // case EXE_BNE1

  EXE_BNE2: begin
   Branch=1'b0;
   ALUSrcA=2'd0;
   ALUSrcB=2'd3;
   ALUControl= 4'd0;
   flag_state=1'b1;
  end // case EXE_BNE2

 //// This instruction works for SW
  WRITE_SW: begin
   RegWrite=1'b0;
   MemWrite=1'b1;
   IorD=1'b1;
   flag_state=1'b1;
  end // case WRITE_SW


  WRITE_BACK: begin
//   Branch=1'b0; 
//   PCWrite=1'b0;
   RegWrite=1'b1;
//   MemWrite=1'b0;
//   IorD=1'b0;
//   PCSrc=1'b0;
//   ALUSrcA=2'd1;
//   ALUSrcB=2'd2;
   MemtoReg=1'b0;
   RegDst=~|Op ; //I = 0 , R = 1
//   IRWrite=1'b0;
   flag_state=1'b1;
   end // case WRITE_BACK


  endcase
 end //always

endmodule

