//Sent following an exception or interrupt, along with cause
//`timescale 1ns/1ps

module inst_trace_enformat3_sf1(
    input       [3:0]   itype_in            ,
//    input       [2:0]   priv_in             ,
    input       [1:0]   context_in          , // previous 3 bits are there, reducing to the 2 bits, we only have 3 scenarios here
    input       [7:0]   cause_in            ,
    input       [15:0]  iaddr_in            , // previous 20 bit reducing to the 16 bit, because of the unused bits
    input               f3_subformat1_en    ,
    input       [31:0]  tval_in             , // exception instructions are passing becuase of mtvalue is constant, it increases to the 32 bits from 20 bits
    input               itype_valid         ,
    input               clk                 ,
    input               rst                 ,
    input               sf1_trace_en        ,
//    output reg  [255:0] subformat1          ,  // original width
    output reg  [63:0]  subformat1           ,   // updated 64 bit width, and also reduced HEADER_FIELD value including bit width
    output reg          sf1_valid
);

//parameter declaration
//parameter HEADER_FIELD = 8'b01000100; // original HEADER_FIELD value
parameter HEADER_FIELD = 3'b011; // updated HEADER_FIELD value to fit into the 64 bit

// to adjust the data fit it into the 64 bits, constant fileds are removed,
// but instead of this constants headerfield can be used to identify it
//parameter FORMAT_FIELD = 2'b11;
//parameter SUBFORMAT_FIELD = 2'b01;

wire branch_tmp;
wire interrupt_tmp;
//wire thaddr_tmp;
//wire [255:0] subformat1_tmp; //packet temparay wire
wire [63:0]  subformat1_tmp;    // updated bit width for the 64 bit


assign branch_tmp = (itype_in == 4'b0101);
assign interrupt_tmp = (itype_in == 4'b0010);
//assign thaddr_tmp = iaddr_in[19]; // removed, because exception or trap
//handler is passing thorugh the context

// original format with 256 bit width
//assign subformat1_tmp = {{187{1'b0}},tval_in,iaddr_in,thaddr_tmp,interrupt_tmp,cause_in,
//                           context_in, priv_in, branch_tmp,SUBFORMAT_FIELD,FORMAT_FIELD,HEADER_FIELD};

assign subformat1_tmp = {1'b0,tval_in,iaddr_in,interrupt_tmp,cause_in,
                           context_in, branch_tmp,HEADER_FIELD};

always @(posedge clk or negedge rst)
begin
    if(!rst)
    begin
//        subformat1 <= 256'b0;
        subformat1 <= 64'b0;  // updated bit width for 64
        sf1_valid <= 1'b0;
    end
    else
    begin
        if(f3_subformat1_en && sf1_trace_en)
        /*   subformat1 <= 68'b0;
        else   */
   begin
            subformat1 <= subformat1_tmp;
            sf1_valid <= itype_valid;
    end
    else begin
        subformat1    <= subformat1_tmp;
        sf1_valid     <= 1'b0;
    end
    end
end

endmodule
