`timescale 1ns / 1ps
module pwm(input wire clk, input wire pixel_clk,
    input wire [11:0] counter_h, input wire [10:0] counter_v,
    input wire track_enable, output wire pwm_h, output wire pwm_v,
    input wire external_mode, input wire [7:0] target_generation,
    input wire direct_enable, input wire [11:0] direct_h_us, direct_v_us,
    output reg [17:0] reported_h = 150000, reported_v = 150000);
    localparam integer PERIOD = 2000000;
    localparam integer S1_NEAR_H_MIN_MS = 45;
    localparam integer S1_NEAR_V_MIN_MS = 60;
    localparam [13:0] S1_BRAKE_H_INTERVALS = 14'd3;
    localparam [13:0] S1_BRAKE_V_INTERVALS = 14'd4;
    localparam [2:0] S1_NEAR_H_DELAY = (S1_NEAR_H_MIN_MS + 19) / 20 - 1;
    localparam [2:0] S1_NEAR_V_DELAY = (S1_NEAR_V_MIN_MS + 19) / 20 - 1;
    reg [20:0] count = 0;
    reg [17:0] pulse_h = 150000, pulse_v = 150000;
    (* ASYNC_REG = "TRUE" *) reg run1 = 0, run2 = 0;
    reg req = 0;
    reg snapshot_direct = 0;
    reg [11:0] snapshot_direct_h = 1500, snapshot_direct_v = 1500;
    reg target_direct = 0;
    reg [17:0] direct_h_ticks = 150000, direct_v_ticks = 150000;
    (* ASYNC_REG = "TRUE" *) reg direct1 = 0, direct2 = 0;
    reg pose_req = 0, pose_ack = 0;
    (* ASYNC_REG = "TRUE" *) reg pose_req1 = 0, pose_req2 = 0, pose_ack1 = 0, pose_ack2 = 0;
    reg [17:0] pose_h = 150000, pose_v = 150000;
    (* ASYNC_REG = "TRUE" *) reg req1 = 0, req2 = 0, ack1 = 0, ack2 = 0;
    reg ack = 0;
    reg [11:0] snapshot_h = 0;
    reg [10:0] snapshot_v = 0;
    reg snapshot_en = 0;
    reg snapshot_external = 0;
    reg [7:0] snapshot_generation = 0;
    reg [11:0] target_h = 0;
    reg [10:0] target_v = 0;
    reg target_en = 0;
    reg target_external = 0;
    reg [7:0] received_generation = 0;
    (* ASYNC_REG = "TRUE" *) reg external1 = 0, external2 = 0;
    reg s1_active = 0;
    reg [7:0] consumed_generation = 0;
    reg [1:0] s1_candidate_h = 0, s1_candidate_v = 0;
    reg s1_locked_h = 0, s1_locked_v = 0;
    reg [1:0] s1_escape_h = 0, s1_escape_v = 0;
    reg [2:0] s1_cooldown_h = 0, s1_cooldown_v = 0;
    reg [2:0] s1_coast_h = 0, s1_coast_v = 0;
    reg [2:0] s1_delay_h = 5, s1_delay_v = 5;
    reg [3:0] s1_missing_frames = 10;
    reg s1_previous_valid = 0;
    reg [11:0] s1_previous_error_h = 0;
    reg [10:0] s1_previous_error_v = 0;
    reg [11:0] s1_closing_h = 0;
    reg [10:0] s1_closing_v = 0;
    reg s1_brake_h = 0, s1_brake_v = 0;
    reg [17:0] s1_move_step_h = 200, s1_move_step_v = 200;
    reg [5:0] tracking_frames = 0;
    reg [1:0] candidate_h = 0, candidate_v = 0;
    reg [1:0] direction_h = 0, direction_v = 0;
    reg [11:0] error_h = 0;
    reg [10:0] error_v = 0;
    reg [17:0] cached_gain_h = 200, cached_gain_v = 200;
    reg [17:0] move_step_h = 200, move_step_v = 200;
    reg locked_h = 0, locked_v = 0;
    reg [1:0] escape_h = 0, escape_v = 0;
    reg [1:0] coast_h = 0, coast_v = 0;
    reg previous_valid = 0;
    reg [11:0] previous_error_h = 0, closing_h = 0;
    reg [10:0] previous_error_v = 0, closing_v = 0;
    reg [1:0] previous_side_h = 0, previous_side_v = 0;
    reg brake_h = 0, brake_v = 0;
    wire [1:0] desired_h = target_h < 150 ? 2'd1 : target_h > 170 ? 2'd2 : 2'd0;
    wire [1:0] desired_v = target_v < 110 ? 2'd1 : target_v > 130 ? 2'd2 : 2'd0;
    wire crossed_h = previous_valid && previous_side_h != 0 && desired_h != 0 && previous_side_h != desired_h;
    wire crossed_v = previous_valid && previous_side_v != 0 && desired_v != 0 && previous_side_v != desired_v;
    wire [17:0] gain_h = error_h <= 24 ? 18'd200 : error_h <= 40 ? 18'd500 :
                        error_h <= 70 ? 18'd1000 : error_h <= 100 ? 18'd1800 :
                        error_h < 120 ? 18'd3000 : 18'd6000;
    wire [17:0] gain_v = error_v <= 18 ? 18'd200 : error_v <= 30 ? 18'd500 :
                        error_v <= 52 ? 18'd1000 : error_v <= 75 ? 18'd1800 :
                        error_v < 90 ? 18'd3000 : 18'd6000;
    wire [17:0] engagement_cap = tracking_frames < 25 ? 18'd500 :
                                 tracking_frames < 50 ? 18'd1500 : 18'd6000;
    wire [17:0] step_h = direction_h != desired_h ? 18'd200 :
                        cached_gain_h > engagement_cap ? engagement_cap : cached_gain_h;
    wire [17:0] step_v = direction_v != desired_v ? 18'd200 :
                        cached_gain_v > engagement_cap ? engagement_cap : cached_gain_v;
    wire [17:0] s1_step_h = error_h <= 8 ? 18'd210 : error_h <= 24 ? 18'd800 :
                          error_h <= 40 ? 18'd1000 : error_h <= 70 ? 18'd2247 :
                          error_h <= 100 ? 18'd3371 : 18'd4269;
    wire [17:0] s1_step_v = error_v <= 8 ? 18'd200 : error_v <= 24 ? 18'd300 :
                          gain_v >= 3000 ? 18'd3000 : gain_v;
    wire [1:0] s1_desired_h = target_h < 156 ? 2'd1 : target_h > 164 ? 2'd2 : 2'd0;
    wire [1:0] s1_desired_v = target_v < 116 ? 2'd1 : target_v > 124 ? 2'd2 : 2'd0;
    wire s1_reverse_h = s1_candidate_h != 0 && s1_desired_h != 0 && s1_candidate_h != s1_desired_h;
    wire s1_reverse_v = s1_candidate_v != 0 && s1_desired_v != 0 && s1_candidate_v != s1_desired_v;
    always @(posedge pixel_clk) begin
        req1 <= req; req2 <= req1;
        pose_ack1 <= pose_ack; pose_ack2 <= pose_ack1;
        if (pose_req == pose_ack2) begin
            reported_h <= pose_h; reported_v <= pose_v;
            pose_req <= ~pose_req;
        end
        if (req2 != ack) begin
            snapshot_h <= counter_h;
            snapshot_v <= counter_v;
            snapshot_en <= track_enable;
            snapshot_external <= external_mode;
            snapshot_generation <= target_generation;
            snapshot_direct <= direct_enable;
            snapshot_direct_h <= direct_h_us; snapshot_direct_v <= direct_v_us;
            ack <= req2;
        end
    end
    assign pwm_h = count < pulse_h;
    assign pwm_v = count < pulse_v;
    always @(posedge clk) begin
        direct1 <= direct_enable; direct2 <= direct1;
        pose_req1 <= pose_req; pose_req2 <= pose_req1;
        if (pose_req2 != pose_ack) begin
            pose_h <= pulse_h; pose_v <= pulse_v;
            pose_ack <= pose_req2;
        end
        error_h <= target_h > 160 ? target_h-160 : 160-target_h;
        error_v <= target_v > 120 ? target_v-120 : 120-target_v;
        cached_gain_h <= gain_h; cached_gain_v <= gain_v;
        move_step_h <= step_h; move_step_v <= step_v;
        s1_move_step_h <= s1_step_h; s1_move_step_v <= s1_step_v;
        s1_delay_h <= error_h <= 24 ? S1_NEAR_H_DELAY : error_h <= 70 ? 3 : 2;
        s1_delay_v <= error_v <= 24 ? S1_NEAR_V_DELAY : error_v <= 70 ? 3 : 1;
        s1_closing_h <= s1_previous_error_h > error_h ? s1_previous_error_h-error_h : 0;
        s1_closing_v <= s1_previous_error_v > error_v ? s1_previous_error_v-error_v : 0;
        s1_brake_h <= s1_previous_valid && s1_candidate_h == s1_desired_h &&
                      s1_closing_h != 0 && {2'b0,error_h} <= 14'd4 + {2'b0,s1_closing_h} * S1_BRAKE_H_INTERVALS;
        s1_brake_v <= s1_previous_valid && s1_candidate_v == s1_desired_v &&
                      s1_closing_v != 0 && {3'b0,error_v} <= 14'd4 + {3'b0,s1_closing_v} * S1_BRAKE_V_INTERVALS;
        closing_h <= previous_error_h > error_h ? previous_error_h-error_h : 0;
        closing_v <= previous_error_v > error_v ? previous_error_v-error_v : 0;
        brake_h <= previous_valid && previous_side_h == desired_h && desired_h != 0 &&
                   closing_h != 0 && {2'b0,error_h} <= 14'd12 + {2'b0,closing_h} * 14'd3;
        brake_v <= previous_valid && previous_side_v == desired_v && desired_v != 0 &&
                   closing_v != 0 && {3'b0,error_v} <= 14'd12 + {3'b0,closing_v} * 14'd3;
        run1 <= track_enable; run2 <= run1;
        external1 <= external_mode; external2 <= external1;
        ack1 <= ack; ack2 <= ack1;
        if (req == ack2) begin
            target_h <= snapshot_h;
            target_v <= snapshot_v;
            target_en <= snapshot_en;
            target_external <= snapshot_external;
            received_generation <= snapshot_generation;
            target_direct <= snapshot_direct;
            direct_h_ticks <= snapshot_direct_h * 18'd100;
            direct_v_ticks <= snapshot_direct_v * 18'd100;
        end
        if (count == PERIOD-1000 && req == ack2) req <= ~req;
        if (count == PERIOD-1) begin
            count <= 0;
            if (req == ack2 && direct2 && target_direct &&
                direct_h_ticks >= 50000 && direct_h_ticks <= 250000 &&
                direct_v_ticks >= 125000 && direct_v_ticks <= 250000) begin
                if (pulse_h < direct_h_ticks)
                    pulse_h <= direct_h_ticks-pulse_h > 2500 ? pulse_h+18'd2500 : direct_h_ticks;
                else if (pulse_h > direct_h_ticks)
                    pulse_h <= pulse_h-direct_h_ticks > 2500 ? pulse_h-18'd2500 : direct_h_ticks;
                if (pulse_v < direct_v_ticks)
                    pulse_v <= direct_v_ticks-pulse_v > 2500 ? pulse_v+18'd2500 : direct_v_ticks;
                else if (pulse_v > direct_v_ticks)
                    pulse_v <= pulse_v-direct_v_ticks > 2500 ? pulse_v-18'd2500 : direct_v_ticks;
            end
            if (s1_cooldown_h != 0) s1_cooldown_h <= s1_cooldown_h - 1'b1;
            if (s1_cooldown_v != 0) s1_cooldown_v <= s1_cooldown_v - 1'b1;
            if (s1_coast_h != 0) s1_coast_h <= s1_coast_h - 1'b1;
            if (s1_coast_v != 0) s1_coast_v <= s1_coast_v - 1'b1;
            if (req == ack2) begin
                if (target_external || external2) begin
                    tracking_frames <= 0;
                    candidate_h <= 0; candidate_v <= 0;
                    direction_h <= 0; direction_v <= 0;
                    locked_h <= 0; locked_v <= 0;
                    escape_h <= 0; escape_v <= 0;
                    coast_h <= 0; coast_v <= 0;
                    previous_valid <= 0;
                    previous_error_h <= 0; previous_error_v <= 0;
                    previous_side_h <= 0; previous_side_v <= 0;
                    if (s1_missing_frames < 10) s1_missing_frames <= s1_missing_frames + 1'b1;
                    if (s1_missing_frames >= 9) begin
                        s1_candidate_h <= 0; s1_candidate_v <= 0;
                        s1_locked_h <= 0; s1_locked_v <= 0;
                        s1_escape_h <= 0; s1_escape_v <= 0;
                        s1_previous_valid <= 0;
                    end
                    if (target_external != external2 || !s1_active) begin
                        s1_active <= target_external && external2;
                        consumed_generation <= received_generation;
                        s1_candidate_h <= 0; s1_candidate_v <= 0;
                        s1_locked_h <= 0; s1_locked_v <= 0;
                        s1_escape_h <= 0; s1_escape_v <= 0;
                        s1_previous_valid <= 0;
                        s1_missing_frames <= 10;
                        s1_coast_h <= 0; s1_coast_v <= 0;
                    end else if (!run2 || !target_en || target_h == 0 || target_v == 0 || target_h >= 320 || target_v >= 240) begin
                        consumed_generation <= received_generation;
                        s1_previous_valid <= 0;
                    end else if (received_generation != consumed_generation) begin
                        consumed_generation <= received_generation;
                        s1_missing_frames <= 0;
                        s1_candidate_h <= s1_desired_h; s1_candidate_v <= s1_desired_v;
                        s1_previous_error_h <= error_h; s1_previous_error_v <= error_v;
                        s1_previous_valid <= 1;
                        if (s1_brake_h || s1_reverse_h) s1_coast_h <= 4;
                        if (s1_brake_v || s1_reverse_v) s1_coast_v <= 4;
                        if (error_h <= 4) begin
                            s1_locked_h <= 1; s1_escape_h <= 0; s1_candidate_h <= 0;
                        end else if (s1_locked_h) begin
                            if (error_h >= 6) begin
                                if (s1_escape_h == 1) begin s1_locked_h <= 0; s1_escape_h <= 0; end
                                else s1_escape_h <= s1_escape_h + 1'b1;
                            end else s1_escape_h <= 0;
                        end else if (s1_desired_h != 0 && s1_candidate_h == s1_desired_h &&
                                     s1_missing_frames < 10 && s1_cooldown_h == 0 && s1_coast_h == 0 &&
                                     !s1_brake_h && !s1_reverse_h) begin
                            s1_cooldown_h <= s1_delay_h;
                            if (s1_desired_h == 1 && pulse_h < 250000)
                                pulse_h <= pulse_h + s1_move_step_h > 250000 ? 250000 : pulse_h + s1_move_step_h;
                            else if (s1_desired_h == 2 && pulse_h > 50000)
                                pulse_h <= pulse_h < 50000 + s1_move_step_h ? 50000 : pulse_h - s1_move_step_h;
                        end
                        if (error_v <= 4) begin
                            s1_locked_v <= 1; s1_escape_v <= 0; s1_candidate_v <= 0;
                        end else if (s1_locked_v) begin
                            if (error_v >= 6) begin
                                if (s1_escape_v == 1) begin s1_locked_v <= 0; s1_escape_v <= 0; end
                                else s1_escape_v <= s1_escape_v + 1'b1;
                            end else s1_escape_v <= 0;
                        end else if (s1_desired_v != 0 && s1_candidate_v == s1_desired_v &&
                                     s1_missing_frames < 10 && s1_cooldown_v == 0 && s1_coast_v == 0 &&
                                     !s1_brake_v && !s1_reverse_v) begin
                            s1_cooldown_v <= s1_delay_v;
                            if (s1_desired_v == 1 && pulse_v < 250000)
                                pulse_v <= pulse_v + s1_move_step_v > 250000 ? 250000 : pulse_v + s1_move_step_v;
                            else if (s1_desired_v == 2 && pulse_v > 125000)
                                pulse_v <= pulse_v < 125000 + s1_move_step_v ? 125000 : pulse_v - s1_move_step_v;
                        end
                    end
                end else begin
                    s1_active <= 0;
                    s1_candidate_h <= 0; s1_candidate_v <= 0;
                    s1_locked_h <= 0; s1_locked_v <= 0;
                    s1_escape_h <= 0; s1_escape_v <= 0;
                    s1_previous_valid <= 0;
                    s1_missing_frames <= 10;
                    s1_coast_h <= 0; s1_coast_v <= 0;
                if (run2 && target_en && target_h != 0 && target_v != 0 && target_h < 320 && target_v < 240) begin
                    if (tracking_frames < 50) tracking_frames <= tracking_frames + 1'b1;
                    candidate_h <= desired_h;
                    candidate_v <= desired_v;
                    previous_valid <= 1;
                    previous_error_h <= error_h; previous_error_v <= error_v;
                    previous_side_h <= desired_h; previous_side_v <= desired_v;
                    if (error_h <= 12) begin
                        locked_h <= 1; escape_h <= 0;
                    end else if (locked_h) begin
                        if (error_h >= 22) begin
                            if (escape_h == 2) begin locked_h <= 0; escape_h <= 0; end
                            else escape_h <= escape_h + 1'b1;
                        end else escape_h <= 0;
                    end else escape_h <= 0;
                    if (error_v <= 12) begin
                        locked_v <= 1; escape_v <= 0;
                    end else if (locked_v) begin
                        if (error_v >= 22) begin
                            if (escape_v == 2) begin locked_v <= 0; escape_v <= 0; end
                            else escape_v <= escape_v + 1'b1;
                        end else escape_v <= 0;
                    end else escape_v <= 0;
                    if (brake_h || crossed_h) coast_h <= 3;
                    else if (coast_h != 0) coast_h <= coast_h - 1'b1;
                    if (brake_v || crossed_v) coast_v <= 3;
                    else if (coast_v != 0) coast_v <= coast_v - 1'b1;
                    if (crossed_h) direction_h <= 0;
                    if (crossed_v) direction_v <= 0;
                    if (tracking_frames >= 3) begin
                        if (!locked_h && error_h > 12 && !brake_h && !crossed_h && coast_h == 0 &&
                            candidate_h == desired_h && desired_h != 0) begin
                            direction_h <= desired_h;
                            if (desired_h == 1 && pulse_h < 250000)
                                pulse_h <= (pulse_h + move_step_h > 250000) ? 250000 : pulse_h + move_step_h;
                            else if (desired_h == 2 && pulse_h > 50000)
                                pulse_h <= (pulse_h < 50000 + move_step_h) ? 50000 : pulse_h - move_step_h;
                        end
                        if (!locked_v && error_v > 12 && !brake_v && !crossed_v && coast_v == 0 &&
                            candidate_v == desired_v && desired_v != 0) begin
                            direction_v <= desired_v;
                            if (desired_v == 1 && pulse_v < 250000)
                                pulse_v <= (pulse_v + move_step_v > 250000) ? 250000 : pulse_v + move_step_v;
                            else if (desired_v == 2 && pulse_v > 125000)
                                pulse_v <= (pulse_v < 125000 + move_step_v) ? 125000 : pulse_v - move_step_v;
                        end
                    end
                end else begin
                    tracking_frames <= 0;
                    candidate_h <= 0; candidate_v <= 0;
                    direction_h <= 0; direction_v <= 0;
                    locked_h <= 0; locked_v <= 0;
                    escape_h <= 0; escape_v <= 0;
                    coast_h <= 0; coast_v <= 0;
                    previous_valid <= 0;
                    previous_error_h <= 0; previous_error_v <= 0;
                    previous_side_h <= 0; previous_side_v <= 0;
                end
                end
            end
        end else count <= count + 1'b1;
    end
endmodule
