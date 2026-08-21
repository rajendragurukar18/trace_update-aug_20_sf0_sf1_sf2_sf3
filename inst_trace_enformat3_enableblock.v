//`timescale 1ns/1ps
module inst_trace_enformat3_enableblock(
    input               clk                 ,//to register context value
    input               rst_n               ,//to register context value
    input               eb_itype_valid      ,
    input       [3:0]   itype_in            ,
    input       [1:0]   eb_context_in       , // previous 3 bits are there, reducing to the 2 bits, we only have 3 scenarios here
    input               first_instrn_valid  ,//indicates first instruction is being executed
    input               wfull_fifo          ,//fifo full flag
    output  reg         f3_subformat0_en    ,
    output  reg         f3_subformat1_en    ,
    output  reg         f3_subformat2_en    ,
    output  reg         f3_subformat3_en    ,
    output  reg         format2_en
                                            );

wire        context_change;
reg [1:0]   context_reg; // previous 3 bits are there, reducing to the 2 bits, we only have 3 scenarios here

always@(*)
begin
    casex({eb_itype_valid, itype_in, first_instrn_valid, wfull_fifo, context_change})
        8'b1_xxxx_1_0_0 : begin
                              f3_subformat0_en = 1'b1;
                              f3_subformat1_en = 1'b0;
                              f3_subformat2_en = 1'b0;
                              f3_subformat3_en = 1'b0;
                              format2_en       = 1'b0;
                          end
        8'b1_0001_0_0_0 : begin
                              f3_subformat0_en = 1'b0;
                              f3_subformat1_en = 1'b1;
                              f3_subformat2_en = 1'b0;
                              f3_subformat3_en = 1'b0;
                              format2_en       = 1'b0;
                          end
        8'b1_0010_0_0_0 : begin
                              f3_subformat0_en = 1'b0;
                              f3_subformat1_en = 1'b1;
                              f3_subformat2_en = 1'b0;
                              f3_subformat3_en = 1'b0;
                              format2_en       = 1'b0;
                          end
        8'b1_xxxx_0_1_x : begin
                              f3_subformat0_en = 1'b0;
                              f3_subformat1_en = 1'b0;
                              f3_subformat2_en = 1'b0;
                              f3_subformat3_en = 1'b1;
                              format2_en       = 1'b0;
                          end
        8'b1_xxxx_0_0_1 : begin
                              f3_subformat0_en = 1'b0;
                              f3_subformat1_en = 1'b0;
                              f3_subformat2_en = 1'b1;
                              f3_subformat3_en = 1'b0;
                              format2_en       = 1'b0;
                          end
        8'b1_0101_0_0_0 : begin
                              f3_subformat0_en = 1'b0;
                              f3_subformat1_en = 1'b0;
                              f3_subformat2_en = 1'b0;
                              f3_subformat3_en = 1'b0;
                              format2_en       = 1'b1;
                          end
        8'b1_0100_0_0_0 : begin
                              f3_subformat0_en = 1'b0;
                              f3_subformat1_en = 1'b0;
                              f3_subformat2_en = 1'b0;
                              f3_subformat3_en = 1'b0;
                              format2_en       = 1'b1;
                          end       
        default : begin
                      f3_subformat0_en = 1'b0;
                      f3_subformat1_en = 1'b0;
                      f3_subformat2_en = 1'b0;
                      f3_subformat3_en = 1'b0;
                      format2_en       = 1'b0;
                  end
    endcase
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        context_reg <= 2'b0;
    else
        context_reg <= eb_context_in;
end
assign context_change = (eb_context_in != context_reg);

endmodule
