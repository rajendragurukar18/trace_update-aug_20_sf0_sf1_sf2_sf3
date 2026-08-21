import uvm_pkg::*;
`include "uvm_macros.svh"

class trace_driver extends uvm_driver #(trace_transaction);

    `uvm_component_utils(trace_driver)

    //------------------------------------------------------------
    // Virtual Interface
    //------------------------------------------------------------
    virtual trace_if vif;

    //------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------
    function new(string name = "trace_driver",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //------------------------------------------------------------
    // Build Phase
    //------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(virtual trace_if)::get(this,"","vif",vif))
            `uvm_fatal("DRV","Unable to get Virtual Interface")
    endfunction

    //------------------------------------------------------------
    // Run Phase
    //------------------------------------------------------------
    virtual task run_phase(uvm_phase phase);


wait(vif.it_rst_n == 1);

// @(posedge vif.core_clk_i);
//------------------------------
// APB Setup Phase
//------------------------------
@(posedge vif.pclk_i);

//@(posedge vif.pclk_i);
vif.psel_i    <= 1'b1;
//@(posedge vif.pclk_i);
vif.penable_i <= 1'b0;
vif.pwrite_i <=1'b1;
vif.pwdata_i  <= 1'b1;
@(posedge vif.pclk_i);

//------------------------------
// APB Access Phase
//------------------------------
vif.penable_i <= 1'b1;

while(vif.pready_o == 1'b0)
    @(posedge vif.pclk_i);

//------------------------------
// Transfer Complete
//------------------------------
//@(posedge vif.pclk_i);

vif.psel_i    <= 1'b0;
vif.penable_i <= 1'b0;
repeat(5) @(posedge vif.core_clk_i );

        forever
        begin

            //----------------------------------------------------
            // Get transaction from Sequencer
            //----------------------------------------------------
            seq_item_port.get_next_item(req);

            //----------------------------------------------------
            // Drive on next clock edge
            //----------------------------------------------------
            @(posedge vif.core_clk_i);

            vif.it_itype                  <= req.it_itype;
            vif.it_iaddr                  <= req.it_iaddr;
            vif.it_cause                  <= req.it_cause;
            vif.it_tval                   <= req.it_tval;
            //vif.it_priv                   <= req.it_priv;
            vif.it_context                <= req.it_context;

            //vif.it_trace_enable           <= req.it_trace_enable;
            vif.it_ienable_in             <= req.it_ienable_in;
            vif.it_itype_valid            <= req.it_itype_valid;
            vif.it_first_instrn_valid_in  <= req.it_first_instrn_valid_in;

            vif.it_delta_addr             <= req.it_delta_addr;
            vif.it_del_adr_valid          <= req.it_del_adr_valid;

            vif.afvalid_i                 <= req.afvalid_i;
            vif.atready_i                 <= req.atready_i;




            // APB Signals
            vif.paddr_i   <= req.paddr_i;
           // vif.psel_i    <= req.psel_i;
            //vif.penable_i <= req.penable_i;
            vif.pwrite_i  <= req.pwrite_i;
            vif.pwdata_i  <= req.pwdata_i;





            //----------------------------------------------------
            // Print Transaction
            //----------------------------------------------------
            `uvm_info("DRIVER",
                      $sformatf("Driven : itype=%0d iaddr=%0h cause=%0h context=%0d",
                                req.it_itype,
                                req.it_iaddr,
                                req.it_cause,
                                req.it_context),
                      UVM_LOW)




            //----------------------------------------------------
            // Transaction Completed
            //----------------------------------------------------
            seq_item_port.item_done();


//----------------------------------------------------
// Deassert one-cycle valid signals
//----------------------------------------------------
@(posedge vif.core_clk_i);

vif.it_itype_valid           <= 1'b0;
vif.it_first_instrn_valid_in <= 1'b0;
vif.it_del_adr_valid         <= 1'b0;

wait(vif.it_rst_n == 1);


vif.it_itype_valid           <= 1'b0;
vif.it_first_instrn_valid_in <= 1'b0;
vif.it_del_adr_valid         <= 1'b0;

        end
    endtask
endclass

