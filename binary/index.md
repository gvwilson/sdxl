# Binary Data

## Outline

- Lean's `UInt8`, `UInt16`, `UInt32`, `UInt64` types store unsigned integers in
  fixed-width two's complement representation
- Bitwise operators `&&&`, `|||`, `^^^`, `<<<`, `>>>` work directly on these types
- Two's complement: negation of an N-bit unsigned value `x` is `(max + 1 - x) mod 2^N`
  — demonstrated by showing that `x + (-x) == 0` in `UInt8` arithmetic
- Character encodings: `Char.toNat` gives the Unicode code point; UTF-8 encodes code
  points < 128 as single bytes (ASCII-compatible)
- Packing multiple values into a single word using shifts and masks

## Code

[%inc code.lean %]
