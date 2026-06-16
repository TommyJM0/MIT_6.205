`default_nettype none // prevents system from inferring an undeclared logic (good practice)
 
module top_level(
    input wire clk_100mhz, //100 MHz onboard clock
    input wire [15:0] sw, //all 16 input slide switches
    input wire [3:0] btn, //all four momentary button switches
    output logic [15:0] led, //16 green output LEDs (located right above switches)
    output logic [2:0] rgb0, //RGB channels of RGB LED0
    output logic [2:0] rgb1, //RGB channels of RGB LED1
    output logic [3:0] ss0_an,//anode control for upper four digits of seven-seg display
    output logic [3:0] ss1_an,//anode control for lower four digits of seven-seg display
    output logic [6:0] ss0_c, //cathode controls for the segments of upper four digits
    output logic [6:0] ss1_c //cathode controls for the segments of lower four digits
    );
 
    //shut up those rgb LEDs for now (active high):
    assign rgb1 = 0; //set to 0.
    assign rgb0 = 0; //set to 0. Change later!!
 
    //have btnd control system reset
    logic sys_rst;
    assign sys_rst = btn[0];
 
    //how many button presses have we seen so far?
    //wire this up to the LED display
    logic [15:0] btn_count; //use me to keep track of counting
    assign led = btn_count;
 
    //downstream/display variables:
    logic [31:0] val_to_display; //either the spi data or the btn_count data (default)
    logic [6:0] ss_c; //used to grab output cathode signal for 7s leds
 
    // debouncer for the button. we wrote this in lecture together.
    //TODO: make a variable for the debounced
    //button output, and feed it into your edge detector

    logic db_output;
    logic old_db_output;

    debouncer btn1_db(
        .clk(clk_100mhz),
        .rst(sys_rst),
        .dirty(btn[1]),
        .clean(db_output)
    );
 
    // this signal should go high for one cycle on the ..
    //rising edge of the (debounced) button output
    logic btn_pulse;
 
    //TODO: write your edge detector for part 1 of the lab here!
    
    always_ff @(posedge clk_100mhz) begin
        if(rst) begin
            db_output <= 0;
            old_db_output <= 0;
        end
        if(db_output == 1 && old_db_output == 0) begin
            btn_pulse <= 1;
        end
        else begin
            btn_pulse <= 0;
        end
        
        old_db_output <= db_output;
    end
 
    //the button-press counter.
    //TODO: finish this during part 1 of the lab
    evt_counter msc(
        .clk(clk_100mhz),
        .rst(sys_rst),
        .evt(btn_pulse),
        .count(btn_count)
    );
 
    //for starters just display button count:
    assign val_to_display = btn_count;
 
    //uncomment seven segment module for part 2!
    //
    //seven_segment_controller mssc(
    //  .clk(clk_100mhz),
    //  .rst(sys_rst),
    //  .val(val_to_display),
    //  .cat(ss_c),
    //  .an({ss0_an, ss1_an})
    //  );
    //
 
    assign {ss0_an, ss1_an} = 8'h00; // Remove this for part 2!
 
    assign ss0_c = ss_c; //control upper four digit's cathodes!
    assign ss1_c = ss_c; //same as above but for lower four digits!
 
endmodule // top_level
 
`default_nettype wire