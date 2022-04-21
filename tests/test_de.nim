import unittest
import os

import iso9660
import iso9660/datatypes/de


# Testing Marshalling and unmarshalling of de data structure
suite "Directory Entry":

    echo dirExists("./fixtures")

    let f = open("./fixtures/test.iso")
    defer: f.close()

    # # Test end to end
    test "end to end":
        var buffer1: seq[byte] = newSeq[byte](34)

        setFilePos(f, int64((sectorSize*16) + 156))
        discard readBytes(f, buffer1, 0, 34)

        var entry: DirectoryEntry = UnMarshalDE(buffer1)

        var buffer2: seq[byte] = MarshalDE(entry)

        check:
            buffer1 == buffer2

    # Test cloning of DE
    test "clone":
        var buffer1: seq[byte] = newSeq[byte](34)

        setFilePos(f, int64((sectorSize*16) + 156))
        discard readBytes(f, buffer1, 0, 34)

        var entry: DirectoryEntry = UnMarshalDE(buffer1)

        var clone: DirectoryEntry = Clone(entry)

        check:
            entry.addr != clone.addr
            entry == clone

    

