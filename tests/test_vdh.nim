import unittest

import iso9660/datatypes/vdh

# Testing Marshalling and unmarshalling of vdh data structure
suite "Volume Descriptor Header":
    let test_vdh: VolumeDescriptorHeader = (
        volume_type: byte(1),
        identifier: @[
            byte('C'),
            byte('D'),
            byte('0'),
            byte('0'),
            byte('1'),
        ],
        version: byte(3)
    )
    let test_binary: seq[byte] = @[
        byte(1),
        byte('C'),
        byte('D'),
        byte('0'),
        byte('0'),
        byte('1'),
        byte(3)
    ]


    # Test successful unmarshaling
    test "Unmarshal Volume Descriptor Header":
        let got: VolumeDescriptorHeader = UnMarshalVDH(test_binary)
        let want: VolumeDescriptorHeader = test_vdh
        check(got == want)

    # Test unmarshaling with too few bytes
    test "Short byte seq":
        let test_data: seq[byte] = @[
            byte(1),
            byte(2),
            byte(3)
        ]
        
        expect EOFError:
            discard UnMarshalVDH(test_data)

    # Test unmarshaling with too many bytes
    test "Long byte seq":
        let test_data: seq[byte] = @[
            byte(1),
            byte(2),
            byte(3),
            byte(4),
            byte(5),
            byte(6),
            byte(7),
            byte(8),
            byte(9),
            byte(10)
        ]

        expect ValueError:
            discard UnMarshalVDH(test_data)

    # Test Marshaling
    test "marshal":
        let got: seq[byte] = MarshalVDH(test_vdh)
        let want: seq[byte] = test_binary

        check(got == want)

    # Test end to end
    test "end to end":
        let unmarshalled: VolumeDescriptorHeader = UnMarshalVDH(test_binary)

        check(unmarshalled == test_vdh)

        let marshalled: seq[byte] = MarshalVDH(unmarshalled)

        check(marshalled == test_binary)
    

