//`timescale 1ns/1ps
module inst_trace_enmodule(
    input               te_ienable_in           ,
    input               itype_valid_i           ,
    input       [3:0]   itype_in                ,
    input       [7:0]   cause_in                ,
    input       [31:0]  tval_in                 , // exception instructions are passing becuase of mtvalue is constant, it increases to the 32 bits from 20 bits
//    input       [2:0]   priv_in                 ,
    input       [15:0]  iaddr_in                , // previous 20 bit reducing to the 16 bit, because of the unused bits
    input       [1:0]   context_in              , // previous 3 bits are there, reducing to the 2 bits, we only have 3 scenarios here
    input       [19:0]  delta_addr              ,//coming from hart
    input               del_addr_valid          ,
    input               clk                     ,
    input               rst_n                   ,
    input               first_instrn_valid_in   ,
    input               fifo_wfull              ,
    input               te_trace_enable         ,
    output      [63:0]  packet_format3_o        ,//64 bit because of fifo width
    output              wr_en_out       
);

//68 bit wire declaration for packet_format 3 output
//wire packet_f3_valid_w    ;

wire f3_subformat0_en_w   ;
wire f3_subformat1_en_w   ;
wire f3_subformat2_en_w   ;
wire f3_subformat3_en_w   ;
wire format2_en_w         ;//format2 enable signal

//wire [255:0]subformat0_w    ;
//wire        sf0_valid_w     ;
//wire [255:0]subformat1_w    ;
//wire        sf1_valid_w     ;
//wire [255:0]subformat2_w    ;
//wire        sf2_valid_w     ;
//wire [255:0]subformat3_w    ;
//wire        sf3_valid_w     ;
//wire [255:0]format2_w       ;
//wire        format2_valid_w ;
//wire [255:0]format1_w       ;
//wire        format1_valid_w ;

wire [63:0] subformat0_w    ;
wire        sf0_valid_w     ;
wire [63:0] subformat1_w    ;
wire        sf1_valid_w     ;
wire [63:0] subformat2_w    ;
wire        sf2_valid_w     ;
wire [63:0] subformat3_w    ;
wire        sf3_valid_w     ;
wire [63:0] format2_w       ;
wire        format2_valid_w ;
wire [63:0] format1_w       ;
wire        format1_valid_w ;


wire        branchmap_full_w;
wire [30:0] branchmap_w     ;

//instantiate the enable generation block
inst_trace_enformat3_enableblock   inst_trace_enformat3_enableblock (
     .clk                   (clk                    ),
     .rst_n                 (rst_n                  ),
     .eb_itype_valid        (itype_valid_i          ),
     .itype_in              (itype_in               ),
     .eb_context_in         (context_in             ),
     .first_instrn_valid    (first_instrn_valid_in  ),
     .wfull_fifo            (fifo_wfull             ),
     .f3_subformat0_en      (f3_subformat0_en_w     ),
     .f3_subformat1_en      (f3_subformat1_en_w     ),
     .f3_subformat2_en      (f3_subformat2_en_w     ),
     .f3_subformat3_en      (f3_subformat3_en_w       ),
     .format2_en            (format2_en_w           )
     );
//instantiate the packet generation block

//instantiate the subformat0 block

inst_trace_enformat3_sf0  inst_trace_enformat3_sf0(
    .itype_in               (itype_in               ),
//    .priv_in                (priv_in                ),
    .context_in             (context_in             ),
    .iaddr_in               (iaddr_in               ),
    .first_instruction_valid(first_instrn_valid_in  ),
    .f3_subformat0_en       (f3_subformat0_en_w     ),
    .clk                    (clk                    ),
    .rst                    (rst_n                  ),
    .sf0_trace_en           (te_trace_enable        ),
    .subformat0             (subformat0_w           ),
    .sf0_valid              (sf0_valid_w            )
    );

//instantiate the subformat1 block
inst_trace_enformat3_sf1  inst_trace_enformat3_sf1(
    .itype_in           (itype_in           ),
//    .priv_in            (priv_in            ),
    .context_in         (context_in         ),
    .cause_in           (cause_in           ),
    .iaddr_in           (iaddr_in           ),
    .f3_subformat1_en   (f3_subformat1_en_w ),
    .tval_in            (tval_in            ),
    .itype_valid        (itype_valid_i      ),
    .clk                (clk                ),
    .rst                (rst_n              ),
    .sf1_trace_en       (te_trace_enable    ),
    .subformat1         (subformat1_w       ),
    .sf1_valid          (sf1_valid_w        )
    );

//instantiate the subformat2 block
inst_trace_enformat3_sf2  inst_trace_enformat3_sf2(
//    .priv_in            (priv_in            ),
    .context_in         (context_in         ),
    .f3_subformat2_en   (f3_subformat2_en_w ),
    .clk                (clk                ),
    .rst_n              (rst_n              ),
    .sf2_trace_en       (te_trace_enable    ),
    .valid_con          (itype_valid_i      ),
    .subformat2         (subformat2_w       ),
    .sf2_valid          (sf2_valid_w        )
    );

                                   
//instantiate the subformat3 block
inst_trace_enformat3_sf3  inst_trace_enformat3_sf3(
    .itype_in           (itype_in           ),
    .ienable_in         (te_ienable_in      ),
    .f3_subformat3_en   (f3_subformat3_en_w   ),
    .clk                (clk                ),
    .rst_n              (rst_n              ),
    .sf3_trace_en       (te_trace_enable    ),
    .valid_itype        (itype_valid_i      ),
    .subformat3         (subformat3_w       ),
    .sf3_valid          (sf3_valid_w        )
);


//Instantiate format 2 packet encoder block
inst_trace_enformat2 format2_inst   (
    .delta_addr_in       (delta_addr       ),    
    .format2_en          (format2_en_w     ),    
    .format2_trace_en    (te_trace_enable  ),    
    .addr_valid          (del_addr_valid   ),        
    .clk                 (clk              ),        
    .rst_n               (rst_n            ),    
    .format2             (format2_w        ),    
    .format2_valid       (format2_valid_w  )
);


//Instantiate branch map logic
branch_map  branch_map_inst (
    .clk               (clk                ),      
    .rst_n             (rst_n              ),        
    .format2_valid     (format2_valid_w    ),               
    .itype             (itype_in           ),    
    .branch_map_out    (branchmap_w        ),    
    .branch_map_full   (branchmap_full_w   )           
);


//Instantiate format 1 packet encoder block
inst_trace_enformat1 format1_inst   (
    .if1_del_addr_in    (delta_addr        ),                 
    .if1_addr_valid_i   (del_addr_valid    ),                               
    .if1_trace_en       (te_trace_enable   ),                                  
    .format1_en         (branchmap_full_w  ),                                    
    .branch_map_i       (branchmap_w       ),                        
    .clk                (clk               ),                             
    .rst_n              (rst_n             ),                     
    .format1            (format1_w         ),                                
    .format1_valid      (format1_valid_w   )
);
 

//instatiate the mux block
inst_trace_enformat3_mux  inst_trace_enformat3_mux(
    .subformat0         (subformat0_w       ),
    .sf0_valid_i        (sf0_valid_w        ),
    .subformat1         (subformat1_w       ),
    .sf1_valid_i        (sf1_valid_w        ),
    .subformat2         (subformat2_w       ),
    .sf2_valid_i        (sf2_valid_w        ),
    .subformat3         (subformat3_w       ),
    .sf3_valid_i        (sf3_valid_w        ),
    .format2_i          (format2_w          ),
    .format2_valid_i    (format2_valid_w    ),
    .format1_i          (format1_w          ),
    .format1_valid_i    (format1_valid_w    ),
    .clk                (clk                ),
    .rst_n              (rst_n              ),
    .packet_format3     (packet_format3_o   ),
    .packet_f3_valid    (wr_en_out          )
    );
endmodule
