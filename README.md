# IEEE Addition

Educational module to add Two 32-bit Floating point numbers in IEEE-754 format.
## Floating Point Representation

The actual value represented by a floating-point number is given by the formula:

$$
(-1)^{\text{sign}} \times 2^{\text{exponent} - 127} \times 1.\text{mantissa}
$$


- **1 is the implicit leading bit, or hidden bit.**

### Normal Numbers

- **Exponent:** Not all zeros.
- **Mantissa:** Has an implicit leading 1.

### Subnormal Numbers
- Subnormal numbers are used to represent numbers too small to be normal numbers.
- **Exponent:** All zeros.
- **Implicit 1 is not assumed**, and the number is represented as $$0.\text{mantissa}$$.

## Workflow

1. **Extract Components:**
   - Get the sign, exponent, and mantissa from the numbers.

2. **Handle Special Cases:**
   - Address special cases such as NaN and Infinity.

3. **Align Mantissas:**
   - If exponents are different, align the mantissas.

4. **Perform Arithmetic:**
   - Add or subtract the mantissas.

5. **Determine Result Sign:**
   - If the result is zero, set the sign as positive. Otherwise, set the sign as that of the larger operand.

6. **Normalize Mantissa:**
   - Adjust the mantissa to maintain the correct format.

7. **Round Mantissa:**
   - Round the mantissa to fit within the available bits.

