// File to generate register file
// Jesus Abraham Lizarraga Banuelos
// Jan-10-2018
// register_file.sv
//
module register_file
#(
    parameter BIT_WIDTH=32,
    parameter REG_WIDTH = $clog2(BIT_WIDTH)
)
(
 output logic [BIT_WIDTH-1:0] Read_Data_1, Read_Data_2,		
 input logic  [BIT_WIDTH-1:0] Write_Data,
 input logic [REG_WIDTH-1:0] Write_reg,Read_reg1,Read_reg2,
 input logic write,clk,rst
);

timeunit 1ns;
timeprecision 100ps;

//logic
logic [BIT_WIDTH-1:0] [BIT_WIDTH-1:0] register;

always_comb
begin
 Read_Data_1= register[Read_reg1];
 Read_Data_2= register[Read_reg2];
end

always_ff @(posedge clk, negedge rst)
begin
 if (!rst)
  begin
    register=0;
  end
  else
  begin
    if(write)
    begin // write
     register[Write_reg]<= Write_Data;
    end
  end 
end //always

endmodule
