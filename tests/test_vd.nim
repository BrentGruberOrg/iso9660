import unittest

import iso9660/datatypes/consts
import iso9660/datatypes/pvdb
import iso9660/datatypes/vd

# Testing Marshalling and unmarshalling of pvdb data structure
suite "Volume Descriptor":

    let f = open("./fixtures/test.iso")
    defer: f.close()

    # Test end to end
    test "end to end":
        var buffer1: seq[byte] = newSeq[byte](sectorSize)

        setFilePos(f, int64(sectorSize*16))
        discard readBytes(f, buffer1, 0, sectorSize)

        var vd: VolumeDescriptor = UnmarshalVD(buffer1)

        var buffer2: seq[byte] = MarshalVD(vd)

        check(buffer1 == buffer2)