//This packet provides supporting information to aid the decoder.
//`timescale 1ns/1ps

module inst_trace_enformat3_sf3(
input       [3:0]   itype_in        ,
input               ienable_in      , //Signal from control interface registers
input               f3_subformat3_en,
input               clk             ,
input               rst_n           ,
input               sf3_trace_en    ,
input               valid_itype     ,//Valid signal coming from core indictating info signals are valid
//output reg [255:0]  subformat3      , // orginal width
output reg [63:0]   subformat3      ,// updated the width to the 64 bits
output reg          sf3_valid
);

//parameter declaration
//parameter HEADER_FIELD      = 8'b00001000   ; // original HEADER_FIELD value
parameter HEADER_FIELD      = 3'b101        ; // updated HEADER_FIELD value

// to adjust the data fit it into the 64 bits, constant fileds are removed,
// but instead of this constants headerfield can be used to identify it
// parameter FORMAT_FIELD      = 2'b11         ;
// parameter SUBFORMAT_FIELD   = 2'b11         ;

wire branch_tmp;
//wire [255:0] subformat3_tmp; //packet temparay wire, orginal decalaration
wire [63:0]  subformat3_tmp; // updated 64 bit decalaration
wire [1:0] qual_status;

assign branch_tmp = (itype_in == 4'b0101);
assign qual_status = 2'b0;

// original assignment for 256 bit width
//assign subformat3_tmp = {{240{1'b0}},qual_status,branch_tmp,ienable_in,
//                          SUBFORMAT_FIELD,FORMAT_FIELD,HEADER_FIELD};

// updated for the 64 bit assignment
assign subformat3_tmp = {{57{1'b0}},qual_status,branch_tmp,ienable_in,
                          HEADER_FIELD};


always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
//        subformat3 <= 256'b0; // orignal default reset value
        subformat3  <= 64'b0;
        sf3_valid  <= 1'b0;
    end
    else
    begin
        if(f3_subformat3_en && sf3_trace_en && valid_itype)
        begin
            subformat3 <= subformat3_tmp;
            sf3_valid <= sf3_trace_en;
        end else begin
            subformat3 <= subformat3_tmp;
            sf3_valid <= 1'b0;
        end
    end
end
               
endmodule
