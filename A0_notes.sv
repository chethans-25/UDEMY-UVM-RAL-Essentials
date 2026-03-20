********************Section 1: Adding Register and Memory to Verification Environment********************
/*
minimum requirements for including RAL
  
  1) atlest single register/ memory exist in DUT
  2) register have atleast single field
  3) registers should have address
 
*/
 
// adaptor converts Register transaction to Bus transaction and vice versa

// register blocks will have a base class //refer img_012.png

// Different types of registers //refer img_014.png

// registers are built using uvm_reg base class
`include "uvm_macros.svh"
import uvm_pkg::*;

class reg0 extends uvm_reg;
  `uvm_object_utils(reg0)

  // field declaration
  rand uvm_reg_field slv_reg0;
  
  // constructor
  function new(string name = "reg0");
    super.new(name, 32, UVM_NO_COVERAGE); // name, size, coverage
    //here size is total number of bits in the register, not the field
  endfunction
  
  // build function to create fields
  function void build();
    slv_reg0 = uvm_reg_field::type_id::create("slv_reg0", this);

    //registers need to be configured to specify the field position, access type, volatile etc
    slv_reg0.configure(
      this, // parent register
      0,    // lsb_pos
      32,   // size of this field, in bits
      "RW", // access type, RW means read/write
      0,    // volatile
      0,     // reset value
      1,     // has reset, 1 means this field has reset value
      1,     // is rand, 1 means this field will be randomized
      1      // individually accessible, 1 means this field can be accessed individually
    );
  endfunction
endclass

module tb;
    reg0 r1;
    initial begin
        r1 = reg0::type_id::create("r1"); //or use new() method to create object
        r1.build();
    end
endmodule



// Access policies
RW: read/write
RO: read only
WO: write only
RC: read clear, means when you read this field, it will clear the value to 0
RW1C: read/write 1 to clear, means when you write 1 to this field, it will clear the value to 0, but when you write 0, it will not change the value

// refer internet for further details

//Adding Memory

class dut_mem1 extends uvm_mem;
  `uvm_object_utils(dut_mem1)
  function new(string name = "dut_mem1");
    super.new(name, 1024, 8, UVM_NO_COVERAGE); // name, number of elements, size of each element, coverage
  endfunction //new()
  
endclass //dut_mem1 extends uvm_mem
