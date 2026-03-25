// Implement an adapter class for the design whose code is mentioned in the instruction tab.

/*
The functionality of I/O ports is as follows:

1) clk is the global clock signal

2) rst is active high synchronous reset

3) addrin is used to specify address of register where read or write operation will be performed.

4) datain is an input data bus

5) dataout is the output data bus.

6) wr is mode control pin (if wr is high 
then specific register will be updated with datain value based on address specified on addrin bus 
else content of register will be returned on dataout bus  based on address specified on addrin bus )
*/

//design
module top(
  input clk, rst,
  input wr,
  input [3:0]  addrin,
  input [31:0]  datain,
  output [31:0] dataout
);
  
  ////////////DUT registers
  logic [31:0] reg1;///offset addr : 0
  logic [31:0] reg2;///offset addr : 1
  logic [31:0] reg3;///offset addr : 2
  logic [31:0] reg4;///offset addr : 3
  
  //////////// temporary register to store read data
  logic [31:0] temp;
  
  
  always@(posedge clk)
    begin
      if(rst)
        begin
        reg1 <= 32'h0;
        reg2 <= 32'h0;
        reg3 <= 32'h0;
        reg4 <= 32'h0;
        temp <= 32'h0;  
        end
      else 
        begin
          if(wr) 
           begin
            case(addrin)
              2'b00: reg1 <= datain;
              2'b01: reg2 <= datain;
              2'b10: reg3 <= datain;
              2'b11: reg4 <= datain;
            endcase
          end
          else
           begin
            case(addrin)
              2'b00: temp <= reg1;
              2'b01: temp <= reg2;
              2'b10: temp <= reg3;
              2'b11: temp <= reg4;
            endcase
          end
        end
    end
  assign dataout = temp;
  
endmodule
 
 
//////////////////////////////////////
//interface

interface top_if ;
  
  logic clk, rst;
  logic wr;
  logic [3:0]  addrin;
  logic [31:0]  datain;
  logic [31:0] dataout;
  
endinterface

class transaction extends uvm_sequence_item;
  `uvm_object_utils(transaction)
  
  logic wr;
  logic [3:0]  addrin;
  logic [31:0]  datain;
  logic [31:0] dataout;
  
  function new(string name = "transaction");
    super.new(name);
  endfunction
endclass

class top_adapter;
  `uvm_object_utils(top_adapter)
  
  virtual top_if vif;
  
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

