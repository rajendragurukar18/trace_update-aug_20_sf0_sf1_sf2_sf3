`timescale 1ns/1ps
module branch_map(
    input               clk             ,
    input               rst_n           ,
    input               format2_valid   ,
    input       [3:0]   itype           ,
    output reg  [30:0]  branch_map_out  ,
    output reg          branch_map_full
);

//Internal register declaration
reg [4:0]   branch_count;
reg [30:0]  branch_map_w;

//branch counter
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        branch_count <= 5'b0;
    else
    begin
        if(format2_valid)//counts only when there is branch packet(i.e. format 2 valid)
            branch_count <= branch_count + 5'b00001;
    end
end

//branch map full indicator logic
//assign branch_map_full = (branch_count == 5'b1111);//combo version commented because valid has to be generated along with branch map

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        branch_map_full <= 1'b0;
    else
    begin
            branch_map_full <= (branch_count == 5'b1111);
    end
end

//branch map wire logic
always@(*)
begin
    branch_map_w[0]     = (branch_count == 5'd1)    ? (itype == 4'd5) : 1'b0  ;
    branch_map_w[1]     = (branch_count == 5'd2)    ? (itype == 4'd5) : 1'b0  ;
    branch_map_w[2]     = (branch_count == 5'd3)    ? (itype == 4'd5) : 1'b0  ;
    branch_map_w[3]     = (branch_count == 5'd4)    ? (itype == 4'd5) : 1'b0  ;
    branch_map_w[4]     = (branch_count == 5'd5)    ? (itype == 4'd5) : 1'b0  ;
    branch_map_w[5]     = (branch_count == 5'd6)    ? (itype == 4'd5) : 1'b0  ;
    branch_map_w[6]     = (branch_count == 5'd7)    ? (itype == 4'd5) : 1'b0  ;
    branch_map_w[7]     = (branch_count == 5'd8)    ? (itype == 4'd5) : 1'b0  ;
    branch_map_w[8]     = (branch_count == 5'd9)    ? (itype == 4'd5) : 1'b0  ;
    branch_map_w[9]     = (branch_count == 5'd10)   ? (itype == 4'd5) : 1'b0  ;
    branch_map_w[10]    = (branch_count == 5'd11)   ? (itype == 4'd5) : 1'b0  ;
    branch_map_w[11]    = (branch_count == 5'd12)   ? (itype == 4'd5) : 1'b0  ;
    branch_map_w[12]    = (branch_count == 5'd13)   ? (itype == 4'd5) : 1'b0  ;
    branch_map_w[13]    = (branch_count == 5'd14)   ? (itype == 4'd5) : 1'b0  ;
    branch_map_w[14]    = (branch_count == 5'd15)   ? (itype == 4'd5) : 1'b0  ;
    branch_map_w[15]    = (branch_count == 5'd16)   ? (itype == 4'd5) : 1'b0  ;
    branch_map_w[16]    = (branch_count == 5'd17)   ? (itype == 4'd5) : 1'b0  ;
    branch_map_w[17]    = (branch_count == 5'd18)   ? (itype == 4'd5) : 1'b0  ;
    branch_map_w[18]    = (branch_count == 5'd19)   ? (itype == 4'd5) : 1'b0  ;
    branch_map_w[19]    = (branch_count == 5'd20)   ? (itype == 4'd5) : 1'b0  ;
    branch_map_w[20]    = (branch_count == 5'd21)   ? (itype == 4'd5) : 1'b0  ;
    branch_map_w[21]    = (branch_count == 5'd22)   ? (itype == 4'd5) : 1'b0  ;
    branch_map_w[22]    = (branch_count == 5'd23)   ? (itype == 4'd5) : 1'b0  ;
    branch_map_w[23]    = (branch_count == 5'd24)   ? (itype == 4'd5) : 1'b0  ;
    branch_map_w[24]    = (branch_count == 5'd25)   ? (itype == 4'd5) : 1'b0  ;
    branch_map_w[25]    = (branch_count == 5'd26)   ? (itype == 4'd5) : 1'b0  ;
    branch_map_w[26]    = (branch_count == 5'd27)   ? (itype == 4'd5) : 1'b0  ;
    branch_map_w[27]    = (branch_count == 5'd28)   ? (itype == 4'd5) : 1'b0  ;
    branch_map_w[28]    = (branch_count == 5'd29)   ? (itype == 4'd5) : 1'b0  ;
    branch_map_w[29]    = (branch_count == 5'd30)   ? (itype == 4'd5) : 1'b0  ;
    branch_map_w[30]    = (branch_count == 5'd31)   ? (itype == 4'd5) : 1'b0  ;
end

//branch map register
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        branch_map_out <= 31'b0;
    else
    begin
        if(branch_count == 5'd31)
            branch_map_out <= 31'b0;
        else
            branch_map_out <= branch_map_w;
    end
end

endmodule
