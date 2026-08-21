//`timescale 1ns/1ps
//
// all the inputs are actually 256, but for our reuiremnt they are changed to
// the 64 bits
module inst_trace_enformat3_mux(
    input   [63:0]          subformat0          ,
    input                   sf0_valid_i         ,
    input   [63:0]          subformat1          ,
    input                   sf1_valid_i         ,
    input   [63:0]          subformat2          ,
    input                   sf2_valid_i         ,
    input   [63:0]          subformat3          ,
    input                   sf3_valid_i         ,
    input   [63:0]          format2_i           ,
    input                   format2_valid_i     ,
    input   [63:0]          format1_i           ,
    input                   format1_valid_i     ,
    input                   clk                 ,
    input                   rst_n               ,
    output  reg [63:0]      packet_format3      ,
    output  reg             packet_f3_valid
);

//Internal register declaration
//reg [255:0]  packet_format3_temp;//Temparory register for storing packet
//original decalration
//reg [63:0] packet_format3_temp; // updated declaration to the 64 bits
//reg     packet_f3_valid_temp    ;
//reg     packet_f3_valid_reg1    ;
//reg     packet_f3_valid_reg2    ;
//reg     packet_f3_valid_reg3    ;

always@(posedge clk or negedge rst_n)//Changing seq. logic to combo
begin
    if(!rst_n)
    begin
//        packet_format3_temp <= 256'b0   ; // original value for the reset
        packet_format3 <= 64'b0; // updated default reset bit width
        packet_f3_valid     <= 1'b0     ;
    end
    else
    begin
        case({sf3_valid_i, sf2_valid_i, sf1_valid_i, sf0_valid_i, format2_valid_i, format1_valid_i})
           6'b000100 :  begin
                            packet_format3 <= subformat0   ;
                            packet_f3_valid     <= sf0_valid_i  ;
                        end
           6'b001000 :  begin
                            packet_format3 <= subformat1   ;
                            packet_f3_valid     <= sf1_valid_i  ;
                        end
           6'b010000 :  begin
                            packet_format3 <= subformat2   ;
                            packet_f3_valid     <= sf2_valid_i  ;
                        end
           6'b100000 :  begin
                            packet_format3 <= subformat3   ;
                            packet_f3_valid     <= sf3_valid_i  ;
                        end
           6'b000010 :  begin
                            packet_format3 <= format2_i   ;
                            packet_f3_valid     <= format2_valid_i  ;
                        end
           6'b000001 :  begin
                            packet_format3 <= format1_i   ;
                            packet_f3_valid     <= format1_valid_i  ;
                        end
            default :   begin
//                            packet_format3 <= packet_format3;
                            packet_f3_valid     <= 1'b0         ;
                        end
        endcase
    end
end 

/*
always@(posedge clk or negedge rst_n)//Changing seq. logic to combo
begin
    if(!rst_n)
    begin
//        packet_format3_temp <= 256'b0   ; // original value for the reset
        packet_format3_temp <= 64'b0; // updated default reset bit width
        packet_f3_valid_temp     <= 1'b0     ;
    end
    else
    begin
        case({sf3_valid_i, sf2_valid_i, sf1_valid_i, sf0_valid_i, format2_valid_i, format1_valid_i})
           6'b000100 :  begin
                            packet_format3_temp <= subformat0   ;
                            packet_f3_valid_temp     <= sf0_valid_i  ;
                        end
           6'b001000 :  begin
                            packet_format3_temp <= subformat1   ;
                            packet_f3_valid_temp     <= sf1_valid_i  ;
                        end
           6'b010000 :  begin
                            packet_format3_temp <= subformat2   ;
                            packet_f3_valid_temp     <= sf2_valid_i  ;
                        end
           6'b100000 :  begin
                            packet_format3_temp <= subformat3   ;
                            packet_f3_valid_temp     <= sf3_valid_i  ;
                        end
           6'b000010 :  begin
                            packet_format3_temp <= format2_i   ;
                            packet_f3_valid_temp     <= format2_valid_i  ;
                        end
           6'b000001 :  begin
                            packet_format3_temp <= format1_i   ;
                            packet_f3_valid_temp     <= format1_valid_i  ;
                        end
            default :   begin
                            packet_format3_temp <= packet_format3_temp;
                            packet_f3_valid_temp     <= 1'b0         ;
                        end
        endcase
    end
end 


//Delay for valid signal required for generating valid for 4 clock cycles
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        packet_f3_valid_reg1    <= 1'b0 ;
        packet_f3_valid_reg2    <= 1'b0 ;
        packet_f3_valid_reg3    <= 1'b0 ;
    end
    else
    begin
        packet_f3_valid_reg1    <= packet_f3_valid_temp      ;
        packet_f3_valid_reg2    <= packet_f3_valid_reg1 ;
        packet_f3_valid_reg3    <= packet_f3_valid_reg2 ;
    end
end

//Sending packet(64 bits) according to valid along with valid signal
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        packet_f3_valid     <= 1'b0 ;
        packet_format3      <= 64'b0;
    end
    else
    begin
        case({packet_f3_valid_temp, packet_f3_valid_reg1, packet_f3_valid_reg2, packet_f3_valid_reg3})
            4'b1000 :   begin
                            packet_f3_valid     <= packet_f3_valid_temp ;
                            packet_format3      <= packet_format3_temp[63:0];
                        end
            4'b0100 :   begin
                            packet_f3_valid     <= packet_f3_valid_reg1 ;
                            packet_format3      <= packet_format3_temp[127:64];
                        end
            4'b0010 :   begin
                            packet_f3_valid     <= packet_f3_valid_reg2 ;
                            packet_format3      <= packet_format3_temp[191:128];
                        end
            4'b0001 :   begin
                            packet_f3_valid     <= packet_f3_valid_reg3 ;
                            packet_format3      <= packet_format3_temp[255:192];
                        end
            default :   begin
                            packet_f3_valid     <= packet_f3_valid_reg3 ;
                            packet_format3      <= packet_format3_temp[255:192];
                        end
        endcase
    end
end

*/

endmodule
