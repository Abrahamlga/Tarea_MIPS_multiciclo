// Memory ROM, created by MARS.jar
// Jesus Abraham Lizarraga Banuelos
// March-09-2018
// memory_rom.sv
//

timeunit 1ns;
timeprecision 100ps;

module memory_rom
#(
    parameter BIT_WIDTH=32
)
(
 output logic [BIT_WIDTH-1:0] Read_Data_out,
 input logic  [BIT_WIDTH-1:0] Address_in
);

 logic [BIT_WIDTH-1:0] reg_mem [0:BIT_WIDTH-1] ;

always_comb
 begin
  Read_Data_out=reg_mem[Address_in];
  $readmemh("Multicycle_MIPS1.mem", reg_mem);
 end
endmodule
