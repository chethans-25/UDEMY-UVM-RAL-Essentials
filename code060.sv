`include "uvm_macros.svh"
import uvm_pkg::*;
 
 
///////////////////////transaction class
class transaction extends uvm_sequence_item;
  rand bit[3:0] addr;
  rand bit[3:0] data;
  
  `uvm_object_utils(transaction)
  
  function new(string name = "transaction");
    super.new(name);
  endfunction
  
endclass
 
///////////////////////generator
 
class generator extends uvm_sequence #(transaction);
  `uvm_object_utils(generator)
  
    transaction tr;
  
  function new (string name = "generator");
    super.new(name);
  endfunction
 
  task body();
    tr = transaction::type_id::create("tr");
    wait_for_grant();
    assert(tr.randomize());
    `uvm_info("SEQ", $sformatf("Sending TX to SEQR: addr = %0d  data = %0d", tr.addr, tr.data),UVM_LOW); 
    send_request(tr);
    wait_for_item_done();
    get_response(tr); //get response from Driver
    `uvm_info("SEQ", $sformatf("After get_response: addr = %0d  data = %0d", tr.addr, tr.data), UVM_LOW);
  endtask
endclass
 
/////////////////////////////////driver
 
 
class driver extends uvm_driver#(transaction);
  `uvm_component_utils(driver)
  
  transaction tr;
  
  
  function new(string name = "driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
 
  
  task run_phase (uvm_phase phase);
    forever 
      begin
        seq_item_port.get_next_item(tr);
        `uvm_info("DRV", $sformatf("Recv. TX from SEQR addr = %0d data = %0d",tr.addr, tr.data), UVM_LOW);
         #100; 
        `uvm_info("DRV", $sformatf("Applied Stimuli to DUT -> Sending REQ response to SEQR"), UVM_LOW);
        seq_item_port.item_done(tr);
      end
  endtask
  
  
endclass
 
 
///////////////////////////////////////////////////// sequencer
 
 
class sequencer extends uvm_sequencer #(transaction);
  `uvm_component_utils(sequencer)
  
  function new(string name = "sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
endclass
 
////////////////////////////////////////////agent
 
class agent extends uvm_agent;
   `uvm_component_utils(agent)
  
  driver drv;
  sequencer seqr;
  
 
  
  function new(string name = "agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv = driver::type_id::create("drv", this);
    seqr = sequencer::type_id::create("seqr", this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction
  
  
endclass
 
 
//////////////////////////////////////////////////// env
class env extends uvm_agent;
  `uvm_component_utils(env)
 
  
  agent agt;
  
  function new(string name = "env", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agt = agent::type_id::create("agt", this);
  endfunction
  
endclass
 
//////////////////////////////////////////////////////////test
 
class test extends uvm_test;
  `uvm_component_utils(test)
  
  
  env e;
  generator gen;
 
 
  
  function new(string name = "test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env::type_id::create("e", this);
    gen = generator::type_id::create("gen");    
 
  endfunction
 
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    gen.start(e.agt.seqr);
    phase.drop_objection(this);
  endtask
endclass
 
 
/////////////////////////////////////////////
 
module tb;
  initial begin
    run_test("test");
  end
endmodule