`timescale 1ns/1ps

interface trace_if(
                    input logic it_clk,
                    input logic core_clk_i,
                    input logic pclk_i);

    //------------------------------------------------------------
    // Reset
    //------------------------------------------------------------
    logic it_rst_n;
    logic core_rst_ni;
    logic presetn_i;

    //------------------------------------------------------------
    // Trace Encoder Inputs
    //------------------------------------------------------------
    logic [3:0]  it_itype;
    logic [15:0] it_iaddr;
    logic [7:0]  it_cause;
    logic [31:0] it_tval;
    logic [1:0]  it_context;

    logic        it_ienable_in;
    logic        it_itype_valid;
    logic        it_first_instrn_valid_in;

    logic [19:0] it_delta_addr;
    logic        it_del_adr_valid;

    //------------------------------------------------------------
    // Flush Interface
    //------------------------------------------------------------
    logic        afvalid_i;
    logic        afready_o;

    //------------------------------------------------------------
    // ATB Interface
    //------------------------------------------------------------
    logic        atready_i;
    logic        atvalid_o;
    logic [15:0] atdata_o;

    //------------------------------------------------------------
    // APB -- SIGNALS
    //------------------------------------------------------------
    logic [7:0]  paddr_i;
    logic        psel_i;
    logic        penable_i;
    logic        pwrite_i;
    logic [31:0] pwdata_i;

    logic [31:0] prdata_o;
    logic        pready_o;
    logic        pslverr_o;

endinterface
