module tb_fp_adder;
    reg [31:0] operandX, operandY;
    wire [31:0] result;
    reg [31:0] expected_result;

    fp_adder uut (
        .operandX(operandX),
        .operandY(operandY),
        .result(result)
    );

    // Function to compare results and display test status
    task check_result;
        input integer test_case_number;
        input [31:0] expected, actual;
        begin
            if (expected === actual) begin
                $display("PASS: Test Case %0d: operandX = %h, operandY = %h, result = %h (expected = %h)", test_case_number, operandX, operandY, actual, expected);
            end else begin
                $display("FAIL: Test Case %0d: operandX = %h, operandY = %h, result = %h (expected = %h)", test_case_number, operandX, operandY, actual, expected);
            end
        end
    endtask

    initial begin
        // Test case 1: 1.0 + 1.0
        operandX = 32'h3F800000; // 1.0
        operandY = 32'h3F800000; // 1.0
        expected_result = 32'h40000000; // 2.0
        #10;
        check_result(1, expected_result, result);

        // Test case 2: 2.0 + 3.0
        operandX = 32'h40000000; // 2.0
        operandY = 32'h40400000; // 3.0
        expected_result = 32'h40A00000; // 5.0
        #10;
        check_result(2, expected_result, result);

        // Test case 3: -1.0 + 1.0
        operandX = 32'hBF800000; // -1.0
        operandY = 32'h3F800000; // 1.0
        expected_result = 32'h00000000; // 0.0
        #10;
        check_result(3, expected_result, result);

        // Test case 4: 1.5 + 2.5
        operandX = 32'h3FC00000; // 1.5
        operandY = 32'h40200000; // 2.5
        expected_result = 32'h40400000; // 4.0
        #10;
        check_result(4, expected_result, result);

        // Test case 5: 0.5 + 0.5
        operandX = 32'h3F000000; // 0.5
        operandY = 32'h3F000000; // 0.5
        expected_result = 32'h3F800000; // 1.0
        #10;
        check_result(5, expected_result, result);

        // Test case 6: 0 + 0
        operandX = 32'h00000000; // 0
        operandY = 32'h00000000; // 0
        expected_result = 32'h00000000; // 0.0
        #10;
        check_result(6, expected_result, result);

        // Test case 7: Infinity + Infinity
        operandX = 32'h7F800000; // +Infinity
        operandY = 32'h7F800000; // +Infinity
        expected_result = 32'h7F800000; // +Infinity
        #10;
        check_result(7, expected_result, result);

        // Test case 8: NaN + 1.0
        operandX = 32'h7FC00000; // NaN
        operandY = 32'h3F800000; // 1.0
        expected_result = 32'h7FC00000; // NaN (or any other NaN value)
        #10;
        check_result(8, expected_result, result);

        // Test case 9: -Infinity + Infinity
        operandX = 32'hFF800000; // -Infinity
        operandY = 32'h7F800000; // +Infinity
        expected_result = 32'h7FC00000; // NaN (undefined behavior)
        #10;
        check_result(9, expected_result, result);

        // Test case 10: Smallest positive number + smallest positive number
        operandX = 32'h00000001; // Smallest positive subnormal number
        operandY = 32'h00000001; // Smallest positive subnormal number
        expected_result = 32'h00000002; // Next smallest positive subnormal number
        #10;
        check_result(10, expected_result, result);

        $finish;
    end
endmodule
