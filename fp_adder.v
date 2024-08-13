module fp_adder (
    input [31:0] operandX,
    input [31:0] operandY,
    output reg [31:0] result
);
//registers for parts of number
reg [23:0] mantissa_x, mantissa_y;
reg [7:0] exponent_x, exponent_y;
reg sign_x, sign_y; //sign bits
//Intermediate registers for Mantissa Sum, aligned mantissa, final mantissa
reg [24:0] mantissa_sum;
reg [24:0] x_aligned, y_aligned;
reg [7:0] exponent_difference; //stores difference so we can align mantissas before add/sub
//outputs
reg [23:0] mantissa_final;
reg [7:0] exponent_final;
reg sign_final;

always @(*) begin
    //Get Sign, Exponent, Mantissa from numbers
    sign_x = operandX[31]; //32nd bit
    exponent_x = operandX[30:23]; //Bit 23-31

    if (exponent_x == 0) begin
        mantissa_x = {1'b0, operandX[22:0]}; //if subnormal, implicit zero
    end else begin
        mantissa_x = {1'b1, operandX[22:0]}; //if normal, implicit one
    end

    $display("operandX: sign = %b, exponent = %b, mantissa = %b", sign_x, exponent_x, mantissa_x); //Display operandX components

    sign_y = operandY[31]; //32nd bit
    exponent_y = operandY[30:23]; //Bit 23-31

    if (exponent_y == 0) begin
        mantissa_y = {1'b0, operandY[22:0]}; //if subnormal, implicit zero
    end else begin
        mantissa_y = {1'b1, operandY[22:0]}; //if normal, implicit one
    end

    $display("operandY: sign = %b, exponent = %b, mantissa = %b", sign_y, exponent_y, mantissa_y); //Display operandY components

    // Special case: If both operands are infinity with the same sign, return infinity
    if (exponent_x == 8'hFF && exponent_y == 8'hFF && mantissa_x == 0 && mantissa_y == 0) begin
        if (sign_x == sign_y) begin
            result = {sign_x, 8'hFF, 23'h0}; // return the same infinity
        end else begin
            result = 32'h7FC00000; // return NaN if they are of opposite signs
        end
    end
    // Special case: If one operand is NaN, return NaN
    else if ((exponent_x == 8'hFF && mantissa_x != 0) || (exponent_y == 8'hFF && mantissa_y != 0)) begin
        result = (exponent_x == 8'hFF && mantissa_x != 0) ? operandX : operandY; // return NaN
    end
    // Special case: Handling undefined operations like +Infinity and -Infinity
    else if (exponent_x == 8'hFF && exponent_y == 8'hFF && sign_x != sign_y) begin
        result = 32'h7FC00000; // Return NaN
    end
    else begin
        //Align Exponents if they are different (shift small mantissa)
        if (exponent_x > exponent_y) begin
            exponent_difference = exponent_x - exponent_y;
            y_aligned = mantissa_y >> exponent_difference; //bit shift mantissa y by exponent difference
            x_aligned = mantissa_x; //x stays the same
            exponent_final = exponent_x; //set final exponent to greater
        end else begin
            exponent_difference = exponent_y - exponent_x;
            x_aligned = mantissa_x >> exponent_difference; //bit shift mantissa x by exponent difference
            y_aligned = mantissa_y; //y stays same
            exponent_final = exponent_y; //set final exponent to greater
        end

        //Add/Subtract Mantissa. Addition or Subtraction depends on Sign bit
        if (sign_x == sign_y) begin
            //if same sign, add
            mantissa_sum = x_aligned + y_aligned;
            sign_final = sign_x;
        end else begin
            //if not the same sign, subtract
            if (x_aligned >= y_aligned) begin
                //if x greater, subtract y from x
                mantissa_sum = x_aligned - y_aligned;
                sign_final = sign_x;
            end else begin
                //if y greater, subtract x from y
                mantissa_sum = y_aligned - x_aligned;
                sign_final = sign_y;
            end
        end

        // Ensure that if the result is zero, the sign is positive
        if (mantissa_sum == 0) begin
            sign_final = 0;
        end

        //Normalize (shift Mantissa, Exponent), then Round result to IEEE 754 format
        if (mantissa_sum[24]) begin
            //if there is a carry bit, leading to larger mantissa, normalize by adding 1 to exponent, shifting mantissa
            mantissa_final = mantissa_sum[24:1];
            exponent_final = exponent_final + 1;
        end else begin
            //if no carry bit, take first take the other 23. The leading bit of mantissa might not be one, (leading zeros)
            mantissa_final = mantissa_sum[23:0];
            //shift mantissa final left until leading bit becomes 1, decrementing exponent until zero
            while (mantissa_final[23] == 0 && exponent_final > 0) begin
                mantissa_final = mantissa_final << 1;
                exponent_final = exponent_final - 1;
            end
        end

        // Handle rounding
        if (mantissa_final[0] == 1) begin
            mantissa_final = mantissa_final + 1;
            if (mantissa_final[23]) begin
                exponent_final = exponent_final + 1;
                mantissa_final = mantissa_final >> 1;
            end
        end

        //Return result, Handle Edge cases (Infinity, Zero)
        if (exponent_final == 8'hFF) begin
            result = {sign_final, 8'hFF, 23'h0}; //infinity case, return infinity
        end else if (exponent_final == 0 && mantissa_final == 0) begin
            result = {sign_final, 8'h00, 23'h0}; //zero case, return zero
        end else begin
            result = {sign_final, exponent_final, mantissa_final[22:0]}; //assemble final 32 bit number in IEEE 754 format
        end
    end
end

endmodule
