//`timescale 1ns/1ps
module inst_trace_enformat1(
    input      [19:0]   if1_del_addr_in     ,
    input               if1_addr_valid_i    ,
    input               if1_trace_en        ,
    input               format1_en          ,
    input      [30:0]   branch_map_i        ,
    input               clk                 ,
    input               rst_n               ,
//    output reg [255:0]  format1             ,  // original width
    output reg [63:0]   format1             , // for the 64 bit, reduced the header field
    output reg          format1_valid   
);

//parameter declaration
//parameter HEADER_FIELD = 8'b00011111;   // original HEADER_FIELD value
parameter HEADER_FIELD = 3'b000;        // updated HEADER_FIELD value to make it 64 bits as output
parameter FORMAT_FIELD = 2'b01;
parameter [4:0] BRANCHES = 5'b11111;//Total branches possible in a block (set to maximum possible i.e 32)

//Internal wire decaration
//wire [255:0] format1_tmp    ; //packet temparay wire, orignal declaration 
wire [63:0]  format1_tmp    ; // updated the declaration for the 64 bit
wire         notify         ;
wire         updiscon       ;
wire         irreport       ;

//notify, updiscon, irreport logic
assign notify   = if1_del_addr_in[19] ;
assign updiscon = notify              ;
assign irreport = updiscon            ;

//temportaory packet format logic, original logic
//assign format1_tmp = {{187{1'b0}}, irreport, updiscon, notify, if1_del_addr_in,
//                       branch_map_i, BRANCHES, FORMAT_FIELD, HEADER_FIELD};

// updated logic for the 64 bit as output
assign format1_tmp = { irreport, updiscon, notify, if1_del_addr_in,
                       branch_map_i, BRANCHES, FORMAT_FIELD, HEADER_FIELD};

                     
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
//     format1 <= 256'b0;
     format1 <= 64'b0;
     format1_valid <= 1'b0;
    end
    else 
    begin
        if(if1_trace_en && format1_en && if1_addr_valid_i)
        begin
            format1 <= format1_tmp;
            format1_valid <= if1_addr_valid_i;
        end
    end
end
endmodule
