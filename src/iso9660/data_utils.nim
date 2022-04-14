import std/endians
import std/strutils

type
    EndianMismatch* = object of Exception

# MarshalString encodes the given string as a byte array padded to the given length
proc MarshalString(s: string, padToLength: int): seq[byte] =

    var padded: string = s
    
    if len(s) > padToLength:
        padded = padded[ .. padToLength]
    
    var missingPadding = padToLength - len(s)
    padded = s & " ".repeat(missingPadding)
    return @(padded.toOpenArrayByte(0, s.high))


# UnmarshalInt32LSBMSB decodes a 32-bit integer in both byte orders, as defined in ECMA-119 7.3.3
proc UnMarshalInt32LSBMSB(data: seq[byte]): int32 =
    if len(data) < 8:
        raise EOFError

    var lsb:int32
    var msb:int32

    var le_data = data[0 .. 4]
    var be_data = data[4 .. 8]

    littleEndian32(addr lsb, addr le_data)
    bigEndian32(addr msb, addr be_data)

    if lsb != msb:
        raise newException(EndianMismatch, &"little-endian and big-endian value mismatch: {lsb} != {msb}")

    return lsb