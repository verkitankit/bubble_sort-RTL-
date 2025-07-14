`timescale 1ns / 1ps
module control_unit(
  input logic clk,
  input logic rst,
  input logic start,
  input logic lt,gt,eq,
  output logic done,
  output logic load_i,load_j,load_k,
  output logic load_A, load_B,
  output logic [1:0] mux_sel_i,mux_sel_j,
  output logic mux_sel_k,
  output logic [1:0] mux_sel_op1,mux_sel_op2,
  output logic [1:0] mux_sel_mem_addr,
  output logic  mux_sel_mem_data,
  output logic [1:0] alu_op,
  output logic mem_read, mem_write,
  output logic clear_eoc,
  output logic preset_eoc
);
  typedef enum logic [3:0]{
     S0, S1, S2, S3, S4, S5, S6,
      S7, S8, S9, S10, S11, S12
  }state_t;
  state_t state,next;
  always_ff @(posedge clk or posedge rst) begin
    if (rst) state <=S0;
    else begin 
      state<=next;
      $display("FSM State Transition: %0t | current=%0d -> next=%0d", $time, state, next);
    end
  end
  always_comb begin
    next=state;
    case (state)
       S0:  next = start ? S1 : S0;
        S1:  next = S2;
        S2:  next = lt ? S3 : S12;
        S3:  next = S4;
        S4:  next = lt ? S5 : S11;
        S5:  next = S6;
        S6:  next = S7;
        S7:  next = gt ? S8 : S10;
        S8:  next = S9;
        S9:  next = S10;
        S10: next = S4;
        S11: next = S2;
        S12: next = start ? S12: S0;
       
    endcase
  end
  always_comb begin
        // Default all controls to 0
        load_i = 0; load_j = 0; load_k = 0;
        load_A = 0; load_B = 0;
        mux_sel_i = 2'd0;
        mux_sel_j = 2'd0;
        mux_sel_k = 1'b0;
        mux_sel_op1 = 2'd0;
        mux_sel_op2 = 2'd0;
        mux_sel_mem_addr = 2'd0;
        mux_sel_mem_data = 1'b0;
        alu_op = 2'd0;
        mem_read = 0;
        mem_write = 0;
        done = 0;
        clear_eoc = 0;
        preset_eoc = 0;

        case (state)
            S0: begin
                clear_eoc = 1;
            end
            S1: begin
                load_j = 1;
                mux_sel_j = 2'd0;  // j = 0
            end
            S2: begin
                mux_sel_op1 = 2'd1; // j
                mux_sel_op2 = 2'd1; // N-1
                alu_op = 2'd1;      // COMP
            end
            S3: begin
                load_i = 1;
                mux_sel_i = 2'd0; // i = 0
            end
            S4: begin
                mux_sel_op1 = 2'd0; // i
                mux_sel_op2 = 2'd1; // N-1
                alu_op = 2'd1;      // COMP
            end
            S5: begin
                mux_sel_mem_addr = 2'd0; // i
                mem_read = 1;
                load_A = 1;

                // k = i + 1
                mux_sel_op1 = 2'd0;  // i
                mux_sel_op2 = 2'd2;  // 1
                alu_op = 2'd0;       // ADD
                mux_sel_k = 1'b0;
                load_k = 1;
            end
            S6: begin
                mux_sel_mem_addr = 2'd2; // k
                mem_read = 1;
                load_B = 1;
            end
            S7: begin
                mux_sel_op1 = 2'd2; // A
                mux_sel_op2 = 2'd0; // B
                alu_op = 2'd1;      // COMP
            end
            S8: begin
                mux_sel_mem_addr = 2'd0;   // i
                mux_sel_mem_data = 1'b0;   // B
                mem_write = 1;
            end
            S9: begin
                mux_sel_mem_addr = 2'd2;   // k
                mux_sel_mem_data = 1'b1;   // A
                mem_write = 1;
            end
            S10: begin
                mux_sel_op1 = 2'd0; // i
                mux_sel_op2 = 2'd2; // 1
                alu_op = 2'd0;      // ADD
                mux_sel_i = 2'd1;
                load_i = 1;
            end
            S11: begin
                mux_sel_op1 = 2'd1; // j
                mux_sel_op2 = 2'd2; // 1
        
              alu_op = 2'd0;      // ADD
                mux_sel_j = 2'd1;
                load_j = 1;
            end
            S12: begin
                preset_eoc = 1;
                done = 1;
            end
        endcase
    end
  


endmodule
  