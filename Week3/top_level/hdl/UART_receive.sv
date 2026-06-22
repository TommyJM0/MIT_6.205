`timescale 1ns / 1ps
`default_nettype none

module UART_receive
  #(
    parameter INPUT_CLOCK_FREQ = 100_000_000,
    parameter BAUD_RATE = 9600
    )
   (
        input wire         clk,
        input wire         rst,
        input wire         din,
        output logic       dout_valid,
        output logic [7:0] dout
    );

    localparam BAUD_BIT_PERIOD = INPUT_CLOCK_FREQ/BAUD_RATE;

    typedef enum {
        IDLE,
        START,
        DATA,
        STOP,
        TRANSMIT

    } uart_state;


    uart_state state, next;
    
    logic [4:0] bit_num = 0;
    logic [4:0] bit_num_next = 0;
    logic [32:0] count = 0;
    logic [32:0] count_next = 0;
    logic [7:0] rx_buffer = 0;
    logic [7:0] rx_buffer_next = 0;

    always_comb begin
      if(rst) begin
        next = IDLE;
      end
      else begin
        case (state)

          IDLE : begin
            if(din == 0) begin
              next = START;
              bit_num_next = 0;
              count_next = 0;
              rx_buffer_next = 0;

            end else begin
              next = state;
              bit_num_next = 0;
              count_next = 0;
              rx_buffer_next = 0;
            end

            dout_valid = 0;
            dout = 0;
          end

          START : begin
            if(count  == BAUD_BIT_PERIOD/2 ) begin //checking for a bad start bit
              if(din == 0) begin
                next = START;
              end else begin
                next = IDLE;
              end
            end
            
            if(count == BAUD_BIT_PERIOD - 1) begin //Keeping the BAUD rate timing right
              next = DATA;
              count_next = 0;
            end
            else begin
              count_next = count + 1;
            end

            dout_valid = 0;
            dout = 0;
          end
          
          DATA : begin
            
            if((count == BAUD_BIT_PERIOD - 1) && (bit_num != 7)) begin
              count_next = 0;
              bit_num_next = bit_num + 1;
            end else if ((count == BAUD_BIT_PERIOD - 1) && (bit_num == 7))begin
              next = STOP;
              bit_num_next = 0;
              count_next = 0; 
            end else begin
              count_next = count + 1;
            end 
            
            if(count == BAUD_BIT_PERIOD / 2) begin
              rx_buffer_next = {din, rx_buffer[7:1]};
            end
            else begin
              rx_buffer_next =  rx_buffer;
            end

            
            dout_valid = 0;
            dout = 0;
          end
        
          STOP: begin
            if(count  == BAUD_BIT_PERIOD/2 ) begin //checking for a bad stop bit
              if(din == 1) begin
                next = TRANSMIT;
              end else begin
                next = IDLE;
              end
            end
            else begin
              count_next = count + 1;
              dout_valid = (count == BAUD_BIT_PERIOD/2 - 1);
              dout = 0;
            end
          end

          TRANSMIT: begin
            
            if(count == BAUD_BIT_PERIOD - 1) begin
              next = IDLE;
              count_next = 0;
            end
            else begin
              count_next = count + 1;
            end
            
            dout = rx_buffer;
            dout_valid = 0;

          end

        endcase
      end 
    end   
      
    always_ff @(posedge clk) begin
      if (rst) begin
        state <= IDLE;
        count <= 0;
      end
      else begin
        state <= next;
        count <= count_next;
        bit_num <= bit_num_next;
        rx_buffer <= rx_buffer_next;
      end
    end

endmodule // uart_receive

`default_nettype wire