`timescale 1ns/1ps
module itrace_top(
    input               it_clk                      ,//trace encoder clock
//    input               it_spi_clk                  ,//clock for spi module
    input               it_rst_n                    ,//trace encoder reset
//    input               it_spi_rst_n                ,//spi reset signal
    input   [3:0]       it_itype                    ,//instruction type from core
    input   [19:0]      it_iaddr                    ,//instruction address from core
    input   [7:0]       it_cause                    ,//cause from core
    input   [19:0]      it_tval                     ,//trap value signal from core
    input   [2:0]       it_priv                     ,//privilege signal from core
    input   [2:0]       it_context                  ,//context signal from core
//    input               it_spi_miso_i               ,//master in slave out signal from spi slave
    input               it_trace_enable             ,//trace enable signal from control registers
    input               it_ienable_in               ,
    input               it_itype_valid              ,
    input               it_first_instrn_valid_in    ,
    input   [19:0]      it_delta_addr               ,//delta address input from hart
    input               it_del_adr_valid            ,//valid signal of delta address
//    output              it_spi_sclk_o               ,//spi master clk driving slave
//    output              it_spi_mosi_o               ,//spi master out slave in
//    output              it_spi_ss_o                 ,//spi slave select
//    output              it_spi_txdone_o              //spi transmission done
	output				it_rempty					,// trace_fifo output
	output  [63:0]		it_rdata					 // trace_fifo read data
);
                                                                                
wire    [63:0]  wdata_w;
wire            wr_en_w;
wire            fifo_wfull_w;//intrernal signal from fifo indicating full condition


//Instantiate trace encoder top module
inst_trace_enmodule te_inst (
    .te_ienable_in          (it_ienable_in              ),
    .itype_valid_i          (it_itype_valid             ),
    .itype_in               (it_itype                   ),
    .cause_in               (it_cause                   ),
    .tval_in                (it_tval                    ),
    .priv_in                (it_priv                    ),
    .iaddr_in               (it_iaddr                   ),
    .context_in             (it_context                 ),
    .delta_addr             (it_delta_addr              ),                 
    .del_addr_valid         (it_del_adr_valid           ),              
    .clk                    (it_clk                     ),
    .rst_n                  (it_rst_n                   ),
    .first_instrn_valid_in  (it_first_instrn_valid_in   ),
    .fifo_wfull             (fifo_wfull_w               ),
    .te_trace_enable        (it_trace_enable            ),
    .packet_format3_o       (wdata_w                    ),
    .wr_en_out              (wr_en_w                    )
);

//Instantiate trace_fifo_spi_top module
trace_fifo_spi_top t_fifo_spi_inst(
    .tfs_te_clk_i    (it_clk          ),
//    .tfs_spi_clk_i   (it_spi_clk      ),
    .tfs_te_rst_n_i  (it_rst_n        ),
//    .tfs_spi_rst_n_i (it_spi_rst_n    ),
    .tfs_te_wen_i    (wr_en_w         ),
    .tfs_te_wdata_i  (wdata_w         ),
//    .tfs_spi_miso_i  (it_spi_miso_i   ),
    .tfs_fifo_wfull  (fifo_wfull_w    ),
//    .tfs_spi_sclk_o  (it_spi_sclk_o   ),
//    .tfs_spi_mosi_o  (it_spi_mosi_o   ),
//    .tfs_spi_ss_o    (it_spi_ss_o     ),
//    .tfs_spi_txdone_o(it_spi_txdone_o )
	.tfs_rdata		 (it_rdata		  ),
	.tfs_rempty		 (it_rempty		  )
);

endmodule

