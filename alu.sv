`timescale 1ns / 1ps
module alu (
    input  logic [15:0] op1,
    input  logic [15:0] op2,
    input  logic [1:0]  alu_op, 
    output logic [15:0] result,
    output logic        lt, gt, eq
);
    always_comb begin
        result = 16'd0;
        lt = 0;
        gt = 0;
        eq = 0;

        case (alu_op)
            2'b00: begin // ADD
                result = op1 + op2;
            end

           2'b01: begin
            result = 16'd0; // still needed by external logic
            if (op1 < op2)  lt = 1;
            else if (op1 > op2) gt = 1;
            else eq = 1;
             $monitor("ALU: op1=%0d, op2=%0d, op=%b -> lt=%b gt=%b eq=%b",op1, op2, alu_op, lt, gt, eq);
             
        end

            default: begin
                result = 16'd0;
            end
        endcase
    end
  

endmodule
