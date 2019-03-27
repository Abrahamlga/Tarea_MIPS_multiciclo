// Top module, includes GPIO block and MIPS_arch
// Jesus Abraham Lizarraga Banuelos
// Mar-24-2018
// Top_module.sv
//


timeunit 1ns;
timeprecision 100ps;

module Top_module
#(
   parameter BIT_WIDTH=32,
   parameter REG_WIDTH = $clog2(BIT_WIDTH),
   parameter BIT_SEL=3,
   parameter BIT_CTRL=5
)
(
  input logic clk, rst,
   output logic [7:0] GPIO_PORT_OUT
);

logic clk_1HZ;
logic  [BIT_WIDTH-1:0] Data, Address;
MIPS_arch MIPS_arch1
(
 .clk(clk_1HZ),
 .rst(rst),
 .DFT_data(Data),
 .DFT_Address_in(Address)
);

GPIO GPIO1
(
 .rst(rst),
 .clk(clk),
 .Data(Data),
 .Address(Address),
 .GPIO_PORT_OUT(GPIO_PORT_OUT)
);

Clock_divider Clock_divider1
(
 .clock_in(clk),
 .clock_out(clk_1HZ)
);


endmodule
