// can_encoder.v
`timescale 1ns/1ps
module can_encoder(
    input clk, rst_n,
    input [1:0] state,
    input [2:0] active_fault,
    output reg [63:0] can_frame
);
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) can_frame<=64'h0;
        else begin
            can_frame[7:0] <= {3'b000, active_fault, state}; // pack state+fault
            can_frame[63:8] <= 56'h0;
        end
    end
endmodule
