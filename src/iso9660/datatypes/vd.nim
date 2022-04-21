import std/strformat

import consts
import exceptions
import vdh
import bvdb
import pvdb
import ../marshal


type
    VolumeDescriptor* = tuple
        header: VolumeDescriptorHeader
        boot:   BootVolumeDescriptorBody
        primary:    PrimaryVolumeDescriptorBody


# UnmarshalVD decodes a VolumeDescriptor from its binary form
proc UnmarshalVD*(data: seq[byte]): VolumeDescriptor =
    if uint32(len(data)) < sectorSize:
        raise newException(EOFError, &"Volume Descriptor received {len(data)} bytes and expected {sectorSize}")

    var vd: VolumeDescriptor

    vd.header = UnMarshalVDH(data[0 .. 6])

    let identifier_string = toString(vd.header.identifier)
    if identifier_string != standardIdentifier:
        raise newException(ValueError, &"volume descriptor {identifier_string} != {standardIdentifier}")

    case vd.header.volume_type:
        of volumeTypeBoot:
            vd.boot = UnmarshalBVDB(data)
        of volumeTypePartition:
            raise newException(ValueError, "Partitions are currently not supported") # This should be a different exception
        of volumeTypePrimary, volumeTypeSupplementary:
            vd.primary = UnmarshalPVDB(data)
        of volumeTypeTerminator:
            return vd
        else:
            raise newException(Exception, "Received an unexpected error")

    
    return vd

# MarshalVD encodes a Volume Descriptor to its binary format
proc MarshalVD*(vd: VolumeDescriptor): seq[byte] =
    var data: seq[byte]

    case vd.header.volume_type:
        of volumeTypeBoot:
            raise newException(UnsupportedError, "Boot volumes are currently not supported")
        of volumeTypePartition:
            raise newException(UnsupportedError, "Partitions are currently not supported")
        of volumeTypePrimary, volumeTypeSupplementary:
            data = MarshalPVDB(vd.primary)
        of volumeTypeTerminator:
            data = newSeq[byte](sectorSize)
        else:
            raise newException(Exception, "Received an unexpected error")
        
    
    data[0 .. 6] = MarshalVDH(vd.header)

    return data