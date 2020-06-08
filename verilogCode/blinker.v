// Blink an LED provided blink durations and quantity of blinks
/* module */
module blinker (
    hwclk,
    led, // must be specified by controller

    testled, // just for debugging

    blinkType,

    start_blinking,
    done_blinking,

    output led5,
    output led6,
    output led7,
    output led8,
    );

    /* I/O */
    input hwclk;
    output led;

    output testled;
    
    input blinkType;

    input start_blinking;
    output done_blinking;

    wire start_blinkinglocal;

    /* register counts the number of led toggles (half blinks) that have occurred*/
    reg [3:0] numBlinks;// = 32'b0;
    reg [31:0] blink_timer;// = 32'b0;
    reg [4:0] blink_counter;// = 5'b0;
    
    reg clk_led;
    reg done;

    // actual led number must be specified by controller
    assign led = clk_led;
    assign done_blinking = done;
    assign testled = done;

    // error blink
    parameter PERIODON1 = 32'd6000000;   //0.5 SECONDS
    parameter PERIODOFF1 = 32'd12000000; // 1 SECOND
    parameter BLINKCOUNT1 = 4'd6;   // 3 BLINKS

    // successful programming blink
    parameter PERIODON2 = 32'd2400000;   // 0.2 SECONDS
    parameter PERIODOFF2 = 32'd2400000;  //0.2 SECONDS
    parameter BLINKCOUNT2 = 4'd10;  // 5 BLINKS
    
    /* specify blinkLengths in units: tenths of seconds */
    reg [31:0] BLINK_PERIODON;// = PERIODON1;
    reg [31:0] BLINK_PERIODOFF;// = PERIODOFF1;
    reg [3:0] timesToBlink;// = BLINKCOUNT1;

    initial BLINK_PERIODON = PERIODON1;
    initial BLINK_PERIODOFF = PERIODOFF1;
    initial timesToBlink = BLINKCOUNT1;    

    // for testing only
    assign led5 = numBlinks[0];
    assign led6 = numBlinks[1];
    assign led7 = numBlinks[2];
    assign led8 = numBlinks[3];

    always @ (posedge hwclk) begin 
        if(start_blinking && (numBlinks < timesToBlink)) begin
            /*if(clk_led) begin  // led ON 
                if (blink_timer < BLINK_PERIODON) begin
                    blink_timer <= blink_timer + 1; 
                end 
                else begin
                    blink_timer = 32'b0;
                    numBlinks <= numBlinks + 1;
                    clk_led <= 0;
                end
            end 
            else begin  // led OFF
                if (blink_timer < BLINK_PERIODOFF) begin
                    blink_timer <= blink_timer + 1;
                end 
                else begin
                    blink_timer = 32'b0;
                    numBlinks <= numBlinks + 1;
                    clk_led <= 1;
                end
            end*/
                if (blink_timer < BLINK_PERIODON) begin
                    blink_timer <= blink_timer + 1; 
                    clk_led <= blink_timer[23];
                end 
                else begin
                    blink_timer <= 32'b0;
                    numBlinks <= numBlinks + 1;
                    clk_led <= ~clk_led;
                end
        end 
        else begin    // module is done blinking
            clk_led <= 0; // change back to 0
            done <= 1;
        end
    end

    always @ (posedge start_blinking) begin
    // controller tells module to start blinking
    numBlinks <= 4'b0000;
    done <= 0;
    clk_led <= 1;
    case (blinkType)
        1'b0 : begin
            BLINK_PERIODON <= PERIODON1;
            BLINK_PERIODOFF <= PERIODOFF1;
            timesToBlink <= BLINKCOUNT1;
        end
        1'b1 : begin
            BLINK_PERIODON <= PERIODON2;
            BLINK_PERIODOFF <= PERIODOFF2;
            timesToBlink <= BLINKCOUNT2;
        end
    endcase
    end

endmodule
