module atb_transmitter
#(
    parameter DATA_WIDTH = 64,
    parameter ATID_WIDTH = 7,
    parameter ATID_VALUE = 7'h01
)
(
    //----------------------------------------------------------
    // Global Signals
    //----------------------------------------------------------
    input                       atclk,
    input                       atresetn,

    //----------------------------------------------------------
    // Trace FIFO Interface
    //----------------------------------------------------------
    input  [DATA_WIDTH-1:0]     tf_rdata,
    input                       tf_rempty,
    output reg                  tf_ren,

    //----------------------------------------------------------
    // Flush Interface
    //----------------------------------------------------------
    input                       afvalid_i,
    output reg                  afready_o,

    //----------------------------------------------------------
    // ATB Interface
    //----------------------------------------------------------
    output reg [15:0] atdata_o,
    output reg                  atvalid_o,
    input                       atready_i

   // output reg [ATID_WIDTH-1:0] atid_o,
    //output reg [2:0]            atbytes_o
);


//==============================================================
// State Encoding
//==============================================================

localparam ST_IDLE      = 3'd0;
localparam ST_FIFO_READ = 3'd1;
localparam ST_CAPTURE   = 3'd2;
localparam ST_SEND      = 3'd3;
localparam ST_FLUSH     = 3'd4;


//==============================================================
// State Registers
//==============================================================

reg [2:0] current_state;
reg [2:0] next_state;


//==============================================================
// Internal Registers
//==============================================================

// Holds one complete ATB packet
reg [DATA_WIDTH-1:0] packet_reg;

// Flush request pending
reg flush_pending;

// Indicates transmitter busy
reg tx_busy;
reg [1:0] word_cnt;

//==============================================================
// State Register
//==============================================================

always @(posedge atclk or negedge atresetn)
begin
    if(!atresetn)
        current_state <= ST_IDLE;
    else
        current_state <= next_state;
end


//==============================================================
// Sequential Output Logic
//==============================================================

always @(posedge atclk or negedge atresetn)
begin

    if(!atresetn)
    begin

        //------------------------------------------------------
        // FIFO
        //------------------------------------------------------
        tf_ren <= 1'b0;

        //------------------------------------------------------
        // ATB Outputs
        //------------------------------------------------------
        atdata_o  <=16'h0000;
        atvalid_o <= 1'b0;

      //  atid_o    <= ATID_VALUE;
       // atbytes_o <= 3'b111;

        //------------------------------------------------------
        // Flush
        //------------------------------------------------------
        afready_o     <= 1'b0;
        flush_pending <= 1'b0;

        //------------------------------------------------------
        // Internal
        //------------------------------------------------------
        packet_reg <= {DATA_WIDTH{1'b0}};
        tx_busy    <= 1'b0;
        word_cnt <= 2'd0;

    end
    else
    begin

        //------------------------------------------------------
        // Default Outputs
        //------------------------------------------------------
        tf_ren     <= 1'b0;
        afready_o  <= 1'b0;

        //------------------------------------------------------
        // Latch Flush Request
        //------------------------------------------------------
        if(afvalid_i)
            flush_pending <= 1'b1;

        //------------------------------------------------------
        // State Machine
        //------------------------------------------------------
        case(current_state)
             ST_IDLE:
        begin

            atvalid_o <= 1'b0;
            tx_busy   <= 1'b0;

        end

        ST_FIFO_READ:
        begin

            // Generate one clock read pulse
            tf_ren <= 1'b1;

        end


      
        ST_CAPTURE:
        begin

            //--------------------------------------------------
            // Capture FIFO data into internal register
            //--------------------------------------------------
        packet_reg <= tf_rdata;

            //--------------------------------------------------
    // Start sending from lower 16 bits
    //--------------------------------------------------
    word_cnt <= 2'd0;

            //--------------------------------------------------
            // Fixed ATB information
            //--------------------------------------------------
          //  atid_o    <= ATID_VALUE;

            // 64-bit data = 8 valid bytes
          //  atbytes_o <= 3'b111;

            //--------------------------------------------------
            // Do NOT drive ATDATA here.
            // Do NOT assert ATVALID here.
            // Both are handled only in ST_SEND.
            //--------------------------------------------------

        end
        
    /* ST_SEND:
        begin

            //--------------------------------------------------
            // Drive ATB Bus
            //--------------------------------------------------
            atdata_o  <= packet_reg;



            atvalid_o <= 1'b1;

            //--------------------------------------------------
            // Transmission Status
            //--------------------------------------------------
            tx_busy <= 1'b1;

            //--------------------------------------------------
            // Receiver Accepted Packet
            //--------------------------------------------------
            if(atvalid_o && atready_i)
            begin

                // Handshake completed
                tx_busy <= 1'b0;

                // If no more packets remain, remove VALID.
                // Otherwise the next packet will be loaded
                // through FIFO_READ -> CAPTURE -> SEND.
                if(tf_rempty)
                    atvalid_o <= 1'b0;

            end

        end */

ST_SEND:
begin

    //--------------------------------------------------
    // Send one 16-bit portion of the 64-bit packet
    //--------------------------------------------------
    case(word_cnt)
        2'd0: atdata_o <= packet_reg[15:0];
        2'd1: atdata_o <= packet_reg[31:16];
        2'd2: atdata_o <= packet_reg[47:32];
        2'd3: atdata_o <= packet_reg[63:48];
    endcase

    atvalid_o <= 1'b1;
    tx_busy   <= 1'b1;

    //--------------------------------------------------
    // Receiver accepted current 16-bit word
    //--------------------------------------------------
    if(atvalid_o && atready_i)
    begin

        if(word_cnt == 2'd3)
        begin
            word_cnt <= 2'd0;
            tx_busy  <= 1'b0;

            if(tf_rempty)
                atvalid_o <= 1'b0;
        end
        else
        begin
            word_cnt <= word_cnt + 1'b1;
        end

    end

end


        //------------------------------------------------------
        // FLUSH
        //------------------------------------------------------
        ST_FLUSH:
        begin
              afready_o <= 1'b0;    // default
            //--------------------------------------------------
            // Flush is complete only after:
            // 1. FIFO becomes empty
            // 2. No packet is currently being transmitted
            //--------------------------------------------------
            if(tf_rempty && !tx_busy)


            begin

                afready_o      <= 1'b1;
                flush_pending  <= 1'b0;
                   tx_busy        <= 1'b0;
            end

        end


        //------------------------------------------------------
        // Default
        //------------------------------------------------------
        default:
        begin

            atvalid_o <= 1'b0;
            tx_busy   <= 1'b0;

        end

        endcase

    end

end
//==============================================================
// Next State Logic
//==============================================================

always @(*)
begin

    //----------------------------------------------------------
    // Default
    //----------------------------------------------------------
    next_state = current_state;

    case(current_state)

    //----------------------------------------------------------
    // IDLE
    //----------------------------------------------------------
    ST_IDLE:
    begin

        if(flush_pending)
        begin
            next_state = ST_FLUSH;
        end
        else if(!tf_rempty)
        begin
            next_state = ST_FIFO_READ;
        end
        else
        begin
            next_state = ST_IDLE;
        end

    end


    //----------------------------------------------------------
    // FIFO READ
    //----------------------------------------------------------
    ST_FIFO_READ:
    begin

        // Wait one clock for FIFO output
        next_state = ST_CAPTURE;

    end


    //----------------------------------------------------------
    // CAPTURE
    //----------------------------------------------------------
    ST_CAPTURE:
    begin

        // Packet is now stored in packet_reg
        next_state = ST_SEND;

    end


    //----------------------------------------------------------
    // SEND
    //----------------------------------------------------------
   /* ST_SEND:
    begin

        //------------------------------------------------------
        // Wait until receiver accepts packet
        //------------------------------------------------------
        if(atvalid_o && atready_i)
        begin

            //--------------------------------------------------
            // Flush Mode
            //--------------------------------------------------
            if(flush_pending)
            begin

                if(!tf_rempty)
                    next_state = ST_FIFO_READ;
                else
                    next_state = ST_FLUSH;

            end

            //--------------------------------------------------
            // Normal Mode
            //--------------------------------------------------
            else
            begin

                if(!tf_rempty)
                    next_state = ST_FIFO_READ;
                else
                    next_state = ST_IDLE;

            end

        end
        else
        begin

            // Receiver not ready
            next_state = ST_SEND;

        end

    end */


    ST_SEND:
begin

    if(atvalid_o && atready_i)
    begin

        //--------------------------------------------------
        // Still sending the same 64-bit FIFO word
        //--------------------------------------------------
        if(word_cnt != 2'd3)
        begin
            next_state = ST_SEND;
        end

        //--------------------------------------------------
        // Last 16-bit word sent
        //--------------------------------------------------
        else
        begin

            if(flush_pending)
            begin
                if(!tf_rempty)
                    next_state = ST_FIFO_READ;
                else
                    next_state = ST_FLUSH;
            end
            else
            begin
                if(!tf_rempty)
                    next_state = ST_FIFO_READ;
                else
                    next_state = ST_IDLE;
            end

        end

    end
    else
    begin
        next_state = ST_SEND;
    end

end


    //----------------------------------------------------------
    // FLUSH
    //----------------------------------------------------------
    ST_FLUSH:
    begin

        if(!tf_rempty)
        begin
            next_state = ST_FIFO_READ;
        end
        else if(tf_rempty && !tx_busy)
        begin
            next_state = ST_IDLE;
        end
        else
        begin
            next_state = ST_FLUSH;
        end

    end


    //----------------------------------------------------------
    // Default
    //----------------------------------------------------------
    default:
    begin
        next_state = ST_IDLE;
    end

    endcase

end
//==============================================================
// Optional Debug Messages
//==============================================================

// synthesis translate_off

always @(posedge atclk)
begin

    //----------------------------------------------------------
    // Successful ATB Transfer
    //----------------------------------------------------------
    if(atvalid_o && atready_i)
    begin

        $display("[%0t] ATB Packet Sent", $time);
        $display("         DATA    = %h", atdata_o);
      /*  $display("         ATID    = %0d", atid_o);
        $display("         BYTES   = %0d", atbytes_o); */

    end


    //----------------------------------------------------------
    // Flush Completed
    //----------------------------------------------------------
    if(afready_o)
    begin

        $display("[%0t] ATB Flush Completed", $time);

    end

end

// synthesis translate_on


endmodule
