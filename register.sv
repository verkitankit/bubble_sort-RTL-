`timescale 1ns / 1ps
module register_file (
    input  logic        clk,
    input  logic        rst,

    // ALU and memory inputs
    input  logic [15:0] alu_result,
    input  logic [15:0] mem_data_in,

    // MUX controls
    input  logic [1:0]  mux_sel_i,
    input  logic [1:0]  mux_sel_j,
    input  logic        mux_sel_k, 
    input  logic        load_i, load_j, load_k,
    input  logic        load_A, load_B,

    // Register outputs to rest of system
    output logic [9:0]  i, j, k,
    output logic [15:0] A, B
);

    // Internal wires
    logic [9:0] i_next, j_next;
    logic [9:0] zero_10 = 10'd0;

    // MUX for i
    always_comb begin
        case (mux_sel_i)
            2'd0: i_next = zero_10;
            2'd1: i_next = alu_result[9:0];
            default: i_next = 10'dx;
        endcase
    end

    // MUX for j
    always_comb begin
        case (mux_sel_j)
            2'd0: j_next = zero_10;
            2'd1: j_next = alu_result[9:0];
            default: j_next = 10'dx;
        endcase
    end

    // Registers for i, j, k
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            i <= 10'd0;
            j <= 10'd0;
            k <= 10'd0;
        end else begin
            if (load_i) i <= i_next;
            if (load_j) j <= j_next;
            if (load_k) k <= alu_result[9:0]; 
        end
    end

    // Registers for A and B (data from memory)
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            A <= 16'd0;
            B <= 16'd0;
        end else begin
            if (load_A) A <= mem_data_in;
            if (load_B) B <= mem_data_in;
        end
    end

endmodule
