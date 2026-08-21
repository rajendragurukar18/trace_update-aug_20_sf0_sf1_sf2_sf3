import uvm_pkg::*;
`include "uvm_macros.svh"

class trace_test extends uvm_test;

   `uvm_component_utils(trace_test)

   trace_env env;

   function new(string name="trace_test",
                uvm_component parent=null);

      super.new(name,parent);

   endfunction

   function void build_phase(uvm_phase phase);

      super.build_phase(phase);

      env = trace_env::type_id::create("env",this);

   endfunction

   task run_phase(uvm_phase phase);

      trace_sequence seq;

      phase.raise_objection(this);

      seq = trace_sequence::type_id::create("seq");

      seq.start(env.agt.seqr);

      #700;

      phase.drop_objection(this);

   endtask

endclass
