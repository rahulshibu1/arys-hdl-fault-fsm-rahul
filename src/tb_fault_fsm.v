// tb_fault_fsm.v
// Testbench for fault_fsm.v
// Generates VCD for GTKWave + CSV log for plotting

`timescale 1ns/1ps
module tb_fault_fsm;

    reg clk, rst_n;
    reg ov, uv, ot, uc;
    reg mask_ov, mask_uv, mask_ot, mask_uc;
    reg clear_warning;

    wire [1:0] state;
    wire warn, fault, shutdown;
    wire [2:0] active_fault_id;
    wire [7:0] cnt_uv, cnt_ov, cnt_ot, cnt_uc;

    // DUT instance
    fault_fsm uut(
        .clk(clk), .rst_n(rst_n),
        .ov(ov), .uv(uv), .ot(ot), .uc(uc),
        .mask_ov(mask_ov), .mask_uv(mask_uv), .mask_ot(mask_ot), .mask_uc(mask_uc),
        .clear_warning(clear_warning),
        .state(state), .warn(warn), .fault(fault), .shutdown(shutdown),
        .active_fault_id(active_fault_id),
        .cnt_uv(cnt_uv), .cnt_ov(cnt_ov), .cnt_ot(cnt_ot), .cnt_uc(cnt_uc)
    );

    // Clock generation
    always #5 clk = ~clk;

    // VCD dump for GTKWave
    initial begin
        $dumpfile("tb_fault_fsm.vcd");
        $dumpvars(0, tb_fault_fsm);
        $dumpvars(0, uut);
    end

    // CSV logging
    integer csv;
    initial begin
        csv = $fopen("sim_log.csv","w");
        $fwrite(csv,"time_ns,state,active_fault,warn,fault,shutdown,cnt_uv,cnt_ov,cnt_ot,cnt_uc,ov,uv,ot,uc\n");
    end
    always @(posedge clk) begin
        $fwrite(csv,"%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d\n",
            $time, state, active_fault_id, warn, fault, shutdown,
            cnt_uv, cnt_ov, cnt_ot, cnt_uc, ov, uv, ot, uc);
    end
    initial begin
        #2000;
        $fclose(csv);
    end

    // Stimulus
    initial begin
        clk=0; rst_n=0;
        ov=0; uv=0; ot=0; uc=0;
        mask_ov=0; mask_uv=0; mask_ot=0; mask_uc=0;
        clear_warning=0;

        #20 rst_n=1;

        // Case 1: transient UC (ignored)
        uc=1; #10; uc=0; #50;

        // Case 2: persistent OV -> WARNING -> FAULT -> clear
        ov=1; #200; ov=0; clear_warning=1; #20; clear_warning=0; #50;

        // Case 3: persistent UC -> SHUTDOWN
        uc=1; #400; uc=0; #50;

        // Case 4: masking UC
        mask_uc=1; uc=1; #200; uc=0; mask_uc=0; #50;

        $finish;
    end
endmodule
