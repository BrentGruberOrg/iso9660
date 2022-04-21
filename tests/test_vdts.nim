import unittest

import iso9660/datatypes/vdts

# Testing Marshalling and unmarshalling of vdts data structure
suite "Volume Descriptor Timestamp":
    let test_vdts: VolumeDescriptorTimestamp = (
        year:   2018,
        month:  6,
        day:    1,
        hour:   3,
        minute: 12,
        second: 50,
        hundredth:  7,
        offset: 8
    )
    let test_binary: seq[byte] = @[byte 50, 48, 49, 56, 48, 54, 48, 49, 48, 51, 49, 50, 53, 48, 48, 55, 8]

    # Test successful unmarshal of vdts
    test "Unmarshal VDTS":
        let got: VolumeDescriptorTimestamp = UnmarshalVDTS(test_binary)

        check (got == test_vdts)

    # Test short data
    test "Short Data":
        let test_data: seq[byte] = @[byte 1, 2, 3]

        expect EOFError:
            discard UnmarshalVDTS(test_data)

    # Test long data
    test "Long Data":
        let test_data: seq[byte] = @[byte 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]

        expect EOFError:
            discard UnmarshalVDTS(test_data)

    # Test successful marshal of binary
    test "Marshal VDTS":
        let got: seq[byte] = MarshalVDTS(test_vdts)

        check (got == test_binary)

    # Test end to end marshalling and unmarshalling
    test "End to End":
        var marshalled: seq[byte] = MarshalVDTS(test_vdts)

        check(len(marshalled) == 17)

        var unmarshalled: VolumeDescriptorTimestamp = UnmarshalVDTS(marshalled)

        check(unmarshalled == test_vdts)
    