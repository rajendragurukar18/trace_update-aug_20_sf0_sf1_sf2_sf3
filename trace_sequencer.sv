import uvm_pkg::*;
`include "uvm_macros.svh"

class trace_sequencer extends uvm_sequencer #(trace_transaction);

    `uvm_component_utils(trace_sequencer)

    //------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------
    function new(string name = "trace_sequencer",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

endclass
