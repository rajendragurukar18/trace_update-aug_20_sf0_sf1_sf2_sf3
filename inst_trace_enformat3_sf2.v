//when the context value changes and can be reported imprecisely
//`timescale 1ns/1ps

module inst_trace_enformat3_sf2(
// input         [2:0]    priv_in             ,
 input         [1:0]    context_in          , // previous 3 bits are there, reducing to the 2 bits, we only have 3 scenarios here
 input                  f3_subformat2_en    ,
 input                  clk                 ,
 input                  rst_n                 ,
 input                  sf2_trace_en        ,
 input                  valid_con           ,//Valid signal coming from core indictating info signals are valid
// output reg    [255:0]  subformat2          , //original decalration
 output reg    [63:0]   subformat2          , // updated declaration for the 64 bit width
 output reg             sf2_valid
 );

//parameter declaration
//parameter HEADER_FIELD       = 8'b00001010  ; // original HEADER_FIELD value
parameter HEADER_FIELD       = 3'b100       ; // updated HEADER_FIELD value to fit into 64 bits

// to adjust the data fit it into the 64 bits, constant fileds are removed,
// but instead of this constants headerfield can be used to identify it
// parameter FORMAT_FIELD       = 2'b11        ;
// parameter SUBFORMAT_FIELD    = 2'b10        ;

//wire [255:0] subformat2_tmp; //packet temparay wire
wire [63:0]  subformat2_tmp; // bit width updated to 64

// original assignment
//assign subformat2_tmp = {{238{1'b0}},context_in,priv_in,SUBFORMAT_FIELD, FORMAT_FIELD,
//                          HEADER_FIELD};

// updated assignment for 64 bit
assign subformat2_tmp = {{59{1'b0}},context_in,HEADER_FIELD};


always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
//        subformat2 <= 256'b0; //original value
        subformat2 <= 64'b0;
        sf2_valid <= 1'b0;
    end
    else
    begin 
        if(f3_subformat2_en && sf2_trace_en && valid_con)
        begin
            subformat2 <= subformat2_tmp;
            sf2_valid <= sf2_trace_en;
        end
        else begin
            subformat2 <= subformat2_tmp;
            sf2_valid <= 1'b0;
        end
    end
end
endmodule
