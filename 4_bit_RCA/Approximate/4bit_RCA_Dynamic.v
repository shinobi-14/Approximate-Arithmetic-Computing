`timescale 1ns/1ps

module dynamic_rca_4bit (
    input  [3:0] A, B,       // 4-bit inputs
    input        Cin,        // Carry in
    input  [1:0] mode,       // Mode select
    output [3:0] Sum,        // 4-bit Sum output
    output       Cout        // Final Carry out
);

    // Internal exact computation
    wire [3:0] sum_exact;
    wire [2:0] carry;
    wire       carry3;

    // Mode control signals
    wire carry_cut_en = (mode == 2'b01) || (mode == 2'b11); // Mode1, Mode3
    wire or_en        = (mode == 2'b10) || (mode == 2'b11); // Mode2, Mode3
    wire spec_pred_en = (mode == 2'b11);                    // Mode3 only

    // Exact Ripple-Carry Addition (reference)
    assign {carry[0], sum_exact[0]} = A[0] + B[0] + Cin;
    assign {carry[1], sum_exact[1]} = A[1] + B[1] + carry[0];
    assign {carry[2], sum_exact[2]} = A[2] + B[2] + carry[1];
    assign {carry3,   sum_exact[3]} = A[3] + B[3] + carry[2];

    // Registers for approximate result
    reg [3:0] sum_reg;
    reg       cout_reg;

    // Temp registers used inside always
    reg c0, c1, c2;
    reg [3:0] sum_tmp;

    always @(*) begin
        case (mode)
            2'b00: begin
                // Mode 0: Exact RCA
                sum_reg  = sum_exact;
                cout_reg = carry3;
            end

            2'b01: begin
                // Mode 1: Carry cut after FA1
                {c0, sum_tmp[0]} = A[0] + B[0] + Cin;
                {c1, sum_tmp[1]} = A[1] + B[1] + c0;
                sum_tmp[2] = A[2] ^ B[2];   // carry cut (Cin=0)
                sum_tmp[3] = A[3] ^ B[3];   // carry cut (Cin=0)
                sum_reg  = sum_tmp;
                cout_reg = 1'b0;
            end

            2'b10: begin
                // Mode 2: Lower-part OR (FA0 replaced by OR)
                sum_tmp[0] = A[0] | B[0];  // OR replacement
                {c1, sum_tmp[1]} = A[1] + B[1] + 1'b0;
                {c2, sum_tmp[2]} = A[2] + B[2] + c1;
                {cout_reg, sum_tmp[3]} = A[3] + B[3] + c2;
                sum_reg = sum_tmp;
            end

            2'b11: begin
                // Mode 3: OR + Speculative Carry Prediction
                sum_tmp[0] = A[0] | B[0];
                {c1, sum_tmp[1]} = A[1] + B[1] + 1'b0;
                {c2, sum_tmp[2]} = A[2] + B[2] + c1;
                // Speculative predictor for FA3
                if (A[2] & B[2])
                    {cout_reg, sum_tmp[3]} = A[3] + B[3] + 1'b1;
                else
                    {cout_reg, sum_tmp[3]} = A[3] + B[3] + 1'b0;
                sum_reg = sum_tmp;
            end

            default: begin
                sum_reg  = sum_exact;
                cout_reg = carry3;
            end
        endcase
    end

    // Outputs
    assign Sum  = sum_reg;
    assign Cout = cout_reg;

endmodule

Test Bench: -

Test Bench :- 

`timescale 1ns/1ps

module tb_dynamic_rca_4bit;

    reg  [3:0] A, B;
    reg        Cin;
    reg  [1:0] mode;
    wire [3:0] Sum;
    wire       Cout;

    // DUT instance
    dynamic_rca_4bit uut (
        .A(A),
        .B(B),
        .Cin(Cin),
        .mode(mode),
        .Sum(Sum),
        .Cout(Cout)
    );

    // Reference exact RCA (used for error calculation)
    reg [4:0] exact_sum;  // 5-bit to capture Cout + Sum
    reg [4:0] approx_sum;
    integer   error_val;
    real      error_perc;

    integer i, j, k, m;

    initial begin
        $display("===========================================================================");
        $display("   A   B  Cin | Mode | Exact Sum | Approx Sum | Error | Error %%");
        $display("===========================================================================");

        // Iterate through a subset of inputs (you can expand to all 16x16x2 cases if needed)
        for (i = 0; i < 16; i = i+1) begin
            for (j = 0; j < 16; j = j+1) begin
                for (k = 0; k < 2; k = k+1) begin
                    // compute exact result
                    A   = i[3:0];
                    B   = j[3:0];
                    Cin = k[0];

                    exact_sum = A + B + Cin;

                    // Sweep modes
                    for (m = 0; m < 4; m = m+1) begin
                        mode = m[1:0];

                        #1; // small delay for propagation

                        approx_sum = {Cout, Sum};
                        error_val  = exact_sum - approx_sum;
                        if (error_val < 0)
                            error_val = -error_val;

                        if (exact_sum != 0)
                            error_perc = (error_val * 100.0) / exact_sum;
                        else
                            error_perc = 0.0;

                        $display("%4b %4b   %1b   |  %2b   |   %5d    |    %5d    | %5d | %6.2f%%",
                                 A, B, Cin, mode, exact_sum, approx_sum, error_val, error_perc);
                    end
                end
            end
        end

        $display("===========================================================================");
        $finish;
    end

endmodule