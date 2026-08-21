`timescale 1ns/1ps

module trace_fifo_atb_top
#(
    parameter DATA_WIDTH = 64,
    parameter ADDR_WIDTH = 8,
    parameter ATID_WIDTH = 7,
    parameter ATID_VALUE = 7'h01
)
(
    //========================================================
    // Trace Encoder (FIFO Write Side)
    //========================================================
    input                       tf_wclk,
    input                       tf_wrst_n,
    input                       tf_wen,
    input  [DATA_WIDTH-1:0]     tf_wdata,

    //========================================================
    // ATB Clock Domain (FIFO Read Side)
    //========================================================
    input                       atclk,
    input                       atresetn,

    //========================================================
    // Flush Interface
    //========================================================
    input                       afvalid_i,
    output                      afready_o,

    //========================================================
    // ATB Interface
    //========================================================
    input                       atready_i,
    output [DATA_WIDTH-1:0]     atdata_o,
    output                      atvalid_o,
    output [ATID_WIDTH-1:0]     atid_o,
    output [2:0]                atbytes_o,

    //========================================================
    // Status
    //========================================================
    output                      fifo_wfull_o
);

    //--------------------------------------------------------
    // Internal Signals
    //--------------------------------------------------------
    wire [DATA_WIDTH-1:0] fifo_rdata_w;
    wire                  fifo_rempty_w;
    wire                  fifo_ren_w;

    //--------------------------------------------------------
    // Trace FIFO
    //--------------------------------------------------------
    trace_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_trace_fifo (
        .tf_wclk    (tf_wclk),
        .tf_wen     (tf_wen),
        .tf_wrst_n  (tf_wrst_n),
        .tf_wdata   (tf_wdata),

        .tf_rclk    (atclk),
        .tf_ren     (fifo_ren_w),
        .tf_rrst_n  (atresetn),
        .tf_rdata   (fifo_rdata_w),

        .tf_wfull   (fifo_wfull_o),
        .tf_rempty  (fifo_rempty_w)
    );

    //--------------------------------------------------------
    // ATB Transmitter
    //--------------------------------------------------------
    atb_transmitter #(
        .DATA_WIDTH(DATA_WIDTH),
        .ATID_WIDTH(ATID_WIDTH),
        .ATID_VALUE(ATID_VALUE)
    ) u_atb_transmitter (
        .atclk      (atclk),
        .atresetn   (atresetn),

        // FIFO Interface
        .tf_rdata   (fifo_rdata_w),
        .tf_rempty  (fifo_rempty_w),
        .tf_ren     (fifo_ren_w),

        // Flush Interface
        .afvalid_i  (afvalid_i),
        .afready_o  (afready_o),

        // ATB Interface
        .atdata_o   (atdata_o),
        .atvalid_o  (atvalid_o),
        .atready_i  (atready_i),
        .atid_o     (atid_o),
        .atbytes_o  (atbytes_o)
    );

endmodule
