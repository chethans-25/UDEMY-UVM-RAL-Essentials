// Implement a 64 x 32 RAM memory in Verification environment whose structure is mentioned in the Instruction tab.
`include "uvm_macros.svh"
import uvm_pkg::*;

class mem1 extends uvm_mem;
 
`uvm_object_utils(mem1)
 
function new(string name = "mem1");
  // RAM should have RW access.
  super.new(name, 64, 32, "RW", UVM_NO_COVERAGE);// name, number of elements, size of each element, access type, coverage
endfunction

endclass
 
module top;
  mem1 m1;
  initial begin
    m1 = mem1::type_id::create("m1"); //or use new() method to create object
  end
endmodule