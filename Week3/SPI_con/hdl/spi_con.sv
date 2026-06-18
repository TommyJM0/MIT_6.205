`timescale 1ns / 1ps
`default_nettype none

module spi_con
     #(parameter DATA_WIDTH = 8,
       parameter DATA_CLK_PERIOD = 100
      )
      (input wire   clk,
       input wire   rst,
       input wire   [DATA_WIDTH-1:0] data_in,
       input wire   trigger,
       output logic [DATA_WIDTH-1:0] data_out,
       output logic data_valid, //high when output data is present.

       output logic copi,
       input wire   cipo,
       output logic dclk,
       output logic cs
      );
      
      logic [DATA_WIDTH - 1 : 0] tx_buffer;
      logic [DATA_WIDTH - 1 : 0] rx_buffer;
      logic [31:0] count;
      logic [31:0] bit_num;

      assign dclk = (count > (DATA_CLK_PERIOD/2 - 1)) && !cs;
      assign copi = tx_buffer[0];

      always_ff @(posedge clk) begin
        
        if(rst) begin
          data_out <= 0;
          data_valid <= 0;
          cs <= 1;
          
          bit_num <= 0;
          count <= 0;
          rx_buffer <= 0;
        end 
        
        else if(trigger && cs) begin
          cs <= 0;
          tx_buffer <= data_in;
        end

        else if(~cs) begin
          
          if((count == DATA_CLK_PERIOD - 1) && (bit_num != DATA_WIDTH - 1)) begin
              count <= 0;
              bit_num <= bit_num + 1;
              
              tx_buffer <= {tx_buffer[DATA_WIDTH - 2 : 0], tx_buffer[DATA_WIDTH - 1]};
            end 
          
          else if (count == DATA_CLK_PERIOD/2 - 1) begin
            rx_buffer <= {rx_buffer[DATA_WIDTH - 2 : 0], cipo};
            count <= count + 1;
          end

          else if ((count == DATA_CLK_PERIOD - 1) && (bit_num == DATA_WIDTH - 1))begin
            cs <= 1;
            count <= 0;
            bit_num <= 0; 

            data_out <= rx_buffer;
            data_valid <= 1;
          end 
            
          else begin
            count <= count + 1;
          end
        end
        
        else begin
          data_valid <= 0;
          cs <= 1;
          
          bit_num <= 0;
          count <= 0;
          rx_buffer <= 0;
        end
      end
endmodule

`default_nettype wire
