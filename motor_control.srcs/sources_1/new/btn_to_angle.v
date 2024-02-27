`timescale 1ns / 1ps

module btn_to_angle(
    input btn_l,
    input btn_r,
    output reg [8:0] angle
);

    always @(btn_l or btn_r)
    begin
        if (btn_l)  // btn_l pressed
            angle = (angle == 9'd0) ? 0 : angle - 9'd1;
        else if (btn_r)  // btn_r pressed
            angle = (angle == 9'd360) ? 360 : angle + 9'd1;
        else
            angle = angle;
    end

endmodule
