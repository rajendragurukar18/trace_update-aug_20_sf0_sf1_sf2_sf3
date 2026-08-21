//For first traced Instruction or first instruction after trace timer expiry
//`timescale 1ns/1ps

module inst_trace_enformat3_sf0(
    input       [3:0]   itype_in                ,
    input               first_instruction_valid ,//For first traced Instruction or first instruction after trace timer expiry
//    input       [2:0]   priv_in                 ,
    input       [1:0]   context_in              , // previous 3 bits are there, reducing to the 2 bits, we only have 3 scenarios here
    input       [15:0]  iaddr_in                , // previous 20 bit reducing to the 16 bit, because of the unused bits
    input               f3_subformat0_en        ,
    input               sf0_trace_en            ,//Trace enable signal from control register
    input               clk                     ,
    input               rst                     ,
//    output reg  [255:0] subformat0              , // original declaration
    output reg  [63:0]  subformat0              , // updated the format width to 64 bit, and reduced the HEADER_FIELD
    output reg          sf0_valid
);

//parameter declaration
//parameter HEADER_FIELD = 8'b00011110    ; // original HEADER_FIELD value 
parameter HEADER_FIELD = 3'b010         ; // updated HEADER_FIELD value to fit it in 64 bits

// to adjust the data fit it into the 64 bits, constant fileds are removed or
// commented,but instead of this constants headerfield can be used to identify it
// parameter FORMAT_FIELD = 2'b11          ;
// parameter SUBFORMAT_FIELD = 2'b00       ;

//reg [3:0]itype_tmp;
//reg [1:0]context_tmp;
//reg [2:0]priv_tmp;
//reg [19:0]addr_tmp;

wire branch_tmp             ;
//wire [255:0] subformat0_tmp ;//packet temparay wire, original decalaration
wire [63:0]  subformat0_tmp ; // updated the decalration by changeing the bit width

//latching of itype values
/*always@(posedge clk or negedge rst)
   begin
        if(~rst)
             itype_tmp <= 4'b0000;
        else
             itype_tmp <= itype_in[3:0];
   end
*/

//setting the branch field
/*always@(posedge clk or negedge rst)
    begin
        if(~rst)
            branch_tmp <= 1'b0;

        else if(itype_in==4'b0101)
            branch_tmp <= 1'b1;

        else
            branch_tmp <= 1'b0;
    end */

assign branch_tmp = (itype_in == 4'b0101);

//assigning priv,address,context fields
/*always@(posedge clk or negedge rst)
    begin
        if(~rst)
           begin
                priv_tmp <= 3'b00;
                context_tmp <= 2'b00;
                addr_tmp <= 20'h00000;
           end
        else
             begin
                priv_tmp <= priv_in;
                context_tmp <= context_in;
                addr_tmp <= iaddr_in;
             end
    end     */

// orignal format assignment
//assign subformat0_tmp = {{217{1'b0}},iaddr_in, context_in,priv_in, branch_tmp,
//                           SUBFORMAT_FIELD,FORMAT_FIELD,HEADER_FIELD};

// updated format for the 64 bit
assign subformat0_tmp = {{42{1'b0}},iaddr_in, context_in, branch_tmp,
                           HEADER_FIELD};


always @(posedge clk or negedge rst)
begin
    if(!rst)
    begin
//        subformat0 <= 256'b0; 
        subformat0 <= 64'b0; // width is updated
        sf0_valid <= 1'b0;
    end
    else 
    begin 
       if(f3_subformat0_en && sf0_trace_en && first_instruction_valid)
       /*    subformat0 <= 38'b0;
       else*/
       begin
           subformat0 <= subformat0_tmp;
           sf0_valid <= first_instruction_valid;
       end
       else
       begin
           subformat0 <= subformat0;
           sf0_valid <= 1'b0;
       end
    end
end

endmodule
