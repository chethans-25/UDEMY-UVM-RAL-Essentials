// Implementation of register with single field

`include "uvm_macros.svh"
  import uvm_pkg::*;
 
class reg0 extends uvm_reg;
  
  `uvm_object_utils(reg0)

  rand uvm_reg_field slv_reg0;
 
  function new (string name = "reg0");
    super.new(name,32,UVM_NO_COVERAGE); 
  endfunction
 
  function void build; 
 
    slv_reg0 = uvm_reg_field::type_id::create("slv_reg0");   
    
    
    slv_reg0.configure(  .parent(this), 
                         .size(32), 
                         .lsb_pos(0), 
                         .access("RW"),  
                         .volatile(0), 
                         .reset('h0), 
                         .has_reset(1), 
                         .is_rand(1), 
                         .individually_accessible(1)); 
    
   // slv_reg0.configure(this, 32,       0,   "RW",   0,        0,        1,        1,      1); 
    //                  reg, bitwidth, lsb, access, volatile, reselVal, hasReset, isRand, fieldAccess
    
  endfunction
  
  
endclass
 
 
////////////////////////////////
 
 
module tb;
  
 reg0 r1;
  
  initial begin 
    r1 = new("r1");
    r1.build();
  end
  
endmodule