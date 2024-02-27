`timescale 1ns / 1ps
module top (
    input clr,
    input clk,
    input btn_l,
    input btn_r,
    input btn_f,
    output PWM_servo,
    output PWM_brush_motor,
    output PWM_dir
    );    
    
    localparam PWM_MIN = 60000;
    localparam PWM_MAX = 255840;
    localparam DC_BRUSH_MIN = 0;
    localparam DC_BRUSH_MAX = 505840;
    
    // Servo Motor Control
    wire [19:0] A_net;
    reg [19:0] value_net;
    reg [7:0] counter_200th = 0; // Counter to keep track of every 200th clock cycle

    // Modify value_net every 200th clock cycle
    always @(posedge clk or posedge clr) begin
        if (clr) begin
            value_net <= 60000;
            counter_200th <= 0;
        end else begin
            // Increment the counter
            counter_200th <= counter_200th + 1;

            // Modify value_net every 200th clock cycle
            if (counter_200th == 199) begin
            // Continuous increase when btn_r is pressed
                if (btn_r && (value_net < PWM_MAX)) begin
                    value_net <= (value_net + 1 > PWM_MAX) ? PWM_MAX : value_net + 1;
                end
                // Continuous decrease when btn_l is pressed
                else if (btn_l && (value_net > PWM_MIN)) begin
                    value_net <= (value_net - 1 < PWM_MIN) ? PWM_MIN : value_net - 1;
                end
                counter_200th <= 0; // Reset counter after modifying value_net
            end
        end
    end
    
    wire [19:0] B = value_net;
    
    
    comparator compare(
        .A(A_net),
        .B(B),
        .PWM(PWM_servo)
    );
      
    // Counts up to a certain value and then resets.
    // This module creates the refresh rate of 20ms.   
    counter count(
        .clr(clr),
        .clk(clk),
        .count(A_net)
    );
    
    // DC Brush Motor logic
    wire [19:0] C_net;
    reg [19:0] value_net_brush;
    reg [7:0] counter_200th_brush = 0;
    
    
    // Modify value_net_brush based on button presses
    always @(posedge clk or posedge clr) begin
        if (clr) begin
            value_net_brush <= 0;
            counter_200th_brush <= 0;
        end else begin
            // Increment the counter
            counter_200th_brush <= counter_200th_brush + 1;

            // Modify value_net_brush every 200th clock cycle
            if (counter_200th_brush == 199) begin
                // Increment when btn_f is pressed
                if (btn_f && (value_net_brush < DC_BRUSH_MAX)) begin
                    value_net_brush <= (value_net_brush + 1 > DC_BRUSH_MAX) ? DC_BRUSH_MAX : value_net_brush + 1;
                end
                // Decrement until reaching zero when btn_f is not pressed
                else if (!btn_f && (value_net_brush > DC_BRUSH_MIN)) begin
                    value_net_brush <= value_net_brush - 1;
                end
                counter_200th_brush <= 0; // Reset counter after modifying value_net_brush
            end
        end
    end
    
    
    wire [19:0] D = value_net_brush;
    
    comparator compare2(
        .A(C_net),
        .B(D),
        .PWM(PWM_brush_motor)
    );
    
    // Counts up to a certain value and then resets.
    // This module creates the refresh rate of 20ms.   
    counter count2(
        .clr(clr),
        .clk(clk),
        .count(C_net)
    );
    
    assign PWM_dir = 1'b1;
    
endmodule