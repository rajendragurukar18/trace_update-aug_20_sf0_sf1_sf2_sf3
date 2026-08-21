import uvm_pkg::*;
`include "uvm_macros.svh"

`uvm_analysis_imp_decl(_IN)
`uvm_analysis_imp_decl(_OUT)

class trace_scoreboard_sf0 extends uvm_scoreboard;

  `uvm_component_utils(trace_scoreboard_sf0)

  //------------------------------------------------------------
  // Analysis Ports
  //------------------------------------------------------------
  uvm_analysis_imp_IN #(trace_transaction, trace_scoreboard_sf0) in_imp;
  uvm_analysis_imp_OUT #(trace_transaction, trace_scoreboard_sf0) out_imp;

  //------------------------------------------------------------
  // Transactions
  //------------------------------------------------------------
  //--------------------------------------------------------------------------
// Transactions
//--------------------------------------------------------------------------
trace_transaction input_tr;
trace_transaction output_tr;

//--------------------------------------------------------------------------
// SF0 Expected Packet
//--------------------------------------------------------------------------
typedef struct {

  bit [15:0] word0;
  bit [15:0] word1;
  bit [15:0] word2;
  bit [15:0] word3;

} sf0_packet_t;

// Queue to store predicted packets
sf0_packet_t expected_queue[$];

// Temporary packet
sf0_packet_t exp_pkt;

// Compare counter
int compare_count;

bit packet_started;

sf0_packet_t curr_pkt;

//------------------------------------------------------------
// Predictor Variables
//------------------------------------------------------------
bit        branch_tmp;


bit interrupt_tmp;
//bit thaddr_tmp;


bit [2:0] header_field;
//bit [1:0] format_field;
//bit [1:0] subformat_field;

bit [63:0] expected_packet;

// SF2 Context Tracking
//------------------------------------------------------------
bit [1:0] prev_context;
bit       prev_context_valid;
//------------------------------------------------------------
// SF3 Tracking
//------------------------------------------------------------
int sf3_input_count;
bit sf3_test_mode;
  //------------------------------------------------------------
  // Constructor
  //------------------------------------------------------------
  function new(string name="trace_scoreboard_sf0",
               uvm_component parent=null);
    super.new(name,parent);

    in_imp  = new("in_imp", this);
    out_imp = new("out_imp", this);
  endfunction

  //------------------------------------------------------------
  // Build Phase
  //------------------------------------------------------------
  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    header_field    = 3'b010;
    //format_field    = 2'b11;
    //subformat_field = 2'b00;
    compare_count = 0;
    packet_started = 0;

    // SF2 Context Tracking Initialization
    //------------------------------------------------------------
    prev_context       = 2'b00;
    prev_context_valid = 1'b0;
    
sf3_input_count = 0;
sf3_test_mode   = 1'b0;


endfunction


  //------------------------------------------------------------
  // INPUT MONITOR
  //------------------------------------------------------------
 virtual function void write_IN(trace_transaction tr);

    input_tr = tr;

    if(tr.it_itype_valid)
    begin

        //--------------------------------------------------
        // SF3 FIFO FULL TEST
        //--------------------------------------------------
        if(sf3_test_mode)
        begin

            sf3_input_count++;

            `uvm_info("SF3",
                      $sformatf("FIFO TEST input count = %0d",
                                sf3_input_count),
                      UVM_LOW)

            //------------------------------------------------
            // Set this to the transaction where your
            // waveform shows SF3 being generated.
            //------------------------------------------------
            if(sf3_input_count == 77)
            begin
                `uvm_info("SF3",
                          "Predicting SF3 packet",
                          UVM_LOW)

                predict_sf3();
            end

        end
        else
        begin

            //--------------------------------------------------
            // EXISTING SF0 / SF1 / SF2 LOGIC
            //--------------------------------------------------

            if(tr.it_first_instrn_valid_in)
            begin
                predict_sf0();
            end
            else if(prev_context_valid &&
                    (tr.it_context != prev_context))
            begin
                // Context changed -> SF2
                predict_sf2();
            end
            else
            begin
                // No context change -> SF1
                predict_sf1();
            end

            //--------------------------------------------------
            // Update context history
            //--------------------------------------------------
            prev_context       = tr.it_context;
            prev_context_valid = 1'b1;

        end
    end

endfunction






//------------------------------------------------------------
// SF0 Predictor
//------------------------------------------------------------
function void predict_sf0();

    //----------------------------------------------------------
    // Branch Bit
    //----------------------------------------------------------
    branch_tmp = (input_tr.it_itype == 4'b0101);

    //----------------------------------------------------------
    // Build Expected SF0 Packet
    //
    // New RTL:
    // {42'b0,
    //  iaddr[15:0],
    //  context[1:0],
    //  branch,
    //  HEADER[2:0]}
    //----------------------------------------------------------
    expected_packet =
    {
        42'b0,
        input_tr.it_iaddr,
        input_tr.it_context,
        branch_tmp,
        3'b010
    };

    //----------------------------------------------------------
    // Split into 16-bit ATB Words
    //----------------------------------------------------------
    exp_pkt.word0 = expected_packet[15:0];
    exp_pkt.word1 = expected_packet[31:16];
    exp_pkt.word2 = expected_packet[47:32];
    exp_pkt.word3 = expected_packet[63:48];

    //----------------------------------------------------------
    // Print Expected Words
    //----------------------------------------------------------
    `uvm_info("SF0_PREDICTOR",
        $sformatf("Expected Word0 = %04h",
                  exp_pkt.word0),
        UVM_NONE);

    `uvm_info("SF0_PREDICTOR",
        $sformatf("Expected Word1 = %04h",
                  exp_pkt.word1),
        UVM_NONE);

    `uvm_info("SF0_PREDICTOR",
        $sformatf("Expected Word2 = %04h",
                  exp_pkt.word2),
        UVM_NONE);

    `uvm_info("SF0_PREDICTOR",
        $sformatf("Expected Word3 = %04h",
                  exp_pkt.word3),
        UVM_NONE);

    //----------------------------------------------------------
    // Store expected packet
    //----------------------------------------------------------
    expected_queue.push_back(exp_pkt);

endfunction





//------------------------------------------------------------
// SF1 Predictor


//------------------------------------------------------------
// SF1 Predictor
//------------------------------------------------------------
function void predict_sf1();

    //----------------------------------------------------------
    // Temporary Fields
    //----------------------------------------------------------
    branch_tmp    = (input_tr.it_itype == 4'b0101);
    interrupt_tmp = (input_tr.it_itype == 4'b0010);

    //----------------------------------------------------------
    // Build Expected SF1 Packet
    //
    // New RTL:
    //
    // {1'b0,
    //  tval[31:0],
    //  iaddr[15:0],
    //  interrupt,
    //  cause[7:0],
    //  context[1:0],
    //  branch,
    //  HEADER[2:0]}
    //----------------------------------------------------------
    expected_packet =
    {
        1'b0,
        input_tr.it_tval,
        input_tr.it_iaddr,
        interrupt_tmp,
        input_tr.it_cause,
        input_tr.it_context,
        branch_tmp,
        3'b011
    };

    //----------------------------------------------------------
    // Split into 16-bit ATB Words
    //----------------------------------------------------------
    exp_pkt.word0 = expected_packet[15:0];
    exp_pkt.word1 = expected_packet[31:16];
    exp_pkt.word2 = expected_packet[47:32];
    exp_pkt.word3 = expected_packet[63:48];

    //----------------------------------------------------------
    // Print Expected Words
    //----------------------------------------------------------
    `uvm_info("SF1_PREDICTOR",
        $sformatf("Expected Word0 = %04h",
                  exp_pkt.word0),
        UVM_NONE);

    `uvm_info("SF1_PREDICTOR",
        $sformatf("Expected Word1 = %04h",
                  exp_pkt.word1),
        UVM_NONE);

    `uvm_info("SF1_PREDICTOR",
        $sformatf("Expected Word2 = %04h",
                  exp_pkt.word2),
        UVM_NONE);

    `uvm_info("SF1_PREDICTOR",
        $sformatf("Expected Word3 = %04h",
                  exp_pkt.word3),
        UVM_NONE);

    //----------------------------------------------------------
    // Store expected packet
    //----------------------------------------------------------
    expected_queue.push_back(exp_pkt);

endfunction






//------------------------------------------------------------
// SF2 Predictor
//------------------------------------------------------------
function void predict_sf2();

    //----------------------------------------------------------
    // Build Expected SF2 Packet
    //
    // New RTL:
    //
    // {59'b0,
    //  context[1:0],
    //  HEADER[2:0]}
    //----------------------------------------------------------
    expected_packet =
    {
        59'b0,
        input_tr.it_context,
        3'b100
    };

    //----------------------------------------------------------
    // Split into 16-bit ATB Words
    //----------------------------------------------------------
    exp_pkt.word0 = expected_packet[15:0];
    exp_pkt.word1 = expected_packet[31:16];
    exp_pkt.word2 = expected_packet[47:32];
    exp_pkt.word3 = expected_packet[63:48];

    //----------------------------------------------------------
    // Print Expected Words
    //----------------------------------------------------------
    `uvm_info("SF2_PREDICTOR",
        $sformatf("Expected Word0 = %04h",
                  exp_pkt.word0),
        UVM_NONE);

    `uvm_info("SF2_PREDICTOR",
        $sformatf("Expected Word1 = %04h",
                  exp_pkt.word1),
        UVM_NONE);

    `uvm_info("SF2_PREDICTOR",
        $sformatf("Expected Word2 = %04h",
                  exp_pkt.word2),
        UVM_NONE);

    `uvm_info("SF2_PREDICTOR",
        $sformatf("Expected Word3 = %04h",
                  exp_pkt.word3),
        UVM_NONE);

    //----------------------------------------------------------
    // Store expected packet
    //----------------------------------------------------------
    expected_queue.push_back(exp_pkt);

endfunction






//------------------------------------------------------------
// SF3 Predictor
//------------------------------------------------------------
function void predict_sf3();

    //----------------------------------------------------------
    // SF3 variable fields
    //----------------------------------------------------------
    bit branch_tmp;
    bit ienable_tmp;

    branch_tmp  = (input_tr.it_itype == 4'b0101);
    ienable_tmp = input_tr.it_ienable_in;

    //----------------------------------------------------------
    // Build expected SF3 packet
    //
    // New RTL:
    //
    // {57'b0,
    //  qual_status[1:0],
    //  branch_tmp,
    //  ienable_in,
    //  HEADER[2:0]}
    //----------------------------------------------------------
    expected_packet =
    {
        57'b0,
        2'b00,
        branch_tmp,
        ienable_tmp,
        3'b101
    };

    //----------------------------------------------------------
    // Split into 16-bit ATB words
    //----------------------------------------------------------
    exp_pkt.word0 = expected_packet[15:0];
    exp_pkt.word1 = expected_packet[31:16];
    exp_pkt.word2 = expected_packet[47:32];
    exp_pkt.word3 = expected_packet[63:48];

    //----------------------------------------------------------
    // Print Expected Words
    //----------------------------------------------------------
    `uvm_info("SF3_PREDICTOR",
        $sformatf("Expected Word0 = %04h",
                  exp_pkt.word0),
        UVM_LOW)

    `uvm_info("SF3_PREDICTOR",
        $sformatf("Expected Word1 = %04h",
                  exp_pkt.word1),
        UVM_LOW)

    `uvm_info("SF3_PREDICTOR",
        $sformatf("Expected Word2 = %04h",
                  exp_pkt.word2),
        UVM_LOW)

    `uvm_info("SF3_PREDICTOR",
        $sformatf("Expected Word3 = %04h",
                  exp_pkt.word3),
        UVM_LOW)

    //----------------------------------------------------------
    // Add SF3 expected packet to queue
    //----------------------------------------------------------
    expected_queue.push_back(exp_pkt);

endfunction








  //------------------------------------------------------------
  // OUTPUT MONITOR
  //------------------------------------------------------------
virtual function void write_OUT(trace_transaction tr);

    output_tr = tr;

    if(tr.atvalid_o)
    begin

        `uvm_info("OUTPUT_SB",
          $sformatf("TIME=%0t ATVALID=%0b ATDATA=%04h",
                    $time,
                    tr.atvalid_o,
                    tr.atdata_o),
          UVM_NONE);


        //----------------------------------------------------
        // Start of a new packet
        //----------------------------------------------------
        if(!packet_started)
        begin

            if(expected_queue.size() == 0)
            begin
                `uvm_error("SB","Expected Queue Empty")
                return;
            end


            //------------------------------------------------
            // DO NOT POP YET
            // Just look at the first expected packet
            //------------------------------------------------
            curr_pkt = expected_queue[0];


            //------------------------------------------------
            // Wait until DUT gives expected first word
            //------------------------------------------------
            if(tr.atdata_o != curr_pkt.word0)
            begin
                `uvm_info("SB",
                    $sformatf(
                      "Waiting... DUT=%04h Expected First=%04h",
                      tr.atdata_o,
                      curr_pkt.word0),
                    UVM_LOW)

                return;
            end


            //------------------------------------------------
            // First word matched
            // NOW remove packet from queue
            //------------------------------------------------
            expected_queue.pop_front();

            packet_started = 1;
            compare_count = 0;


            `uvm_info("SB",
                "First packet word detected. Starting comparison.",
                UVM_LOW)

        end


        //----------------------------------------------------
        // Packet word comparison
        //----------------------------------------------------
        case(compare_count)

            0:
            begin
                if(tr.atdata_o == curr_pkt.word0)
                    `uvm_info("COMPARE",
                        $sformatf(
                          "WORD0 MATCH Exp=%04h Act=%04h",
                          curr_pkt.word0,
                          tr.atdata_o),
                        UVM_LOW)
                else
                    `uvm_error("COMPARE",
                        $sformatf(
                          "WORD0 MISMATCH Exp=%04h Act=%04h",
                          curr_pkt.word0,
                          tr.atdata_o))
            end


            1:
            begin
                if(tr.atdata_o == curr_pkt.word1)
                    `uvm_info("COMPARE",
                        $sformatf(
                          "WORD1 MATCH Exp=%04h Act=%04h",
                          curr_pkt.word1,
                          tr.atdata_o),
                        UVM_LOW)
                else
                    `uvm_error("COMPARE",
                        $sformatf(
                          "WORD1 MISMATCH Exp=%04h Act=%04h",
                          curr_pkt.word1,
                          tr.atdata_o))
            end


            2:
            begin
                if(tr.atdata_o == curr_pkt.word2)
                    `uvm_info("COMPARE",
                        $sformatf(
                          "WORD2 MATCH Exp=%04h Act=%04h",
                          curr_pkt.word2,
                          tr.atdata_o),
                        UVM_LOW)
                else
                    `uvm_error("COMPARE",
                        $sformatf(
                          "WORD2 MISMATCH Exp=%04h Act=%04h",
                          curr_pkt.word2,
                          tr.atdata_o))
            end


            3:
            begin
                if(tr.atdata_o == curr_pkt.word3)
                    `uvm_info("COMPARE",
                        $sformatf(
                          "WORD3 MATCH Exp=%04h Act=%04h",
                          curr_pkt.word3,
                          tr.atdata_o),
                        UVM_LOW)
                else
                    `uvm_error("COMPARE",
                        $sformatf(
                          "WORD3 MISMATCH Exp=%04h Act=%04h",
                          curr_pkt.word3,
                          tr.atdata_o))
            end

        endcase


        compare_count++;


        //----------------------------------------------------
        // Packet complete
        //----------------------------------------------------
        if(compare_count == 4)
        begin
            compare_count = 0;
            packet_started = 0;

            `uvm_info("SB",
                "Packet comparison completed",
                UVM_LOW)
        end

    end

endfunction


endclass
