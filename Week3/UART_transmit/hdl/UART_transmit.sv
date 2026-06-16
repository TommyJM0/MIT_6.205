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

   // TODO: module to transmit on UART

endmodule // uart_transmit

`default_nettype wire
