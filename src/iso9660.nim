# iso9660 implements reading and creating basic ISO9660 images


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


# VolumeDescriptorHandler represents the data in bytes 0-6
# of a Volume Descriptor as defined in ECMA-119 8.1
type 
  VolumeDescriptorHeader* = object
    volume_type*: byte
    identifier*: array[5, byte]
    version*: byte

