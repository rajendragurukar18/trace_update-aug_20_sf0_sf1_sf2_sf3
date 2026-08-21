import uvm_pkg::*;
`include "uvm_macros.svh"

`timescale 1ns/1ps
module top_tb;

   import uvm_pkg::*;
   `include "uvm_macros.svh"

   bit it_clk;
   bit core_clk_i;
   bit pclk_i;

   //-------------------------------------------------------
   // Clock Generation
   //-------------------------------------------------------

    always #5 it_clk = ~it_clk;
    always #4  core_clk_i = ~core_clk_i;
    always #10 pclk_i     = ~pclk_i;

   //-------------------------------------------------------
   // Interface
   //-------------------------------------------------------

    trace_if vif(
    it_clk,
    core_clk_i,
    pclk_i
                );


   //-------------------------------------------------------
   // DUT
   //-------------------------------------------------------

   top_core_trace  dut(

      .it_clk(it_clk),

      .it_rst_n(vif.it_rst_n),

      .core_clk_i(core_clk_i),

      .core_rst_ni(vif.core_rst_ni),

      .pclk_i(pclk_i),

      .presetn_i(vif.presetn_i),

      .it_itype(vif.it_itype),

      .it_iaddr(vif.it_iaddr),

      .it_cause(vif.it_cause),

      .it_tval(vif.it_tval),

      
      .it_context(vif.it_context),

      //.it_trace_enable(vif.it_trace_enable),

      .it_ienable_in(vif.it_ienable_in),

      .it_itype_valid(vif.it_itype_valid),

      .it_first_instrn_valid_in(vif.it_first_instrn_valid_in),

      .it_delta_addr(vif.it_delta_addr),

      .it_del_adr_valid(vif.it_del_adr_valid),

      .afvalid_i(vif.afvalid_i),

      //.afready_o(vif.afready_o),

      .atready_i(vif.atready_i),

      .atvalid_o(vif.atvalid_o),

      .atdata_o(vif.atdata_o),


         .paddr_i(vif.paddr_i),

         .psel_i(vif.psel_i),

         .penable_i(vif.penable_i),

         .pwrite_i(vif.pwrite_i),
    
         .pwdata_i(vif.pwdata_i),

         .prdata_o(vif.prdata_o),

         .pready_o(vif.pready_o),

         .pslverr_o(vif.pslverr_o)

         //.atid_o(vif.atid_o),

          //.atbytes_o(vif.atbytes_o)

   );


initial begin
    $shm_open("waves.shm");
    $shm_probe("ACTMF");
end
   //-------------------------------------------------------
   // Reset
   //-------------------------------------------------------

   initial begin

      vif.it_rst_n = 0;
      vif.core_rst_ni  = 0;
      vif.presetn_i    = 0;


      repeat(5) @(posedge it_clk);

      vif.it_rst_n = 1;
      vif.core_rst_ni  = 1;
      vif.presetn_i    = 1;

   end

    initial begin

    vif.psel_i    = 0;
    vif.penable_i = 0;
    vif.pwrite_i  = 0;
    vif.paddr_i   = 0;
    vif.pwdata_i  = 0;

end

    


   //-------------------------------------------------------
   // UVM
   //-------------------------------------------------------

   initial begin

      uvm_config_db #(virtual trace_if)::set(null,
                                             "*",
                                             "vif",
                                             vif);

      run_test("trace_test");

   end


//-------------------------------------------------------
// Temporary ATB Ready Handshake (Debug)
//-------------------------------------------------------

endmodule
