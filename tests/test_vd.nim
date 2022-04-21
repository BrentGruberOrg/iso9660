import unittest

import iso9660/datatypes/pvdb
import iso9660/datatypes/vd

# Testing Marshalling and unmarshalling of pvdb data structure
suite "Volume Descriptor":

    let f = open("./fixtures/test.iso")
    defer: f.close()

    # Test end to end
    test "end to end":
        var buffer1: seq[byte] = newSeq[byte](sectorSize)

        discard readBytes(f, buffer1, (sectorSize*16), sectorSize)

        var vd: VolumeDescriptor

        