type
  # VolumeDescriptorHandler represents the data in bytes 0-6
  # of a Volume Descriptor as defined in ECMA-119 8.1
  VolumeDescriptorHeader* = tuple
    volume_type: byte
    # TODO: we know the length at compile time, could use an array for optimization
    # however, need to figure out to convert sub sequence to fixed array
    identifier: seq[byte] 
    version: byte  

# Convert a sequence of bytes to a Volume Descriptor Header
proc UnMarshalVDH*(data: seq[byte]): VolumeDescriptorHeader =
  if len(data) < 7:
    raise newException(EOFError, "Unexpected EOF")
  if len(data) > 8:
    raise newException(ValueError, "Too many bytes for Volume Descriptor Header")

  var vdh: VolumeDescriptorHeader

  vdh.volume_type = data[0]
  vdh.identifier = data[1 .. 5]
  vdh.version = data[6]

  return vdh

# Convert a VolumeDescriptorHeader to a sequence of bytes
proc MarshalVDH*(vdh: VolumeDescriptorHeader): seq[byte] =
  # TODO: could probably add validations here
  var data:seq[byte] = newSeq[byte](7)
  data[0] = vdh.volume_type
  data[6] = vdh.version
  for i in 1 .. 5:
    data[i] = vdh.identifier[i-1]
  
  return data