import rts
import ../marshal

import std/strformat

type
  # DirectoryEntry contains data from a Directory Descriptor
  # as described by ECMA-119 9.1
  DirectoryEntry* = tuple
    extendedAttributeRecordLength: byte
    extentLocation: int32
    extentLength: int32
    recordingDateTime: RecordingTimeStamp
    fileFlags: byte
    fileUnitSize:   byte
    interleaveGap:  byte
    volumeSequenceNumber:   int16
    identifier: string
    systemUse:  seq[byte]


proc toString(bytes: openarray[byte]): string =
    result = newString(bytes.len)
    copyMem(result[0].addr, bytes[0].unsafeAddr, bytes.len)


# UnmarshalDE decodes a DirectoryEntry from binary form
proc UnMarshalDE*(data: seq[byte]): DirectoryEntry =
    let length = int(data[0])
    if length == 0:
        raise newException(EOFError, "Unsupported length of 0 on Directory Entry")

    var de: DirectoryEntry

    de.extendedAttributeRecordLength = data[1]

    de.extentLocation = UnMarshalInt32LSBMSB(data[2 .. 9])
    de.extentLength = UnmarshalInt32LSBMSB(data[10 .. 17])
    de.recordingDateTime = UnmarshalRTS(data[18 .. 24])

    de.fileFlags = data[25]
    de.fileUnitSize = data[26]
    de.interleaveGap = data[27]

    de.volumeSequenceNumber = UnmarshalInt16LSBMSB(data[28 .. 31])

    let identifierLen: int = int(data[32])
    de.identifier = toString(data[33 .. (33+identifierLen-1)])

    # add padding if identifier length was even
    let idPaddingLen: int = (identifierLen + 1) mod 2
    de.systemUse = data[(33+identifierLen+idPaddingLen) .. (length-1)]

    return de

# MarshalDE encodes a DirectoryEntry to binary form
proc MarshalDE*(de: DirectoryEntry): seq[byte] =
    let identifierLen: int = len(de.identifier)
    let idPaddingLen: int = (identifierLen + 1) mod 2
    let totalLen: int = 33 + identifierLen + idPaddingLen + len(de.systemUse)
    if totalLen > 255:
        raise newException(ValueError, &"identifier {de.identifier} is too long")

    var data: seq[byte] = newSeq[byte](totalLen)

    data[0] = byte(totalLen)
    data[1] = de.extendedAttributeRecordLength

    data[2 .. 9] = MarshalInt32LSBMSB(de.extentLocation)
    data[10 .. 17] = MarshalInt32LSBMSB(de.extentLength)

    data[18 .. 24] = MarshalRTS(de.recordingDateTime)
    data[25] = de.fileFlags
    data[26] = de.fileUnitSize
    data[27] = de.interleaveGap
    data[28 .. 31] = MarshalInt16LSBMSB(de.volumeSequenceNumber)
    data[32] = byte(identifierLen)
    data[33 .. (33+identifierLen-1)] = cast[seq[byte]](de.identifier)


    return data


# clone creates a copy of the DirectoryEntry
proc Clone*(de: DirectoryEntry): DirectoryEntry =
    var newDE: DirectoryEntry = (
        extendedAttributeRecordLength: de.extendedAttributeRecordLength,
        extentLocation: de.extentLocation,
        extentLength: de.extentLength,
        recordingDateTime: de.recordingDateTime,
        fileFlags: de.fileFlags,
        fileUnitSize: de.fileUnitSize,
        interleaveGap: de.interleaveGap,
        volumeSequenceNumber: de.volumeSequenceNumber,
        identifier: de.identifier,
        systemUse:  newSeq[byte](len(de.systemUse))
    )
    copyMem(newDE.systemUse.addr, de.systemUse.unsafeAddr, len(de.systemUse))

    return newDE