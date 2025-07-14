`timescale 1ns / 1ps
//`include "register.sv"
//`include "alu.sv"
//`include "memory_block.sv"
module bubble_sort_top (
    input  logic clk,
    input  logic rst,
    input  logic start,
    output logic done
);

    // Internal signals
    logic [15:0] alu_result;
    logic [15:0] op1, op2;
    logic        lt, gt, eq;

    // Register outputs
    logic [9:0] i, j, k;
    logic [15:0] A, B;

    // Control signals
    logic load_i, load_j, load_k, load_A, load_B;
    logic [1:0] mux_sel_i, mux_sel_j, mux_sel_op1, mux_sel_op2, mux_sel_mem_addr;
    logic mux_sel_k, mux_sel_mem_data;
    logic [1:0] alu_op;
    logic mem_read, mem_write;
    logic clear_eoc, preset_eoc;

    // Memory interface
    logic [9:0] mem_addr;
    logic [15:0] mem_data_in, mem_data_out;
    localparam N=10 ;
    localparam N_MINUS_1 = N - 1;
  

    // ALU Operand Mux
    always_comb begin
        case (mux_sel_op1)
            2'd0: op1 = {{6'd0}, i};     
            2'd1: op1 = {{6'd0}, j};
            2'd2: op1 = A;
            default: op1 = 16'd0;
        endcase

        case (mux_sel_op2)
            2'd0: op2 = B;
            2'd1: op2 = N_MINUS_1;  // N-1 = 9
            2'd2: op2 = 16'd1;
            default: op2 = 16'd0;
        endcase
    end

    // Memory Address MUX
    always_comb begin
        case (mux_sel_mem_addr)
            2'd0: mem_addr = i;
            2'd1: mem_addr = j;
            2'd2: mem_addr = k;
            default: mem_addr = 10'd0;
        endcase
    end

    // Memory Data Input MUX
    assign mem_data_in = (mux_sel_mem_data == 1'b0) ? B : A;

    // EOC Register (preset and clear)
    logic eoc;
    always_ff @(posedge clk or posedge rst) begin
        if (rst || clear_eoc)
            eoc <= 1'b0;
        else if (preset_eoc)
            eoc <= 1'b1;
    end

    // Output
    assign done = eoc;
  always_ff @(posedge clk) begin
    $display("DEBUG: time=%0t | op1=%0d, op2=%0d, lt=%b, gt=%b, eq=%b, alu_op=%b", 
              $time, op1, op2, lt, gt, eq, alu_op);
end
  

    // Instantiate Modules

    control_unit cu (
        .clk(clk),
        .rst(rst),
        .start(start),
        .lt(lt),
        .gt(gt),
        .eq(eq),
        .done(),
        .load_i(load_i),
        .load_j(load_j),
        .load_k(load_k),
        .load_A(load_A),
        .load_B(load_B),
        .mux_sel_i(mux_sel_i),
        .mux_sel_j(mux_sel_j),
        .mux_sel_k(mux_sel_k),
        .mux_sel_op1(mux_sel_op1),
        .mux_sel_op2(mux_sel_op2),
        .mux_sel_mem_addr(mux_sel_mem_addr),
        .mux_sel_mem_data(mux_sel_mem_data),
        .alu_op(alu_op),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .clear_eoc(clear_eoc),
        .preset_eoc(preset_eoc)
    );

    register_file rf (
        .clk(clk),
        .rst(rst),
        .alu_result(alu_result),
        .mem_data_in(mem_data_out),
        .mux_sel_i(mux_sel_i),
        .mux_sel_j(mux_sel_j),
        .mux_sel_k(mux_sel_k),
        .load_i(load_i),
        .load_j(load_j),
        .load_k(load_k),
        .load_A(load_A),
        .load_B(load_B),
        .i(i),
        .j(j),
        .k(k),
        .A(A),
        .B(B)
    );

    alu alu_unit (
        .op1(op1),
        .op2(op2),
        .alu_op(alu_op),
        .result(alu_result),
        .lt(lt),
        .gt(gt),
        .eq(eq)
    );

    memory_block mem (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .addr(mem_addr),
        .data_in(mem_data_in),
        .data_out(mem_data_out)
    );

endmodule
