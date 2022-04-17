type
  # VolumeDescriptorHandler represents the data in bytes 0-6
  # of a Volume Descriptor as defined in ECMA-119 8.1
  VolumeDescriptorHeader* = object
    volume_type*: byte
    identifier*: array[5, byte]
    version*: byte  

proc UnMarshalBinary(vdh: var VolumeDescriptorHeader, data: seq[byte]): void =
  if len(data) < 7:
    raise newException(EOFError, "Unexpected EOF")

  vdh.volume_type = data[0]
  vdh.identifier = data[1 .. 5]
  vdh.version = data[6]

proc MarshalBinary(vdh: var VolumeDescriptorHeader): seq[byte] =
  var data:seq[byte] = newSeq[byte](7)
  data[0] = vdh.volume_type
  data[6] = vdh.version
  for i in 1 .. 6:
    data[i] = vdh.identifier[i-1]
  
  return data