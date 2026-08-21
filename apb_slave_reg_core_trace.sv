
// cdc, all the inputs and output signals are registered
module apb_slave_reg_core_trace #(
  parameter ADDR_WIDTH = 8,
  parameter DATA_WIDTH = 32
//  parameter REGISTER_WIDTH = 3
)(
  // APB Interface
  input  logic                     pclk_i,
  input  logic                     presetn_i,
  input  logic [ADDR_WIDTH-1:0]    paddr_i,
  input  logic                     psel_i,
  input  logic                     penable_i,
  input  logic                     pwrite_i,
  input  logic                     pwdata_i,
  output logic [DATA_WIDTH-1:0]    prdata_o,
  output logic                     pready_o,
  output logic                     pslverr_o,
 
  // Control registers output
//  output logic [DATA_WIDTH-1:0]    clk_ctrl_reg_o,
  output logic     core_trace_ctrl_reg_o
 
  // Status input from DUT
//  input  logic [5:0]    clk_rst_ctrl_status_i
);


//  localparam [REGISTER_WIDTH-1:0] DEFAULT_PER_VALUE = 'hC;
//  localparam [REGISTER_WIDTH-1:0] DEFAULT_DEBUG_VALUE = 'hA;
 
  // -------------------------------------------------
  // Address Map
  // -------------------------------------------------
//  localparam ADDR_CLK_CTRL      = {ADDR_WIDTH{1'b0}};
  localparam ADDR_CORE_TRACE_CTRL    = {{ADDR_WIDTH-4{1'b0}},4'h0};

  // -------------------------------------------------
  // Internal Registers
  // -------------------------------------------------
//  logic [DATA_WIDTH-1:0] clk_ctrl_q;
  logic core_trace_reg_ctrl_q;



  logic psel_q;
  logic penable_q;
  logic [ADDR_WIDTH-1:0] paddr_q;
//  logic [DATA_WIDTH-1:0] pwdata_q;
  logic pwrite_q;

//  logic [5:0] clk_rst_ctrl_status_q;
  
  always_ff@(posedge pclk_i or negedge presetn_i) begin
    if(!presetn_i) begin
        psel_q <= 1'b0;
        penable_q <= 1'b0;
        paddr_q <= {ADDR_WIDTH{1'b0}};
//        pwdata_q <= 0;
        pwrite_q <= 1'b0;
//        clk_rst_ctrl_status_q <= 6'b0;
    end else begin
        psel_q <= psel_i;
        penable_q <= penable_i;
        paddr_q <= paddr_i;
//        pwdata_q <= pwdata_i;
        pwrite_q <= pwrite_i;
//        clk_rst_ctrl_status_q <= clk_rst_ctrl_status_i;
    end
  end


  // -------------------------------------------------
  // APB Control Signals
  // -------------------------------------------------
  logic write_en;
//  logic read_en;
  logic access_en;
 
  assign write_en  = psel_q & penable_q & pwrite_q;
//  assign read_en   = psel_q & ~pwrite_q;
  assign access_en = psel_q & penable_q;
 
  // -------------------------------------------------
  // Address Decode
  // -------------------------------------------------
  logic addr_valid;
 
  always_comb begin
    case (paddr_q)
      ADDR_CORE_TRACE_CTRL : addr_valid = 1'b1;
      default     : addr_valid = 1'b0;
    endcase
  end
 
  // -------------------------------------------------
  // APB Response
  // -------------------------------------------------
  always_ff@(posedge pclk_i or negedge presetn_i) begin
    if(!presetn_i) begin
        pready_o <= 1'b0;
    end else if((psel_q & penable_q) & (psel_i & penable_i))begin
        pready_o <= 1'b1;
    end else begin
        pready_o <= 1'b0;
    end
  end
  
//  assign pready_o = psel_i & penable_i;
 
  // Slave error conditions:
  // 1. Invalid address access
  // 2. Write to read-only register (STATUS)
 
//  logic write_to_ro;
 
//  assign write_to_ro = write_en && (paddr_q == ADDR_STATUS);

  always_ff@(posedge pclk_i or negedge presetn_i) begin
    if(!presetn_i) begin
        pslverr_o <= 1'b0;
    end else if((access_en &&  !addr_valid) && psel_i && penable_i) begin
        pslverr_o <= 1'b1;
    end else begin
        pslverr_o <= 1'b0;
    end
  end
 
//  assign pslverr_o = access_en && ( !addr_valid || write_to_ro );

//  always_ff@(posedge pclk_i or negedge presetn_i) begin
//    if(!presetn_i) begin
//        mux_sync_ctrl_q <= 1'b0;
//    end else if(write_en) begin
//        case(paddr_q)
//          ADDR_CLK_DIV_PER_CTRL,
//          ADDR_CLK_DIV_DEBUG_CTRL,
//          ADDR_CORE_TRACE_CTRL       : mux_sync_ctrl_q <= 1'b1;
//          default             : mux_sync_ctrl_q <= 1'b0;
//        endcase
//    end
//  end
 
  // -------------------------------------------------
  // CONTROL Register (RW)
  // -------------------------------------------------
  always_ff @(posedge pclk_i or negedge presetn_i) begin
    if(!presetn_i) begin
//      clk_ctrl_q            <= {DATA_WIDTH{1'b0}};
      core_trace_reg_ctrl_q    <= 1'b0; //{1'b1,{DATA_WIDTH-5{1'b0}},4'h4}; // divider enabled by default for peripheral
//      clk_div_debug_ctrl_q  <= DEFAULT_DEBUG_VALUE; //{1'b1,{DATA_WIDTH-5{1'b0}},4'h2};
//      rst_ctrl_q            <= 3'b0; //{{DATA_WIDTH-4{1'b0}},4'h0}; // releases resets by default
    end
    else if(write_en) begin
      case(paddr_q)
//        ADDR_CLK_CTRL       : clk_ctrl_q           <= pwdata_i;
//        ADDR_CLK_DIV_PER_CTRL    : clk_div_per_ctrl_q   <= {pwdata_i[31],pwdata_i[REGISTER_WIDTH-2:0]};
//        ADDR_CLK_DIV_DEBUG_CTRL  : clk_div_debug_ctrl_q <= {pwdata_i[31],pwdata_i[REGISTER_WIDTH-2:0]};
        ADDR_CORE_TRACE_CTRL            : core_trace_reg_ctrl_q           <= pwdata_i;
        default                  : begin
                               core_trace_reg_ctrl_q <= core_trace_reg_ctrl_q;
//                               clk_div_debug_ctrl_q <= clk_div_debug_ctrl_q;
//                               rst_ctrl_q           <= rst_ctrl_q;
                              end
      endcase
    end
  end  

//  assign clk_ctrl_reg_o = clk_ctrl_q;
  assign core_trace_ctrl_reg_o    = core_trace_reg_ctrl_q;
//  assign clk_div_debug_ctrl_o = clk_div_debug_ctrl_q;
//  assign rst_ctrl_reg_o       = rst_ctrl_q;
//  assign mux_sync_ctrl_o      = mux_sync_ctrl_q;
 
  // -------------------------------------------------
  // STATUS Register (RO)
  // -------------------------------------------------
//  always_ff @(posedge pclk_i or negedge presetn_i) begin
//    if (!presetn_i) begin
//      status_q <= 6'b0;//{DATA_WIDTH{1'b0}};
//    end
//    else begin
//      status_q <= clk_rst_ctrl_status_q;
//    end
//  end
 
  // -------------------------------------------------
  // Read Data Mux
  // -------------------------------------------------
  always_ff@(posedge pclk_i or negedge presetn_i) begin
    if(!presetn_i) begin
        prdata_o <= {DATA_WIDTH{1'b0}};
    end else if(!pready_o) begin
            unique case(paddr_q)
  
                //      ADDR_CLK_CTRL : prdata_o = clk_ctrl_q;
//                      ADDR_CLK_DIV_PER_CTRL      : prdata_o <= {clk_div_per_ctrl_q[REGISTER_WIDTH-1],{DATA_WIDTH-REGISTER_WIDTH{1'b0}},clk_div_per_ctrl_q[REGISTER_WIDTH-2:0]};
//                      ADDR_CLK_DIV_DEBUG_CTRL    : prdata_o <= {clk_div_debug_ctrl_q[REGISTER_WIDTH-1],{DATA_WIDTH-REGISTER_WIDTH{1'b0}},clk_div_debug_ctrl_q[REGISTER_WIDTH-2:0]};
                      ADDR_CORE_TRACE_CTRL         : prdata_o <= {{DATA_WIDTH-1{1'b0}},core_trace_reg_ctrl_q};
//                      ADDR_STATUS           : prdata_o <= {{DATA_WIDTH-6{1'b0}},status_q};
                  
                      default               : prdata_o <= {DATA_WIDTH{1'b0}};
            endcase
    end
  end


//  always_comb begin
//    unique case(paddr_i)
//  
////      ADDR_CLK_CTRL : prdata_o = clk_ctrl_q;
//      ADDR_CLK_DIV_PER      : prdata_o = clk_div_per_ctrl_q;
//      ADDR_CLK_DIV_DEBUG    : prdata_o = clk_div_debug_ctrl_q;
//      ADDR_RST_CTRL         : prdata_o = rst_ctrl_q;
//      ADDR_STATUS           : prdata_o = status_q;
//  
//      default               : prdata_o = {DATA_WIDTH{1'b0}};
//    endcase
//  end

endmodule
