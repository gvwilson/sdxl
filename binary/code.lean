-- UInt8 arithmetic wraps at 256 (two's complement)
#guard (255 : UInt8) + 1 == 0        -- overflow wraps
#guard (0   : UInt8) - 1 == 255      -- underflow wraps

-- Negation in two's complement: x + (-x) == 0
def twosComplement (x : UInt8) : UInt8 := (~~~x) + 1   -- bitwise NOT + 1

#guard (5 : UInt8) + twosComplement 5 == 0
#guard twosComplement 0 == 0            -- -0 = 0

-- Bitwise operations
def extractNibbles (b : UInt8) : UInt8 × UInt8 :=
  (b >>> 4, b &&& 0x0F)   -- high nibble, low nibble

#guard extractNibbles 0xAB == (0x0A, 0x0B)

def packNibbles (hi lo : UInt8) : UInt8 :=
  (hi <<< 4) ||| (lo &&& 0x0F)

#guard packNibbles 0xA 0xB == 0xAB

-- Counting set bits (popcount) using shifts
def popcount (b : UInt8) : Nat :=
  (List.range 8).foldl (init := 0) fun acc i =>
    acc + ((b >>> i.toUInt8) &&& 1).toNat

#guard popcount 0b10110101 == 5
#guard popcount 0xFF == 8
#guard popcount 0x00 == 0

-- Character / UTF-8 basics
-- ASCII characters have code points 0–127 and encode as single bytes
def isAscii (c : Char) : Bool := c.toNat < 128
def toUtf8SingleByte (c : Char) : Option UInt8 :=
  if isAscii c then some c.toNat.toUInt8 else none

#guard toUtf8SingleByte 'A' == some 65
#guard toUtf8SingleByte 'A' == some 0x41
#guard (toUtf8SingleByte 'é').isNone    -- é is code point 233, needs 2 bytes

-- Packing two UInt8 values into a UInt16
def pack16 (hi lo : UInt8) : UInt16 :=
  (hi.toUInt16 <<< 8) ||| lo.toUInt16

def unpack16 (w : UInt16) : UInt8 × UInt8 :=
  ((w >>> 8).toUInt8, w.toUInt8)

#guard pack16 0xCA 0xFE == 0xCAFE
#guard unpack16 0xCAFE == (0xCA, 0xFE)
