`timescale 1ns/1ps
module trace_fifo #(parameter DATA_WIDTH = 64,
                    parameter ADDR_WIDTH = 8,  
                    parameter FIFO_DEPTH = 1 << ADDR_WIDTH)
( 
    input                           tf_wclk    ,//write clk
    input                           tf_wen     ,//write enable
    input                           tf_wrst_n  ,
    input       [DATA_WIDTH-1:0]    tf_wdata   ,
    input                           tf_rclk    ,//read clk
    input                           tf_ren     ,//read enable
    input                           tf_rrst_n  ,
    output  reg [DATA_WIDTH-1:0]    tf_rdata   ,

    output  reg                     tf_wfull   ,
    output  reg                     tf_rempty   
    //output                          tf_spi_en  //enable for spi master interface

);

reg    [ADDR_WIDTH : 0]  rptr, wptr;
reg     [ADDR_WIDTH : 0]  wq1_rptr, wq2_rptr, rq1_wptr, rq2_wptr;

wire    [ADDR_WIDTH-1 :0]   raddr, waddr;//read and write addresses for memory

wire    rempty_w;
reg     [ADDR_WIDTH : 0]    rbin;
wire    [ADDR_WIDTH : 0]    rbinnext, rgraynext;

wire    wfull_w;
reg     [ADDR_WIDTH:0]    wbin;
wire    [ADDR_WIDTH:0]    wgraynext, wbinnext;

//reg     tf_rempty_reg;

reg     tf_ren_reg;
wire     ren_posedge;

//----------------------------------------------------------------------------------
//Posedge detection for read_enable because spi transfers only 1 data for 1 cycle
//----------------------------------------------------------------------------------
always@(posedge tf_rclk or negedge tf_rrst_n)
begin
    if(!tf_rrst_n)
        tf_ren_reg <=  1'b0;
    else
        tf_ren_reg <=  tf_ren;
end
assign ren_posedge = tf_ren & (~tf_ren_reg);


//----------------------------------------------------------------------------------
//FIFO Memory logic
//----------------------------------------------------------------------------------
reg [DATA_WIDTH-1:0] mem [FIFO_DEPTH-1:0];

//fifo write logic

//fifo write logic

always @(posedge tf_wclk)
begin
    if (tf_wen && (!tf_wfull))
    begin
        mem[waddr] <= tf_wdata;

//        $display("[%0t] FIFO WRITE", $time);
//        $display("        waddr   = %0d", waddr);
//        $display("        tf_wdata= %h", tf_wdata);
    end
end


//fifo read logic
always @(posedge tf_rclk)  //@(*)
begin
    if (/*tf_ren*/ ren_posedge /*&& !tf_rempty*/)//rempty commented because it is not reading until empty goes low
        tf_rdata <= mem[raddr];
    //else 
        //tf_rdata <= 'b0;
end




//----------------------------------------------------------------------------------
//Synchronizers logic
//----------------------------------------------------------------------------------

//2-ff synchronizer in write clk
always @(posedge tf_wclk or negedge tf_wrst_n)
begin
    if (!tf_wrst_n) 
        {wq2_rptr,wq1_rptr} <= 18'b0;
    else 
        {wq2_rptr,wq1_rptr} <= {wq1_rptr,rptr};
end

//2-ff synchronizer in read clk
always @(posedge tf_rclk or negedge tf_rrst_n)
begin
    if (!tf_rrst_n) 
        {rq2_wptr,rq1_wptr} <= 18'b0;
    else 
        {rq2_wptr,rq1_wptr} <= {rq1_wptr,wptr};
end




//----------------------------------------------------------------------------------
//Binary and gray counter logic wrt rclk
//----------------------------------------------------------------------------------
always @(posedge tf_rclk or negedge tf_rrst_n)
    if (!tf_rrst_n) 
        {rbin, rptr} <= 18'b0;
    else 
        {rbin, rptr} <= {rbinnext, rgraynext};

// Memory read-address pointer (use binary to address memory)
assign raddr = rbin[ADDR_WIDTH-1:0];
assign rbinnext = rbin + (/*tf_ren*/ ren_posedge & ~tf_rempty);
assign rgraynext = (rbinnext>>1) ^ rbinnext;


// FIFO empty when the next rptr == synchronized wptr or on reset
assign rempty_w = (rgraynext == rq2_wptr);

always @(posedge tf_rclk or negedge tf_rrst_n)
begin
    if (!tf_rrst_n) 
        tf_rempty <= 1'b1;
    else 
        tf_rempty <= rempty_w;
end




//----------------------------------------------------------------------------------
//Binary and gray counter logic wrt wclk
//----------------------------------------------------------------------------------
always @(posedge tf_wclk or negedge tf_wrst_n)
begin
    if (!tf_wrst_n) 
        {wbin, wptr} <= 18'b0;
    else 
        {wbin, wptr} <= {wbinnext, wgraynext};
end

// Memory write-address pointer (use binary to address memory)
assign waddr = wbin[ADDR_WIDTH-1:0];
assign wbinnext = wbin + (tf_wen & ~tf_wfull);
assign wgraynext = (wbinnext>>1) ^ wbinnext;


//FIFO full condition
assign wfull_w = (wgraynext=={~wq2_rptr[ADDR_WIDTH:ADDR_WIDTH-1], wq2_rptr[ADDR_WIDTH-2:0]});

always @(posedge tf_wclk or negedge tf_wrst_n)
begin
    if (!tf_wrst_n) 
        tf_wfull <= 1'b0;
    else 
        tf_wfull <= wfull_w;
end




//----------------------------------------------------------------------------------
//Negedge detection of empty signal for tx_ready signal in spi master interface
//----------------------------------------------------------------------------------
/*always@(posedge tf_rclk or negedge tf_rrst_n)
begin
    if(!tf_rrst_n)
        tf_rempty_reg <= 1'b0;
    else
        tf_rempty_reg <= tf_rempty;
end
assign tf_spi_en = tf_rempty_reg & (~tf_rempty);    */

endmodule
