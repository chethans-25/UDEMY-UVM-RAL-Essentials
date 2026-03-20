/*
Implement a 24-bit register in a verification environment whose structure is mentioned in the Instruction tab. refer img_a11.png for the register structure.
*/

`include "uvm_macros.svh"
import uvm_pkg::*;

class reg_a11 extends uvm_reg;
  `uvm_object_utils(reg_a11)

  // field declaration
  rand uvm_reg_field ctrl;
  rand uvm_reg_field addr;
  rand uvm_reg_field data;
  
  // constructor
  function new(string name = "reg_a11");
    super.new(name, 24, UVM_NO_COVERAGE); // name, size, coverage
    //here size is total number of bits in the register, not the field
  endfunction
  
  // build function to create fields
  function void build();
    ctrl = uvm_reg_field::type_id::create("ctrl");
    addr = uvm_reg_field::type_id::create("addr");
    data = uvm_reg_field::type_id::create("data");

    //configure fields as per the register structure mentioned in img_a11.png
    ctrl.configure(this, 6, 0, "RW", 0, 0, 1, 1, 1);
    addr.configure(this, 6, 6, "RW", 0, 0, 1, 1, 1);
    data.configure(this, 8, 12, "RW", 0, 0, 1, 1, 1);
    
  endfunction


endclass

module top;
  reg_a11 r1;
  initial begin
    r1 = reg_a11::type_id::create("r1"); //or use new() method to create object
    r1.build();
  end
endmodule