`timescale 1ns/1ps

module dynamic_rca_16bit (
    input  [15:0] A,      // 16-bit inputs
    input  [15:0] B,
    input         Cin,     // Carry-in
    input  [1:0] mode,     // Mode select: 00=Exact, 01=Mode1, 10=Mode2, 11=Mode3
    output [15:0] Sum,     // Sum output
    output        Cout     // Carry-out
);

    // Internal exact computation
    wire [15:0] sum_exact;
    wire [14:0] carry;

    assign {carry[0], sum_exact[0]} = A[0] + B[0] + Cin;
    assign {carry[1], sum_exact[1]} = A[1] + B[1] + carry[0];
    assign {carry[2], sum_exact[2]} = A[2] + B[2] + carry[1];
    assign {carry[3], sum_exact[3]} = A[3] + B[3] + carry[2];
    assign {carry[4], sum_exact[4]} = A[4] + B[4] + carry[3];
    assign {carry[5], sum_exact[5]} = A[5] + B[5] + carry[4];
    assign {carry[6], sum_exact[6]} = A[6] + B[6] + carry[5];
    assign {carry[7], sum_exact[7]} = A[7] + B[7] + carry[6];
    assign {carry[8], sum_exact[8]} = A[8] + B[8] + carry[7];
    assign {carry[9], sum_exact[9]} = A[9] + B[9] + carry[8];
    assign {carry[10], sum_exact[10]} = A[10] + B[10] + carry[9];
    assign {carry[11], sum_exact[11]} = A[11] + B[11] + carry[10];
    assign {carry[12], sum_exact[12]} = A[12] + B[12] + carry[11];
    assign {carry[13], sum_exact[13]} = A[13] + B[13] + carry[12];
    assign {carry[14], sum_exact[14]} = A[14] + B[14] + carry[13];
    assign {Cout, sum_exact[15]} = A[15] + B[15] + carry[14];

    // Approximate sum registers
    reg [15:0] sum_reg;
    reg        cout_reg;

    // Temporary registers for approximation
    reg [15:0] sum_tmp;
    reg [14:0] c_tmp;

    integer i;

    always @(*) begin
        case (mode)
            2'b00: begin
                // Mode 0: Exact RCA
                sum_reg = sum_exact;
                cout_reg = Cout;
            end

            2'b01: begin
                // Mode 1: Carry cut after lower 4 bits (FA0-FA3 exact, rest carry-cut)
                {c_tmp[0], sum_tmp[0]} = A[0] + B[0] + Cin;
                {c_tmp[1], sum_tmp[1]} = A[1] + B[1] + c_tmp[0];
                {c_tmp[2], sum_tmp[2]} = A[2] + B[2] + c_tmp[1];
                {c_tmp[3], sum_tmp[3]} = A[3] + B[3] + c_tmp[2];
                // Carry-cut: upper bits ignore carry
                for (i=4; i<16; i=i+1)
                    sum_tmp[i] = A[i] ^ B[i];
                sum_reg = sum_tmp;
                cout_reg = 1'b0;
            end

            2'b10: begin
                // Mode 2: Lower-part OR (FA0 replaced by OR), rest exact with zero initial carry
                sum_tmp[0] = A[0] | B[0];  // OR replacement
                {c_tmp[1], sum_tmp[1]} = A[1] + B[1] + 1'b0;
                {c_tmp[2], sum_tmp[2]} = A[2] + B[2] + c_tmp[1];
                {c_tmp[3], sum_tmp[3]} = A[3] + B[3] + c_tmp[2];
                for (i=4; i<16; i=i+1) begin
                    {c_tmp[i], sum_tmp[i]} = A[i] + B[i] + c_tmp[i-1];
                end
                sum_reg = sum_tmp;
                cout_reg = c_tmp[14];
            end

            2'b11: begin
                // Mode 3: OR + Speculative Carry Prediction
                sum_tmp[0] = A[0] | B[0];
                {c_tmp[1], sum_tmp[1]} = A[1] + B[1] + 1'b0;
                {c_tmp[2], sum_tmp[2]} = A[2] + B[2] + c_tmp[1];
                {c_tmp[3], sum_tmp[3]} = A[3] + B[3] + c_tmp[2];

                // Speculative predictor for upper bits
                for (i=4; i<16; i=i+1) begin
                    if (A[i-1] & B[i-1])
                        {c_tmp[i], sum_tmp[i]} = A[i] + B[i] + 1'b1;
                    else
                        {c_tmp[i], sum_tmp[i]} = A[i] + B[i] + 1'b0;
                end
                sum_reg = sum_tmp;
                cout_reg = c_tmp[14];
            end

            default: begin
                sum_reg = sum_exact;
                cout_reg = Cout;
            end
        endcase
    end

    assign Sum = sum_reg;
    assign Cout = cout_reg;

endmodule

Test Bench: -

`timescale 1ns/1ps

module tb_dynamic_rca_16bit;

    reg  [15:0] A, B;
    reg         Cin;
    reg  [1:0]  mode;
    wire [15:0] Sum;
    wire        Cout;

    // DUT instance
    dynamic_rca_16bit uut (
        .A(A),
        .B(B),
        .Cin(Cin),
        .mode(mode),
        .Sum(Sum),
        .Cout(Cout)
    );

    // Reference exact RCA sum (17-bit to include Cout)
    reg [16:0] exact_sum;
    reg [16:0] approx_sum;
    integer    error_val;
    real       error_perc;

    integer i, j, k, m;

    initial begin
        $display("===============================================================================================");
        $display("       A              B  Cin | Mode | Exact Sum | Approx Sum | Error | Error %%");
        $display("===============================================================================================");

        // For demonstration, using a subset of inputs; can expand to full 16-bit combinations if needed
        for (i = 0; i < 16; i = i+1) begin
            for (j = 0; j < 16; j = j+1) begin
                for (k = 0; k < 2; k = k+1) begin
                    A   = i;
                    B   = j;
                    Cin = k;

                    // Exact sum computation
                    exact_sum = A + B + Cin;

                    // Sweep all modes
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

                        $display("%16h %16h   %1b   |  %2b   |   %5d    |    %5d    | %5d | %6.2f%%",
                                 A, B, Cin, mode, exact_sum, approx_sum, error_val, error_perc);
                    end
                end
            end
        end

        $display("===============================================================================================");
        $finish;
    end

endmodule