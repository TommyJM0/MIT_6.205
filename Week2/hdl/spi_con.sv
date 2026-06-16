module spi_con
     #(parameter DATA_WIDTH = 8,
       parameter DATA_CLK_PERIOD = 100
      )
    (   input wire   clk, //system clock (100 MHz)
        input wire   rst, //reset in signal
        input wire   [DATA_WIDTH-1:0] data_in, //data to send
        input wire   trigger, //start a transaction
        output logic [DATA_WIDTH-1:0] data_out, //data received!
        output logic data_valid, //high when output data is present.
 
        output logic copi, //(Controller-Out-Peripheral-In)
        input wire cipo, //(Controller-In-Peripheral-Out)
        output logic dclk, //(Data Clock)
        output logic cs // (Chip Select)
 
      );

    logic [10:0] dclk_cycles;
    logic [10:0] count;
    logic [DATA_WIDTH - 1: 0] data_buffer;

    always_comb begin
        if(rst) begin 
            cs = 1;
            data_valid = 8'b0;
            data_out = 0;
            data_buffer = 0;
            count = 0;
            dclk_cycles = 0;
        end

        if(trigger) begin // if the trigger is one for even one clock cycle cs drops low
            cs = 0;
        end
    end
    

    assign dclk = count > (DATA_CLK_PERIOD/2 - 1);
    assign copi = data_in[DATA_WIDTH - 1 - int'(dclk_cycles)];

    always_ff @(posedge clk) begin
        
        if (~cs) begin
            
            data_buffer[DATA_WIDTH - 1 - int'(dclk_cycles)] <= cipo;

            if (count != (DATA_CLK_PERIOD - 1)) begin
                count <= count + 1;
            end
            else if ((count == (DATA_CLK_PERIOD - 1))) begin
                count <= 0;
                if(dclk_cycles == DATA_WIDTH - 1) begin
                    cs <= 1;
                    data_valid <= 1;
                    data_out <= data_buffer;
                end else begin
                    dclk_cycles <= dclk_cycles + 1;  
                end
            end     
        end else begin
            data_valid <= 0;
        end
    end

endmodule
