import uvm_pkg::*;
`include "uvm_macros.svh"

class trace_env extends uvm_env;

   `uvm_component_utils(trace_env)

   //------------------------------------------------------------
   // Component Handles
   //------------------------------------------------------------
   trace_agent      agt;
   trace_scoreboard_sf0 sb;

   //------------------------------------------------------------
   // Constructor
   //------------------------------------------------------------
   function new(string name = "trace_env",
                uvm_component parent = null);

      super.new(name, parent);

   endfunction

   //------------------------------------------------------------
   // Build Phase
   //------------------------------------------------------------
   function void build_phase(uvm_phase phase);

      super.build_phase(phase);

      agt = trace_agent::type_id::create("agt", this);
      sb = trace_scoreboard_sf0::type_id::create("sb", this);

      
   endfunction

   //------------------------------------------------------------
   // Connect Phase
   //------------------------------------------------------------
   function void connect_phase(uvm_phase phase);

      super.connect_phase(phase);

      agt.in_mon.mon_ap.connect(sb.in_imp);
      agt.out_mon.mon_ap.connect(sb.out_imp);

      
   endfunction

endclass
