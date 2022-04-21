import std/strformat
import std/strutils

import ../marshal

type
    # VolumeDescriptorTimestamp represents a time and date format
    # that can be encoded according to ECMA-119 8.4.26.1
    VolumeDescriptorTimestamp* = tuple
        year:    int
        month:   int
        day:     int
        hour:    int
        minute:  int
        second:  int
        hundredth:   int
        offset:  int


# UnmarshalVDTS decodes a VolumeDescriptorTimestamp from binary form
proc UnmarshalVDTS*(data: seq[byte]): VolumeDescriptorTimestamp =
    if len(data) != 17:
        raise newException(EOFError, &"Received {len(data)} bytes for volume descriptor timestamp, expected 17")

    let year: int = parseInt(toString(data[0 .. 3]))
    let month: int = parseInt(toString(data[4 .. 5]))
    let day: int = parseInt(toString(data[6 .. 7]))
    let hour: int = parseInt(toString(data[8 .. 9]))
    let minute: int = parseInt(toString(data[10 .. 11]))
    let second: int = parseInt(toString(data[12 .. 13]))
    let hundredth: int = parseInt(toString(data[14 .. 15]))

    var ts: VolumeDescriptorTimestamp = (
        year:   year,
        month:  month,
        day:    day,
        hour:   hour,
        minute: minute,
        second: second,
        hundredth: hundredth,
        offset: int(data[16])
    )

    return ts



# MarshalVDTS encodes a VolumeDescriptorTimestamp to binary form
proc MarshalVDTS*(vdts: VolumeDescriptorTimestamp): seq[byte] =
    let formatted: string = &"{vdts.year:04}{vdts.month:02}{vdts.day:02}{vdts.hour:02}{vdts.minute:02}{vdts.second:02}{vdts.hundredth:02}"
    var formattedBytes: seq[byte] = cast[seq[byte]](formatted)
    formattedBytes.add(byte(vdts.offset))

    if len(formattedBytes) != 17:
        raise newException(EOFError, &"vdts.MarshalVDTS: the formatted timestamp is {len(formatted)} bytes long")

    return formattedBytes