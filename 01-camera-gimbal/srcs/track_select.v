`timescale 1ns/1ps
module track_select #(
    parameter integer DEBOUNCE_CYCLES = 500000,
    parameter integer SETTLE_FRAMES = 8
)(input wire clk, input wire button, input wire clear, input wire frame_tick,
  output reg sample_color = 0, output reg tracking_enabled = 0);
    (* ASYNC_REG = "TRUE" *) reg b1 = 0, b2 = 0, c1 = 0, c2 = 0;
    reg button_db = 0;
    reg [19:0] debounce_count = 0;
    reg [3:0] settle_count = 0;
    reg settling = 0;
    always @(posedge clk) begin
        b1 <= button; b2 <= b1;
        c1 <= clear; c2 <= c1;
        sample_color <= 0;
        if (c2) begin
            tracking_enabled <= 0;
            settling <= 0;
            debounce_count <= 0;
            button_db <= b2;
        end else begin
            if (b2 == button_db) debounce_count <= 0;
            else if (debounce_count == DEBOUNCE_CYCLES-1) begin
                button_db <= b2;
                debounce_count <= 0;
            end else debounce_count <= debounce_count + 1'b1;
            if (b2 || button_db) begin
                tracking_enabled <= 0;
                settling <= 0;
                if (!b2 && button_db && debounce_count == DEBOUNCE_CYCLES-1) begin
                    sample_color <= 1;
                    settling <= 1;
                    settle_count <= 0;
                end
            end else if (settling && frame_tick) begin
                if (settle_count == SETTLE_FRAMES-1) begin
                    settling <= 0;
                    tracking_enabled <= 1;
                end else settle_count <= settle_count + 1'b1;
            end
        end
    end
endmodule
