# iso9660 implements reading and creating basic ISO9660 images

import std/times

# ISO 9660 Overview
# https://archive.fo/xs9ac
const
  sectorSize*: uint32 = 2048
  systemAreaSize*: uint32 = sectorSize * 16
  standardIdentifier*: string = "CD001"
  volumeTypeBoot*: byte = 0
  volumeTypePrimary*: byte = 1
  volumeTypeSupplementary*: byte = 2
  volumeTypePartition*: byte = 3
  volumeTypeTerminator*: byte = 255
  
  volumeDescriptorBodySize*: uint32 = sectorSize - 7

  aCharacters*: string = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_!\"%&'()*+,-./:;<=>?"
  dCharacters*: string = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"

  # ECMA-119 7.4.2.2 defines d1-characters as
  # "subject to agreement between the originator and the recipient of the volume"
  d1Characters*: string = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_!\"%&'()*+,-./:;<=>?"

  dirFlagHidden*: int = 1
  dirFlagDir*: int = 2
  dirFlagAssociated*: int = 3
  dirFlagRecord*: int = 4
  dirFlagProtection*: int = 5
  dirFlagMultiExtent*: int = 8


type
  # VolumeDescriptorHandler represents the data in bytes 0-6
  # of a Volume Descriptor as defined in ECMA-119 8.1
  VolumeDescriptorHeader* = object
    volume_type*: byte
    identifier*: array[5, byte]
    version*: byte  

  # RecordingTimeStamp represents a time and date format
  # that can be encoded according to ECMA-119 9.1.5
  RecordingTimeStamp* = Time

  # VolumeDescriptorTimestamp represents a time and date format
  # that can be encoded according to ECMA-119 8.4.26.1
  VolumeDescriptorTimestamp* = object 
    year*: int
    month*: int
    day*: int
    hour*:  int
    minute*:  int
    second*:  int
    hundredth*: int
    offset*:  int

  # DirectoryEntry contains data from a Directory Descriptor
  # as described by ECMA-119 9.1
  DirectoryEntry* = object
    extendedAttributeRecordLength*: byte
    extentLocation*: int32
    extentLength*: int32
    recordingDateTime*: RecordingTimeStamp
    fileFlags*: byte
    fileUnitSize*:  byte
    interleaveGap*: byte
    volumeSequenceNumber*: int16
    identifier*:  string
    systemUse*: seq[byte]

  # BootVolumeDescriptorBody represents the data in bytes 7-2047
  # Of a Boot Record as defined in ECMA-119 8.2
  BootVolumeDescriptorBody* = object
    bootSystemIdentifier*: string
    bootIdentifier*: string
    bootSystemUse*: array[1977, byte]


  # PrimaryVolumeDescriptorBody represents the data in bytes 7-2047
  # of a Primary Volume Descriptor as defined in ECMA-119 8.4
  PrimaryVolumeDescriptorBody* = object
    systemIdentifier*: string 
    volumeIdentifier*: string
    volumeSpaceSize*: int32  
    volumeSetSize*: int16 
    volumeSequenceNumber*: int16
    logicalBlockSize*: int16
    pathTableSize*: int32
    typeLPathTableLoc*: int32
    optTypeLPathTableLoc*: int32
    typeMPathTableLoc*: int32
    optTypeMPathTableLoc*: int32
    rootDirectoryEntry*: DirectoryEntry
    volumeSetIdentifier*: string
    publisherIdentifier*: string
    dataPreparerIdentifier*: string
    applicationIdentifier*: string
    copyrightFileIdentifier*: string
    abstractFileIdentifier*: string
    bibliographicFileIdentifier*: string
    volumeCreationDateAndTime*: VolumeDescriptorTimestamp
    volumeModificationDateAndTIme*: VolumeDescriptorTimestamp
    volumeExpirationDateAndTime*: VolumeDescriptorTimestamp
    volumeEffectiveDateAndTime*:  VolumeDescriptorTimestamp
    fileStructureVersion*:  byte
    applicationUsed*: array[512, byte]


proc UnMarshalBinary(vdh: var VolumeDescriptorHeader, data: seq[byte]): void =
  if len(data) < 7:
    raise EOFError

  vdh.volume_type = data[0]
  vdh.identifier = data[1:6]
  vdh.version = data[6]

proc MarshalBinary(vdh: var VolumeDescriptorHeader): seq[byte] =
  var data:seq[byte] = newSeq[byte](7)
  data[0] = vdh.volume_type
  data[6] = vdh.version
  for i in 1 .. 6:
    data[i] = vdh.identifier[i-1]
  
  return data