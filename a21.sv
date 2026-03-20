// Implement register block in the verification environment for the DUT, 
// which consists of two 24-bit registers whose structure is mentioned in Instruction tab.

`include "uvm_macros.svh"
  import uvm_pkg::*;

class slv_reg0 extends uvm_reg;
  `uvm_object_utils(slv_reg0)
   
 
  rand uvm_reg_field ctrl;
  rand uvm_reg_field addr;
  rand uvm_reg_field data;
 
  
  function new (string name = "slv_reg0");
    super.new(name,24,UVM_NO_COVERAGE); 
  endfunction
 
 
  
  function void build; 
    
 
    ctrl = uvm_reg_field::type_id::create("ctrl");   
    ctrl.configure(this, 6, 0, "RW", 0, 0, 1, 1, 1);

    addr = uvm_reg_field::type_id::create("addr");   
    addr.configure(this, 6, 6, "RW", 0, 0, 1, 1, 1);

    data = uvm_reg_field::type_id::create("data");   
    data.configure(this, 8, 12, "RW", 0, 0, 1, 1, 1);
 
  endfunction
endclass
 
 
///////////////////////////////////////////////////////
class slv_reg1 extends uvm_reg;
  `uvm_object_utils(slv_reg1)
   
 
  rand uvm_reg_field addr;
  rand uvm_reg_field data;
 
  
  function new (string name = "slv_reg1");
    super.new(name,24,UVM_NO_COVERAGE); 
  endfunction
 
 
  
  function void build; 
    
    addr = uvm_reg_field::type_id::create("addr");   
    addr.configure(this, 12, 0, "RW", 0, 0, 1, 1, 1);

    data = uvm_reg_field::type_id::create("data");   
    data.configure(this, 12, 12, "RW", 0, 0, 1, 1, 1);
 
  endfunction
endclass
 
 
 
////////////////////////////////////////////////////////////
 
 
class top_reg_block extends uvm_reg_block;
  `uvm_object_utils(top_reg_block)

  rand slv_reg0  	slv_reg0_inst;
  rand slv_reg1  	slv_reg1_inst;
 
  function new (string name = "top_reg_block");
    super.new(name, UVM_NO_COVERAGE);
  endfunction
 
 
  function void build;
    slv_reg0_inst = slv_reg0::type_id::create("slv_reg0_inst"); // create register object and pass parent block as argument
    slv_reg0_inst.build(); // call build function to create fields
    slv_reg0_inst.configure(this); // configure register to specify parent block

    slv_reg1_inst = slv_reg1::type_id::create("slv_reg1_inst"); // create register object and pass parent block as argument
    slv_reg1_inst.build(); // call build function to create fields
    slv_reg1_inst.configure(this); // configure register to specify parent block

    //create address map for the block
    default_map = create_map("default_map", 0, 4, UVM_LITTLE_ENDIAN); // name, base address, address step, endianness

    //start adding registers to address map
    default_map.add_reg(slv_reg0_inst, 0, "RW"); // register instance, offset address, access policy
    default_map.add_reg(slv_reg1_inst, 4, "RW"); // register instance, offset address, access policy
    
    //lock model after creating address map and adding registers to it, this will prevent any further changes to the model
    lock_model();
    
    
  endfunction
endclass


module top;
  
  top_reg_block reg_blk;
  
  initial begin
    reg_blk = top_reg_block::type_id::create("reg_blk");
    reg_blk.build();
  end

endmodule