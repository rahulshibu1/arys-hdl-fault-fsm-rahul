// fault_fsm.v
// HDL Fault Detection FSM
// States: NORMAL -> WARNING -> FAULT -> SHUTDOWN

`timescale 1ns/1ps
module fault_fsm #(
    parameter integer P_WARN   = 5,   // cycles to assert WARNING
    parameter integer P_FAULT  = 12,  // cycles to assert FAULT
    parameter integer P_SHUT   = 30   // cycles to assert SHUTDOWN
)(
    input  wire clk,
    input  wire rst_n,
    input  wire ov, uv, ot, uc,      // fault inputs
    input  wire mask_ov, mask_uv, mask_ot, mask_uc, // masking
    input  wire clear_warning,       // operator ack
    output reg  [1:0] state,         // FSM state
    output reg  warn, fault, shutdown,
    output reg  [2:0] active_fault_id
);

    // State encoding
    localparam S_NORMAL   = 2'b00;
    localparam S_WARNING  = 2'b01;
    localparam S_FAULT    = 2'b10;
    localparam S_SHUTDOWN = 2'b11;

    // Apply masks
    wire a_uv = uv & ~mask_uv;
    wire a_ov = ov & ~mask_ov;
    wire a_ot = ot & ~mask_ot;
    wire a_uc = uc & ~mask_uc;

    // Fault priority: UC > OT > OV > UV
    reg [2:0] chosen_fault;
    always @(*) begin
        if (a_uc) chosen_fault = 3'd4;
        else if (a_ot) chosen_fault = 3'd3;
        else if (a_ov) chosen_fault = 3'd2;
        else if (a_uv) chosen_fault = 3'd1;
        else chosen_fault = 3'd0;
    end
    always @(*) active_fault_id = chosen_fault;

    // Counters
    integer cnt_uv, cnt_ov, cnt_ot, cnt_uc;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_uv <= 0; cnt_ov <= 0; cnt_ot <= 0; cnt_uc <= 0;
        end else begin
            cnt_uv <= a_uv ? cnt_uv+1 : 0;
            cnt_ov <= a_ov ? cnt_ov+1 : 0;
            cnt_ot <= a_ot ? cnt_ot+1 : 0;
            cnt_uc <= a_uc ? cnt_uc+1 : 0;
        end
    end

    // Next state logic
    reg [1:0] nxt_state;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= S_NORMAL;
        else state <= nxt_state;
    end

    always @(*) begin
        warn=0; fault=0; shutdown=0;
        nxt_state = state;
        case(state)
            S_NORMAL: if(chosen_fault!=0 && (
                          (a_uv && cnt_uv>=P_WARN) ||
                          (a_ov && cnt_ov>=P_WARN) ||
                          (a_ot && cnt_ot>=P_WARN) ||
                          (a_uc && cnt_uc>=P_WARN))) nxt_state=S_WARNING;
            S_WARNING: begin
                warn=1;
                if(chosen_fault==0) begin
                    if(clear_warning) nxt_state=S_NORMAL;
                end else if(
                    (a_uv && cnt_uv>=P_FAULT) ||
                    (a_ov && cnt_ov>=P_FAULT) ||
                    (a_ot && cnt_ot>=P_FAULT) ||
                    (a_uc && cnt_uc>=P_FAULT)) nxt_state=S_FAULT;
            end
            S_FAULT: begin
                fault=1;
                if(chosen_fault==0) begin
                    if(clear_warning) nxt_state=S_NORMAL;
                end else if(
                    (a_uv && cnt_uv>=P_SHUT) ||
                    (a_ov && cnt_ov>=P_SHUT) ||
                    (a_ot && cnt_ot>=P_SHUT) ||
                    (a_uc && cnt_uc>=P_SHUT)) nxt_state=S_SHUTDOWN;
            end
            S_SHUTDOWN: begin
                shutdown=1;
                nxt_state=S_SHUTDOWN;
            end
        endcase
    end
endmodule
