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

  standardIdentifierBytes*: seq[byte] = @[byte('C'), byte('D'), byte('0'), byte('0'), byte('1')]
