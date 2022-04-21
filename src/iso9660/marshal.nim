import endians2
import std/strutils
import std/sequtils

# TODO: Should I make these all inline?
# TODO: Can this be made as functional instead of procs?

type
    EndianMismatch* = object of ValueError
    LengthError* = object of ValueError

# MarshalString encodes the given string as a byte array padded to the given length
proc MarshalString*(s: string, padToLength: int): seq[byte] =
    if padToLength < 0:
        raise newException(LengthError, "Cannot marshal string to negative length")

    var padded: string = s
    
    if len(s) > padToLength:
        padded = padded[0 .. (padToLength-1) ] # this notation is inclusive
    
    var missingPadding = padToLength - len(padded)

    if missingPadding > 0:
        padded = s & " ".repeat(missingPadding)

    return @(padded.toOpenArrayByte(0, padded.high))


# UnmarshalInt32LSBMSB decodes a 32-bit integer in both byte orders, as defined in ECMA-119 7.3.3
proc UnMarshalInt32LSBMSB*(data: seq[byte]): int32 =
    if len(data) < 8:
        raise newException(EOFError, "Unexpected EOF")
    if len(data) > 8:
        raise newException(ValueError, $"Received too many bytes for unmarshaling, expected: 4, received {len(data)}")

    var le_data = data[0 .. 3]
    var be_data = data[4 .. 7]

    let lsb: uint32 = fromBytesLE(uint32, le_data)
    let msb: uint32 = fromBytesBE(uint32, be_data)
    
    if lsb != msb:
        raise newException(EndianMismatch, $"little-endian and big-endian value mismatch: {lsb} != {msb}")

    return int32(lsb)

# UnmarshalInt16LSBMSB decodes a 16-bit integer in both byte orders, as defined in ECMA-119 7.3.3
proc UnmarshalInt16LSBMSB*(data: seq[byte]): int16 =
    if len(data) < 4:
        raise newException(EOFError, "Unexpected EOF")
    if len(data) > 4:
        raise newException(ValueError, $"Received too many bytes for unmarshaling, expected: 4, received {len(data)}")

    var le_data = data[0 .. 1]
    var be_data = data[2 .. 3]

    let lsb: uint16 = fromBytesLE(uint16, le_data)
    let msb: uint16 = fromBytesBE(uint16, be_data)

    if lsb != msb:
        raise newException(EndianMismatch, $"little-ending and big-endian value mismatch: {lsb} != {msb}")

    return int16(lsb)


# WriteInt32LSBMSB writes a 32-bit integer in both byte orders, as defined in ECMA-119 7.3.3
#   TODO: can I use fixed arrays instead of seq?
proc MarshalInt32LSBMSB*(value: int32): seq[byte] =
    let le_data: array[4, byte] = toBytesLE(uint32(value))
    let be_data: array[4, byte] = toBytesBE(uint32(value))

    return concat(toseq(le_data), toseq(be_data))



# # WriteInt16LSBMSB writes a 16-bit integer in both byte orders, as defined in ECMA-119 7.2.3
proc MarshalInt16LSBMSB*(value: int16): seq[byte] =
    let le_data: array[2, byte] = toBytesLE(uint16(value))
    let be_data: array[2, byte] = toBytesBE(uint16(value))

    return concat(toseq(le_data), toseq(be_data))