import uvm_pkg::*;
`include "uvm_macros.svh"

class trace_input_monitor extends uvm_monitor;

  `uvm_component_utils(trace_input_monitor)

  virtual trace_if vif;

  trace_transaction tr;

  uvm_analysis_port #(trace_transaction) mon_ap;

  function new(string name="trace_input_monitor",
               uvm_component parent=null);

      super.new(name,parent);

      mon_ap = new("mon_ap",this);

  endfunction

  function void build_phase(uvm_phase phase);

      super.build_phase(phase);

      if(!uvm_config_db#(virtual trace_if)::get(this,"","vif",vif))
          `uvm_fatal("IN_MON","Unable to get interface")

  endfunction

  task run_phase(uvm_phase phase);

 forever begin

   @(posedge vif.core_clk_i);

if (vif.it_itype_valid) begin
   tr = trace_transaction::type_id::create("tr");

   tr.it_itype                 = vif.it_itype;
   tr.it_iaddr                 = vif.it_iaddr;
   tr.it_cause                 = vif.it_cause;
   tr.it_tval                  = vif.it_tval;
  // tr.it_priv                  = vif.it_priv;
   tr.it_context               = vif.it_context;

   //tr.it_trace_enable          = vif.it_trace_enable;

   tr.it_ienable_in            = vif.it_ienable_in;
   tr.it_itype_valid           = vif.it_itype_valid;
   tr.it_first_instrn_valid_in = vif.it_first_instrn_valid_in;

   tr.it_delta_addr            = vif.it_delta_addr;
   tr.it_del_adr_valid         = vif.it_del_adr_valid;

   tr.afvalid_i                = vif.afvalid_i;
   tr.atready_i                = vif.atready_i;

// APB Inputs

     tr.paddr_i   = vif.paddr_i;
    tr.psel_i    = vif.psel_i;
    tr.penable_i = vif.penable_i;
    
    tr.pwrite_i  = vif.pwrite_i;
    tr.pwdata_i  = vif.pwdata_i;
   mon_ap.write(tr);
 end
 end
endtask
endclass
