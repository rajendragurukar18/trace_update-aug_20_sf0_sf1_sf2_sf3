import uvm_pkg::*;
`include "uvm_macros.svh"

class trace_agent extends uvm_agent;

   `uvm_component_utils(trace_agent)

   //------------------------------------------------------------
   // Component Handles
   //------------------------------------------------------------
    trace_driver drv;
    trace_sequencer seqr;
    trace_input_monitor in_mon;
    trace_output_monitor out_mon;

   //------------------------------------------------------------
   // Constructor
   //------------------------------------------------------------
   function new(string name = "trace_agent",
                uvm_component parent = null);

      super.new(name, parent);

   endfunction

   //------------------------------------------------------------
   // Build Phase
   //------------------------------------------------------------
   function void build_phase(uvm_phase phase);

      super.build_phase(phase);

      drv     = trace_driver::type_id::create("drv",this);
      seqr    = trace_sequencer::type_id::create("seqr",this);
      in_mon  = trace_input_monitor::type_id::create("in_mon",this);
      out_mon = trace_output_monitor::type_id::create("out_mon",this);   endfunction

   //------------------------------------------------------------
   // Connect Phase
   //------------------------------------------------------------
   function void connect_phase(uvm_phase phase);

      super.connect_phase(phase);

      drv.seq_item_port.connect(seqr.seq_item_export);

   endfunction

endclass
