// adc2flag.v
`timescale 1ns/1ps
module adc2flag #(
    parameter WIDTH=12,
    parameter OV_THRESH=12'd3500,
    parameter UV_THRESH=12'd2500,
    parameter HYST=12'd20
)(
    input clk, rst_n,
    input [WIDTH-1:0] adc_sample,
    output reg ov_flag, uv_flag
);
    reg ov_last, uv_last;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            ov_last=0; uv_last=0;
            ov_flag=0; uv_flag=0;
        end else begin
            if(adc_sample>=OV_THRESH) ov_last=1;
            else if(adc_sample<=(OV_THRESH-HYST)) ov_last=0;
            ov_flag=ov_last;

            if(adc_sample<=UV_THRESH) uv_last=1;
            else if(adc_sample>=(UV_THRESH+HYST)) uv_last=0;
            uv_flag=uv_last;
        end
    end
endmodule
