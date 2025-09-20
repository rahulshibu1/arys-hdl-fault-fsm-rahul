// tb_fault_fsm.v
`timescale 1ns/1ps
module tb_fault_fsm;
    reg clk, rst_n;
    reg ov, uv, ot, uc;
    reg mask_ov, mask_uv, mask_ot, mask_uc;
    reg clear_warning;
    wire [1:0] state;
    wire warn, fault, shutdown;
    wire [2:0] active_fault_id;

    fault_fsm uut(
        .clk(clk), .rst_n(rst_n),
        .ov(ov), .uv(uv), .ot(ot), .uc(uc),
        .mask_ov(mask_ov), .mask_uv(mask_uv), .mask_ot(mask_ot), .mask_uc(mask_uc),
        .clear_warning(clear_warning),
        .state(state), .warn(warn), .fault(fault), .shutdown(shutdown),
        .active_fault_id(active_fault_id)
    );

    // clock
    always #5 clk = ~clk;

    initial begin
        $dumpfile("tb_fault_fsm.vcd");
        $dumpvars(0,tb_fault_fsm);

        clk=0; rst_n=0; ov=0; uv=0; ot=0; uc=0;
        mask_ov=0; mask_uv=0; mask_ot=0; mask_uc=0;
        clear_warning=0;

        #20 rst_n=1;

        // Test transient UC
        uc=1; #10; uc=0; #50;

        // Test persistent OV
        ov=1; #200; ov=0; clear_warning=1; #20; clear_warning=0; #50;

        // Test persistent UC -> shutdown
        uc=1; #400; uc=0; #50;

        // Masking
        mask_uc=1; uc=1; #200; uc=0; mask_uc=0; #50;

        $finish;
    end
endmodule
