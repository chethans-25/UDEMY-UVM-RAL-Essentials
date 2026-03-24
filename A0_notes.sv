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
    slv_reg0 = uvm_reg_field::type_id::create("slv_reg0");

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



********************Section 2: Adding Register Blocks********************

// Refer img_040.png

Reg block will be exteded from uvm_reg_block base class

class reg_block0 extends uvm_reg_block;
  `uvm_object_utils(reg_block0)

  // register declaration
  rand reg1 reg1_instance; // register object declaration, this will be used to create register object in build function
  rand reg2 reg2_instance; // register object declaration, this will be used to create register object in build function

  function new(string name = "reg_block0");
    super.new(name, UVM_NO_COVERAGE);
  endfunction
  
  function void build();
    reg1_instance = reg1::type_id::create("reg1_instance"); // create register object 
    reg1_instance.build(); // call build function to create fields
    reg1_instance.configure(this); // configure register to specify parent block

    reg2_instance = reg2::type_id::create("reg2_instance"); // create register object 
    reg2_instance.build(); // call build function to create fields
    reg2_instance.configure(this); // configure register to specify parent block


    //create address map
    default_map = create_map("default_map", 0, 4, UVM_LITTLE_ENDIAN); // name, base address, byte width, endianness
    
    //start adding registers to address map
    default_map.add_reg(reg1_instance, `h0, "RW"); //instance name, offset address, access policy
    default_map.add_reg(reg2_instance, `h4, "RW"); 

    lock_model(); // lock the model to prevent further modifications, this is optional but recommended to avoid accidental changes
  endfunction
endclass



********************Section 3: Understanding Adapters********************

Converts register transaction to bus transaction and vice versa

// Usage of Adapter

// refer img_042.png
reg sequence majorly have two methods:
write(status, data);
read(status, variable_to_store_data);

//Typical flow
1) call reg methods //read or write
2) update struct //uvm_reg_bus_op struct will be updated with address, data, byte enable etc
3) call adapter method to convert reg transaction to bus transaction //reg2bus or bus2reg method will be called based on the transaction type
4) Update transaction //adapter will update the transaction with bus specific details like address, data, byte enable etc
5) call driver method to send transaction to DUT
6) Monitor will capture the bus transaction and call adapter/predictor method to convert bus transaction to reg transaction
7) Update Mirror + Desired value //adapter will update the mirror and desired value based on the bus transaction


//reg2bus
regmodel.temp_reg_inst.write(status, 'h4); // call reg method to write data to register
//address is not specified in the write method, it will be updated by the adapter based on the register address map

//structure of uvm_reg_bus_op
kind: UVM_WRITE(write)
addr: address of the register from address map
data: value to be written to the register //'h4 in this case
status: status of the transaction, it will be updated by the reg method based on the success or failure of the transaction //OK, FAIL, etc


reg2bus converts reg transaction to bus transaction

function uvm_sequence_item reg2bus(uvm_reg_bus_op reg_op);
  // create bus transaction
  transaction apb_bus_tr;
  apb_bus_tr = transaction::type_id::create("apb_bus_tr");
  
  // update bus transaction with reg transaction details
  apb_bus_tr.wr = (reg_op.kind == UVM_WRITE); // update transaction type (read/write) from reg transaction
  apb_bus_tr.addr = reg_op.addr; // update address from reg transaction
  if(apb_bus_tr.wr == 'b1) apb_bus_tr.din = reg_op.data; // update data from reg transaction
  if(apb_bus_tr.wr == 'b1) apb_bus_tr.dout = reg_op.data; // update data from reg transaction
  
  return apb_bus_tr; // return the bus transaction
endfunction


//bus2reg
function void bus2reg(uvm_seq_item bus_item, ref uvm_reg_bus_op reg_op);
  transaction apb_bus_tr;

  assert($cast(apb_bus_tr, bus_item)); // cast the bus item to bus transaction, this is optional but recommended to ensure that the bus item is of correct type

  // update reg transaction with bus transaction details
  reg_op.kind = bus_item.wr ? UVM_WRITE : UVM_READ; // update transaction type (read/write) from bus transaction
  reg_op.data = bus_item.data; // update data from bus transaction
  reg_op.addr = bus_item.addr; // update address from bus transaction
  reg_op.status = UVM_IS_OK; // update status of the transaction, this is optional but recommended to indicate the success of the transaction
endfunction




//adapter code with native memory ports
class top_adapter extends uvm_adapter;
  `uvm_object_utils(top_adapter)

  function new(string name = "top_adapter");
    super.new(name);
  endfunction

  function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op reg_op);
    // create bus transaction
    transaction apb_bus_tr;
    apb_bus_tr = transaction::type_id::create("apb_bus_tr");
    
    // update bus transaction with reg transaction details
    apb_bus_tr.wr = (reg_op.kind == UVM_WRITE); // update transaction type (read/write) from reg transaction
    apb_bus_tr.addr = reg_op.addr; // update address from reg transaction
    if(apb_bus_tr.wr == 'b1) apb_bus_tr.din = reg_op.data; // update data from reg transaction
    if(apb_bus_tr.wr == 'b1) apb_bus_tr.dout = reg_op.data; // update data from reg transaction
    
    return apb_bus_tr; // return the bus transaction
  endfunction

  function void bus2reg(uvm_seq_item bus_item, ref uvm_reg_bus_op reg_op);
    transaction apb_bus_tr;

    assert($cast(apb_bus_tr, bus_item)); // cast the bus item to bus transaction, this is optional but recommended to ensure that the bus item is of correct type

    // update reg transaction with bus transaction details
    reg_op.kind = bus_item.wr ? UVM_WRITE : UVM_READ; // update transaction type (read/write) from bus transaction
    reg_op.data = bus_item.data; // update data from bus transaction
    reg_op.addr = bus_item.addr; // update address from bus transaction
    reg_op.status = UVM_IS_OK; // update status of the transaction, this is optional but recommended to indicate the success of the transaction
  endfunction
endclass


//adapter code with protocol specific ports
//APB protocol specific adapter
class apb_adapter extends uvm_adapter;
  `uvm_object_utils(apb_adapter)

  function new(string name = "apb_adapter");
    super.new(name);
  endfunction

  virtual function uvm_sequence_item reg2bus( uvm_reg_bus_op reg_op);
    // create bus transaction
    apb_transaction apb_bus_tr;
    apb_bus_tr = apb_transaction::type_id::create("apb_bus_tr");
    
    // update bus transaction with reg transaction details
    apb_bus_tr.op = (reg_op.kind == UVM_WRITE) ? apb::WRITE : apb::READ; // update transaction type (read/write) from reg transaction
    apb_bus_tr.addr = reg_op.addr; // update address from reg transaction
    apb_bus_tr.data = reg_op.data; // update data from reg transaction    
    return apb_bus_tr; // return the bus transaction
  endfunction

  virtual function void bus2reg(uvm_seq_item bus_item, uvm_reg_bus_op reg_op);
    apb_transaction apb_bus_tr;

    assert($cast(apb_bus_tr, bus_item)) else `uvm_fatal("APB_ADAPTER", "Failed to cast bus item to APB transaction"); // cast the bus item to bus transaction, this is optional but recommended to ensure that the bus item is of correct type

    // update reg transaction with bus transaction details
    reg_op.kind = (bus_item.op == apb::WRITE) ? UVM_WRITE : UVM_READ; // update transaction type (read/write) from bus transaction
    reg_op.data = bus_item.data; // update data from bus transaction
    reg_op.addr = bus_item.addr; // update address from bus transaction
    reg_op.status = UVM_IS_OK; // update status of the transaction, this is optional but recommended to indicate the success of the transaction
  endfunction
endclass


********************Section 4: Different Register Methods********************

************
Types of Predictor

Implicit Predictor
There will not be a separate predictor block, driver performs the predictor actions using bi-directional TLM ports
Steps:
1. generate reg data
2. adapter: convert reg to bus tx
3. send to driver
4. Driver applies stim to dut
5. Driver Collects response
6. Reg model uses response to update desired/mirrored values
//refer img_055.png

Explicit Predictor
Monitor will broadcast response to Predictor and Scoreboard, etc
Predictor will update desired and mirrored values
//refer img_056.png


Passive Predictor
reg sequence will not be. Bus sequence will be used
monitor broadcasts the response to predictor and others
Predictor will update desired and mirrored values
//refer img_057.png

************
Driver Sequencer Communication
