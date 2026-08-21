//This packet contains only an instruction address
//`timescale 1ns/1ps
module inst_trace_enformat2(
    input       [19:0]  delta_addr_in       ,
    input               format2_en          ,
    input               format2_trace_en    ,
    input               addr_valid          , //differential address from the core
    input               clk                 ,
    input               rst_n               ,
//    output reg  [255:0] format2             , // original declaration
    output reg  [63:0]  format2             ,   // for the 64 bit output declaration, by reducing the header field
    output reg          format2_valid        
);

wire          notify      ; 
wire          updiscon    ; 
wire          irreport    ;
//wire [255:0]  format2_tmp ; //packet temparay wire
wire [63:0]   format2_tmp ; 

//parameter declaration
//parameter HEADER_FIELD = 8'b00011001; // original HEADER_FIELD value
parameter HEADER_FIELD = 3'b001; // updated the HEADER_FIELD value to fit into 64 bits
parameter FORMAT_FIELD = 2'b10;

//notify, updiscon, irreport logic
assign notify    =   delta_addr_in[19]  ;
assign updiscon  =   notify             ;
assign irreport  =   updiscon           ;

//Temporary packet comb. logic
//assign format2_tmp = {{223{1'b0}}, irreport, updiscon, notify, delta_addr_in, FORMAT_FIELD, HEADER_FIELD};

// updated for the 64 bit value
assign format2_tmp = {{36{1'b0}}, irreport, updiscon, notify, delta_addr_in, FORMAT_FIELD, HEADER_FIELD};


always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
//        format2 <= 256'b0; orignal default value
        format2 <= 64'b0;
        format2_valid <= 1'b0;
    end
    else 
    begin
        if(format2_trace_en && format2_en && addr_valid)
        begin
            format2 <= format2_tmp;
            format2_valid <= addr_valid;
        end
    end
end

endmodule
