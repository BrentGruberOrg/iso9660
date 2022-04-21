import std/strutils
import ../marshal

type
    # BootVolumeDescriptorBody represents the data in bytes 7-2047
    # of a Boot Record as defined in ECMA-119 8.2
    BootVolumeDescriptorBody* = tuple
        bootSystemIdentifier: string
        bootIdentifier: string
        bootSystemUse:  seq[byte]


# UnmarshalBVDB decodes a BootVolumeDescriptorBody from binary Form
proc UnmarshalBVDB*(data: seq[byte]): BootVolumeDescriptorBody =
    var bvdb: BootVolumeDescriptorBody

    bvdb.bootSystemIdentifier = toString(data[7 .. 38]).strip(leading=false)
    bvdb.bootIdentifier = toString(data[39 .. 70]).strip(leading=false)
    bvdb.bootSystemUse = data[71 .. 2048]

    return bvdb