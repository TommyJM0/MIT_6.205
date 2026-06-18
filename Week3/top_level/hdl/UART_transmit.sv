`timescale 1ns / 1ps
`default_nettype none

module UART_transmit
  #(
    parameter INPUT_CLOCK_FREQ = 100_000_000,
    parameter BAUD_RATE = 9600
    )
   (
    input wire 	     clk,
    input wire 	     rst,
    input wire [7:0] din,
    input wire 	     trigger,
    output logic     busy,
    output logic     dout
    );

  localparam BAUD_BIT_PERIOD = INPUT_CLOCK_FREQ/BAUD_RATE;
  
  typedef enum {
    IDLE,
    START,
    DATA,
    STOP
  } uart_state;

  uart_state state, next_state;
  
  logic [7:0] bit_num = 0, next_bit_num = 0;
  logic [31:0] count = 0, next_count = 0;
  logic [7:0] tx_buffer, next_tx_buffer;
   

  always_comb begin
    
    if (rst) begin
      next_state = IDLE;
    end
    else begin
      
      case(state)

        IDLE: begin
          busy = 0;
          dout = 1;
          next_count = 0;
          next_bit_num = 0;
          next_tx_buffer = 0;

          if(trigger) begin 
            next_state = START;
            next_tx_buffer = din;
            
          end
        end

        START : begin
          busy = 1;
          dout = 0;

          next_count = count + 1;

          if(count == BAUD_BIT_PERIOD - 1) begin
            next_state = DATA;
            next_count = 0; 
          end
        end

        DATA : begin
          busy = 1;
          dout = tx_buffer[0];
        
          if(count == BAUD_BIT_PERIOD - 1) begin
            next_count = 0;
            
            if(bit_num == 7) begin
              next_state = STOP;
              next_bit_num = 0;
            end
            
            else begin
              next_bit_num = bit_num + 1;
              next_tx_buffer = {tx_buffer[0], tx_buffer[7:1]};
            end
          end
          
          else begin
            next_tx_buffer = tx_buffer;
            next_bit_num = bit_num;
            next_count = count + 1;
            next_state = DATA;
          end

        end

        STOP: begin
          busy = 1;
          dout = 1;

          next_count = count + 1;

          if(count == BAUD_BIT_PERIOD - 1) begin
            next_state = IDLE;
            next_count = 0; 
          end
        end
      endcase
    end
  end
  
  always_ff @(posedge clk) begin
    state <= next_state;
    count <= next_count;
    bit_num <= next_bit_num;
    tx_buffer <= next_tx_buffer;
  end

endmodule // uart_transmit

`default_nettype wire
