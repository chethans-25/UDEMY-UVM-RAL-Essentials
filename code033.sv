//Implementation of memory models

class dut_mem1 extends uvm_mem;
 
`uvm_object_utils(dut_mem1)
 
function new(string name = "dut_mem1");
  super.new(name, 16, 8, "RW", UVM_NO_COVERAGE);// name, number of elements, size of each element, access type, coverage
endfunction

endclass
 
///////////////////////////////////////////////////////////
 
class dut_mem2 extends uvm_mem;
 
`uvm_object_utils(dut_mem2)
 
function new(string name = "dut_mem2");
  super.new(name, 1024, 16, "RW", UVM_NO_COVERAGE);
endfunction
 
endclass
 
///////////////////////////////////////////////////////////
 
 
class dut_mem3 extends uvm_mem;
 
`uvm_object_utils(dut_mem3)
 
function new(string name = "dut_mem3");
  super.new(name, 2048, 32, "RW", UVM_NO_COVERAGE);
endfunction
 
endclass