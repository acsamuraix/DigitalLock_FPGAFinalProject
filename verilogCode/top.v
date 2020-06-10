// Blink an LED provided an input clock
/* module */
module top (hwclk, led1, led2, led3, led4, led5, led6, led7, led8,
    // Keypad lines
    keypad_r1,
    keypad_r2,
    keypad_r3,
    keypad_c1,
    keypad_c2,
    keypad_c3,

    // ftdi_tx, // use for UART transmission
    );

    /* I/O */
    input hwclk;
    output led1;
    output led2;
    output led3;
    output led4;
    output led5;
    output led6;
    output led7;
    output led8;

    output keypad_r1;
    output keypad_r2;
    output keypad_r3;

    input keypad_c1;
    input keypad_c2;
    input keypad_c3;

    // output ftdi_tx; // use for UART transmission

    wire [3:0] button;
    wire [3:0] button_local;
    wire bstate;

    reg [23:0] correctUC;
    initial correctUC = (correctUC1 << 20) + (correctUC2 << 16) + (correctUC3 << 12)
    + (correctUC4 << 8) + (correctUC5 << 4) + (correctUC6);
    parameter [3:0]correctUC1 = 1;
    parameter [3:0]correctUC2 = 2;
    parameter [3:0]correctUC3 = 3;
    parameter [3:0]correctUC4 = 4;
    parameter [3:0]correctUC5 = 5;
    parameter [3:0]correctUC6 = 6;


    parameter [23:0] correctPC = (correctPC1 << 20) + (correctPC2 << 16) + (correctPC3 << 12)
    + (correctPC4 << 8) + (correctPC5 << 4) + (correctPC6);
    parameter [3:0]correctPC1 = 6;
    parameter [3:0]correctPC2 = 6;
    parameter [3:0]correctPC3 = 6;
    parameter [3:0]correctPC4 = 6;
    parameter [3:0]correctPC5 = 6;
    parameter [3:0]correctPC6= 6;

    /* UART transmission code
    // 9600 Hz clock generation (from 12 MHz) 
    reg clk_9600 = 0;
    reg [31:0] cntr_9600 = 32'b0;
    parameter period_9600 = 625;

    // 1 Hz clock generation (from 12 MHz) 
    reg clk_1 = 0;
    reg [31:0] cntr_1 = 32'b0;
    parameter period_1 = 6000000;

    //UART registers
    reg [7:0] uart_txbyte;
    reg uart_send = 1'b1;
    wire uart_txed;

    assign uart_txbyte[7:2] = 5'b00000;
    assign uart_txbyte[1:1] = doneblinking;
    assign uart_txbyte[0:0] = startblinking;

    uart_tx_8n1 transmitter (
        // 9600 baud rate clock
        .clk (clk_9600),
        // byte to be transmitted
        .txbyte (uart_txbyte),
        // trigger a UART transmit on baud clock
        .senddata (uart_send),
        // input: tx is finished
        .txdone (uart_txed),
        // output UART tx pin
        .tx (ftdi_tx),
    );
    */

    enterDigit button_press(
        .hwclk(hwclk), 
        .keypad_r1(keypad_r1),
        .keypad_r2(keypad_r2),
        .keypad_r3(keypad_r3),
        .keypad_c1(keypad_c1),
        .keypad_c2(keypad_c2),
        .keypad_c3(keypad_c3),
        .button(button),
        .bstate(bstate),
    );

    wire blinkType = 1;
    wire startblinking;
    wire doneblinking;

    /*
    blinker halfBlinks(
        .hwclk(hwclk),
        .led(led1),
        .blinkType(blinkType),
        .start_blinking(startblinking),
        .done_blinking(doneblinking),
    );*/

    wire validUC;
    wire validPC;
    wire readInput = 1; // change later, assign to actual readInput from controller
    wire inputWrong = 0; // change later, assign to correctness checker module

    lengthChecker lCHECK(
        .hwclk(hwclk),
        .bstate(bstate),
        .button(button),
        .inputWrong(inputWrong),
        .readInput(readInput),
        .validUC(validUC),
        .validPC(validPC),
        /*.led1(led1),
        .led2      (led2),
        .led3      (led3),
        .led4      (led4)
        */
    );

    wire store;
    wire [1:0] compareType;
    initial compareType = 2'b01;
    wire correct;
    wire newUC;

    validChecker vCHECK(
        .hwclk(hwclk),
        .bstate(bstate),
        .button(button),
        .inputWrong(inputWrong),
        .readInput(readInput),
        .compareType(compareType),
        .correctUC(correctUC),
        .correctPC(correctPC),
        .store(store),
        .correct(correct),
        .newUC(newUC),
        
        .led1(led1),
        .led2(led2),
        .led3(led3),
        .led4(led4),
    );

    /* Counter register */
    reg [31:0] counter = 32'b0;

    /* LED drivers */
    /*
    assign led5 = button[0];
    assign led6 = button[1];
    assign led7 = button[2];
    assign led8 = button[3];
    */
    
    wire testLED; 
    wire test2LED;
    assign led7 = testLED;
    assign led8 = test2LED;  

    assign led5 = correct;
    assign led6 = store;
    
    always @ (negedge bstate) begin
        if(readInput) begin
            button_local = button;

            if(button_local[3:0] == 8) begin
                if(compareType == 2'b01) begin 
                    compareType <= 2'b11;
                end
                else if(compareType == 2'b11) begin
                    compareType <= 2'b10;
                end
                else if(compareType == 2'b10) begin
                    compareType <= 2'b01;
                end
            end
            else if (button_local[3:0] == 9) begin
                compareType <= 2'b01;
            end

        if(compareType <= 2'b10 && correct) begin
            store = 1;
            correctUC = newUC;
        end
        else begin
            store <= 0;
        end
        end

        /*testLED <= ~testLED;
        if(startblinking) begin
            startblinking <= 0;
        end
        if(doneblinking) begin
            test2LED <= ~test2LED;
            startblinking <= 1;
        end*/
        
        /*if(button[3:0]==4'd2) begin
            startblinking <= 1;
        end
        else begin
            startblinking <= 0;
        end*/
        
        testLED <= validUC;
        test2LED <= validPC;
    end

    
    /* Low speed clock generation */
    /*always @ (posedge hwclk) begin
        /* generate 9600 Hz clock */
     /*   cntr_9600 <= cntr_9600 + 1;
        if (cntr_9600 == period_9600) begin
            clk_9600 <= ~clk_9600;
            cntr_9600 <= 32'b0;
        end
    */
        /* generate 1 Hz clock */
     /*   cntr_1 <= cntr_1 + 1;
        if (cntr_1 == period_1) begin
            clk_1 <= ~clk_1;
            cntr_1 <= 32'b0;
        end
    end*/
    

endmodule
