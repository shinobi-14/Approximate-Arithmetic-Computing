`timescale 1ns/1ps

module rca_4bit (
    input  [3:0] A,    // 4-bit input A
    input  [3:0] B,    // 4-bit input B
    input        Cin,  // Carry in
    output [3:0] Sum,  // 4-bit sum output
    output       Cout  // Carry out
);

    wire c0, c1, c2;

    // Full Adder 0
    assign {c0, Sum[0]} = A[0] + B[0] + Cin;
    // Full Adder 1
    assign {c1, Sum[1]} = A[1] + B[1] + c0;
    // Full Adder 2
    assign {c2, Sum[2]} = A[2] + B[2] + c1;
    // Full Adder 3
    assign {Cout, Sum[3]} = A[3] + B[3] + c2;

endmodule

Test Bench_1: - (Either can be used) - (Use this for a large number of test cases) 

`timescale 1ns/1ps

module tb_rca_4bit;

    reg  [3:0] A, B;
    reg        Cin;
    wire [3:0] Sum;
    wire       Cout;

    // Instantiate the exact RCA
    rca_4bit uut (
        .A(A),
        .B(B),
        .Cin(Cin),
        .Sum(Sum),
        .Cout(Cout)
    );

    integer i, j, k;

    initial begin
        $display("Time(ns)\tA\tB\tCin\tSum\tCout");
        $monitor("%0t\t%b\t%b\t%b\t%b\t%b", $time, A, B, Cin, Sum, Cout);

        // Exhaustive test for 4-bit inputs
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                for (k = 0; k < 2; k = k + 1) begin
                    A = i;
                    B = j;
                    Cin = k % 2;
                    #5;  // small delay for signal propagation
                end
            end
        end

        $finish;
    end

endmodule

Test Bench_2: - (Either can be used) - (Use this for less test cases)

`timescale 1ns/1ps

module tb_rca_4bit;

    reg  [3:0] A, B;
    reg        Cin;
    wire [3:0] Sum;
    wire       Cout;

    // Instantiate the 4-bit RCA
    rca_4bit uut (
        .A(A),
        .B(B),
        .Cin(Cin),
        .Sum(Sum),
        .Cout(Cout)
    );

    initial begin
        // Display header
        $display("Time(ns)\tA\tB\tCin\tSum\tCout");
       
        // Test case 1
        A = 4'b0000; B = 4'b0000; Cin = 0; #10;
        $display("%0t\t%b\t%b\t%b\t%b\t%b", $time, A, B, Cin, Sum, Cout);

        // Test case 2
        A = 4'b0001; B = 4'b0010; Cin = 0; #10;
        $display("%0t\t%b\t%b\t%b\t%b\t%b", $time, A, B, Cin, Sum, Cout);

        // Test case 3
        A = 4'b0101; B = 4'b0011; Cin = 1; #10;
        $display("%0t\t%b\t%b\t%b\t%b\t%b", $time, A, B, Cin, Sum, Cout);

        // Test case 4
        A = 4'b1111; B = 4'b0001; Cin = 0; #10;
        $display("%0t\t%b\t%b\t%b\t%b\t%b", $time, A, B, Cin, Sum, Cout);

        // Test case 5
        A = 4'b1010; B = 4'b0101; Cin = 1; #10;
        $display("%0t\t%b\t%b\t%b\t%b\t%b", $time, A, B, Cin, Sum, Cout);

        // Test case 6
        A = 4'b1111; B = 4'b1111; Cin = 1; #10;
        $display("%0t\t%b\t%b\t%b\t%b\t%b", $time, A, B, Cin, Sum, Cout);

        $finish;
    end

endmodule