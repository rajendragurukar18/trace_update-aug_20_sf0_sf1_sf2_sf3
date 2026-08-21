`timescale 1ns/1ps
module spi_fifo #(parameter [1:0]mode=2'b0)(
                                          input         clk         ,
                                          input         rst         ,//spi reset
                                          input         empty       ,//empty signal from fifo
                                          input         miso        ,//master to slave input
                                          input [63:0]  data_in     ,//data input from fifo(rdata)
                                          //input         rx_e        ,//
                                          output        sclk        ,//clk driven to slave
                                          output        mosi        ,//master to slave output
                                          output reg    ss          ,//slave select
                                          //output reg [31:0]data_out,
                                          output reg    tx_done     , //transmission done 
                                          //output reg    rx_done     ,//reception done
                                          output reg    read_enable ); //read enable to trace fifo                       
  reg i_clk;
  reg tx_ready;
  wire cpol,cpha;
  reg [5:0]tx_count;
  reg [6:0]rx_count;
  wire miso_d;
  reg mosi_q;
  reg [63:0]sr;  
  wire mclk;
  wire tx_del;
  reg read_enable_del;
  wire read_neg;
  reg txr_del;
  reg first;
  //reg done;
  wire spi_enable;
  reg spi_enable_del;
  //wire empty_posedge;

  assign cpol=(mode==2'd2 || mode==2'd3);
  assign cpha=(mode==2'd1 || mode==2'd3);
  assign miso_d=miso;
  assign mosi=mosi_q;
  assign sclk=ss?cpol:mclk;
  assign mclk=(cpha^cpol)?~i_clk:i_clk;
 
  //clock generation 
  always@(posedge clk,negedge rst)begin
    if(!rst)
      begin
      	i_clk<=cpol;
      end
      else 
        begin
    	i_clk<=~i_clk;
        end
  end
  
  //Read enable generation for FIFO
  always@(posedge mclk,negedge rst)
   begin
    if(!rst)
      read_enable<=1'b0;
    else
    begin
        if((spi_enable || tx_done) /*&& (!empty_posedge)*/)
        begin
    	    if(!empty)
      	        read_enable<=1'b1;
    	    else
      	        read_enable<=1'b0;
        end
        else
        begin
            read_enable<=1'b0;
        end
  	end
   end
  
  // To tx_ready load data from FIFO to spishift register
  always@(read_neg/*,rst*/)
  begin
    /*if(!rst)
      tx_ready =1'b0;
    else
    begin   */
      if(read_neg)
         tx_ready =1'b1;
      else
        tx_ready =1'b0;
  end
  //end
  
  //Slave Select Signal is active only when there is an active transaction
  always@(posedge mclk,negedge rst)
  begin
    if(!rst)
    begin 
      ss<=1'b1;
      first<=1'b0;
    end
    else 
    begin
      if(tx_del)
      begin
        ss<=1'b0;
        first<=1'b1;
      end
      else
      begin
          if((first==1'b1) && (tx_done==1'b0))
            ss<=1'b0;
          else
          begin
            ss<=1'b1;
            first<=1'b0;
          end
      end
      
    end
  end
  
  //Reception of data from slave to master
  
  always@(posedge mclk,negedge rst) 
  begin
    if(!rst) 
    begin
      	sr<=64'd0;
      	rx_count<=7'd0;
    end
       else 
       begin 
         if(tx_del) 
         begin
             sr<=data_in;
         end
         else 
         begin
             if(!ss) 
             begin
           		sr<={sr[62:0],miso_d};
           		rx_count<=rx_count+7'd1;
             end
             else 
             begin
             	rx_count<=7'd0;
             end
         end
    end
  end

  //Transmission block
  
  always@(negedge mclk,negedge rst)//Check 
  begin
    if(!rst) 
    begin
    	mosi_q<=1'b0;
        tx_count<=6'd0;
    end
    else 
    begin 
         if(!ss && !tx_del) 
         begin
        	mosi_q<=sr[63];
           	tx_count<=tx_count+6'd1;
         end           
         else 
         begin
          	mosi_q<=1'b0;
          	tx_count<=6'd0;
      	end
      end
  end
  
  //Update the transmission status
  always@(negedge mclk,negedge rst)
  begin
    if (!rst) 
    begin
    	tx_done<=1'b0;
    end
    else 
    begin
    	if(tx_count==6'd63)
        begin
  			tx_done<=1'b1;
  		end
   		else 
        begin
   			tx_done<=1'b0;
  		end
  	end
  end
  
  //Update the reception status        --------commented because not used anywhere in the top module of Trace
 /* always@(posedge mclk,negedge rst)
  begin
    if(!rst) 
    begin
      	rx_done<=1'b0;
    end
    else 
    begin
      if(rx_count==6'd31)
      begin
  			rx_done<=1'b1;
  	  end
   	  else 
      begin
   			rx_done<=1'b0;
       end      
  	end
  end   */

  //Load received data from SPI to output
/*  always@(posedge mclk,negedge rst)
  begin
    if(!rst)
    begin
      data_out<=32'd0;
      done<=1'b0;
    end
    else 
    begin
      if(rx_count==6'd32)
      begin
        data_out<=sr;
        done<=1'b1;
      end
      else
      begin
        data_out<=data_out;
        done<=1'b0;
      end
    end
  end       */

 //Transmission start bit for SPI 
  always@(posedge mclk,negedge rst)
  begin
    if(!rst) 
    begin
      txr_del<=1'b0;
    end
    else   
    begin
  		txr_del<=tx_ready;
  	end
  end
  assign tx_del= tx_ready & ~txr_del;



  always@(posedge mclk,negedge rst)
  begin 
    if(!rst) 
    begin
    	read_enable_del<=1'b0;
    end
    else 
    begin
  		read_enable_del<=read_enable;
  	end
  end       
  assign read_neg = ~read_enable & read_enable_del;



//Negative edge detection of empty signal
  always@(posedge mclk,negedge rst)
  begin 
    if(!rst) 
    begin
    	spi_enable_del<=1'b0;
    end
    else 
    begin
  		spi_enable_del<=empty;
  	end
  end
  assign spi_enable = ~empty & spi_enable_del;
  //assign empty_posedge = empty & (~spi_enable_del);
  

endmodule


