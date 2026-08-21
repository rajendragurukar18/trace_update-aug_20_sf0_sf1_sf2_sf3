import uvm_pkg::*;
`include "uvm_macros.svh"

class trace_transaction extends uvm_sequence_item;

    `uvm_object_utils(trace_transaction)

    //------------------------------------------------------------
    // DUT INPUTS (Driven by Driver)
    //------------------------------------------------------------

    rand bit [3:0]  it_itype;

    //rand bit [19:0] it_iaddr;
    rand bit [15:0] it_iaddr;

    rand bit [7:0]  it_cause;

    //rand bit [19:0] it_tval;
    rand bit [31:0] it_tval;

    //rand bit [2:0]  it_priv;  // new design priv is completely removed


    //rand bit [2:0]  it_context;
    rand bit [1:0]  it_context;

   // rand bit        it_trace_enable;
    rand bit        it_ienable_in;
    rand bit        it_itype_valid;
    rand bit        it_first_instrn_valid_in;

    rand bit [19:0] it_delta_addr;
    rand bit        it_del_adr_valid;

    rand bit        afvalid_i;
    rand bit        atready_i;

//  APB INPUTS

    rand bit [7:0]  paddr_i;
    rand bit        psel_i;
   rand bit        penable_i;
    rand bit        pwrite_i;
    rand bit [31:0] pwdata_i;


    //------------------------------------------------------------
    // DUT OUTPUTS (Captured by Monitor)
    //------------------------------------------------------------

    bit             afready_o;

    bit             atvalid_o;
    bit [15:0]      atdata_o;
    // bit [6:0]       atid_o;
    // bit [2:0]       atbytes_o;
    
    bit [31:0] prdata_o;
    bit        pready_o;
    bit        pslverr_o;



    // Expected Packet (Scoreboard Predictor)
    
    bit [63:0] expected_packet;

    //------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------

    function new(string name = "trace_transaction");
        super.new(name);
    endfunction

endclass
