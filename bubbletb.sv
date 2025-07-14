`timescale 1ns / 1ps

module tb_bubble_sort_top;

    logic clk;
    logic rst;
    logic start;
    logic done;

    // Instantiate the DUT
    bubble_sort_top uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Stimulus
    initial begin
        clk = 0;
        rst = 1;
        start = 0;

        $display("===== Simulation Start =====");

        // Reset
        #20 rst = 0;

        // Load unsorted values into memory
        uut.mem.mem_array[0] = 16'd44;
        uut.mem.mem_array[1] = 16'd55;
        uut.mem.mem_array[2] = 16'd31;
        uut.mem.mem_array[3] = 16'd2;
        uut.mem.mem_array[4] = 16'd1;
        uut.mem.mem_array[5] = 16'd5;
        uut.mem.mem_array[6] = 16'd70;
        uut.mem.mem_array[7] = 16'd88;
        uut.mem.mem_array[8] = 16'd99;
        uut.mem.mem_array[9] = 16'd23;

        // Pulse start for 1 cycle
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;

        // Wait for done or timeout
        wait (done);
        $display(">>> Sorting done at %0t", $time);

        // Print results
        $display("===== Sorted Result =====");
        for (int i = 0; i < 10; i++) begin
            $display("mem[%0d] = %0d", i, uut.mem.mem_array[i]);
        end

        $finish;
    end

endmodule

