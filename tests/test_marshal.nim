import unittest

import iso9660/marshal

# Testing the MarshalString proc
suite "marshal string":
    let test_string: string = "Hello"

    test "padded string":
        # Test that a string gets padded correctly if it is not long enough
        let want: seq[byte] = @[
            byte(72),   # H
            byte(101),  # e
            byte(108),  # l
            byte(108),  # l
            byte(111),  # o
            byte(32),   # " "
            byte(32),   # " "
            byte(32),   # " "
            byte(32),   # " "
            byte(32),   # " "
            byte(32),   # " "
            byte(32)   # " "
        ]

        let got: seq[byte] = MarshalString(test_string, 12)

        check(got == want)
        check(len(got) == 12)

    test "unpadded string":
        # Test a string that should not receive any additional padding
        let want: seq[byte] = @[
            byte(72),   # H
            byte(101),  # e
            byte(108),  # l
            byte(108),  # l
            byte(111),  # o  
        ]

        let got: seq[byte] = MarshalString(test_string, 5)

        check(got == want)
        check(len(got) == 5)

    test "truncated string":
        # Test a string that should be truncated by the marshaling
        let want: seq[byte] = @[
            byte(72),   # H
            byte(101),  # e
            byte(108),  # l
        ]

        let got: seq[byte] = MarshalString(test_string, 3)

        check(got == want)
        check(len(got) == 3)

    test "negative padlength":
        # Test that error is thrown when negative pad length given
        expect(LengthError):
            discard MarshalString(test_string, -5)


suite "unmarshal int32":
    # Test the unmarshaling of bytes to an int32 object
    let test_int32_bytes: seq[byte] = @[
        byte(0x78),
        byte(0x56),
        byte(0x34),
        byte(0x12),
        byte(0x12),
        byte(0x34),
        byte(0x56),
        byte(0x78)
    ]
    let test_int32_value: int32 = 305419896

    test "test successful conversion":
        # Test that conversion from byte seq to int32 is successful        
        let got: int32 = UnMarshalInt32LSBMSB(test_int32_bytes)
        check got == test_int32_value

    test "test short input":
        # Test that exception is raised given input with too few bytes
        let bad_data: seq[byte] = @[byte(0x78), byte(0x56)]

        expect(EOFError):
            discard UnmarshalInt32LSBMSB(bad_data)

    test "test long input":
        # Test that exception is raised given input with too many bytes
        let bad_data: seq[byte] = @[
            byte(0x78),
            byte(0x56),
            byte(0x34),
            byte(0x12),
            byte(0x12),
            byte(0x34),
            byte(0x56),
            byte(0x78),
            byte(0x00),
            byte(0x00) # 10
        ]

        expect(ValueError):
            discard UnMarshalInt32LSBMSB(bad_data)

    test "test endian mismatch":
        # Test that exception is raised given misformatted data
        # Big Endian does not match Little Endian
        let bad_data: seq[byte] = @[
            byte(0x78),
            byte(0x56),
            byte(0x34),
            byte(0x12),
            byte(0x32),
            byte(0x18),
            byte(0x23),
            byte(0x78)
        ]

        expect(EndianMismatch):
            discard UnMarshalInt32LSBMSB(bad_data)


suite "unmarshal int16":
    # Test the unmarshaling of bytes to an int16 object
    let test_int16_bytes: seq[byte] = @[
        byte(0x78),
        byte(0x56),
        byte(0x56),
        byte(0x78)
    ]
    let test_int16_value: int16 = 22136

    test "test successful conversion":
        # Test that conversion from byte seq to int16 is successful        
        let got: int16 = UnMarshalInt16LSBMSB(test_int16_bytes)
        check got == test_int16_value

    test "test short input":
        # Test that exception is raised given input with too few bytes
        let bad_data: seq[byte] = @[byte(0x78), byte(0x56)]

        expect(EOFError):
            discard UnmarshalInt16LSBMSB(bad_data)

    test "test long input":
        # Test that exception is raised given input with too many bytes
        let bad_data: seq[byte] = @[
            byte(0x78),
            byte(0x56),
            byte(0x34),
            byte(0x12),
            byte(0x12),
            byte(0x34),
            byte(0x56),
            byte(0x78),
            byte(0x00),
            byte(0x00) # 10
        ]

        expect(ValueError):
            discard UnMarshalInt16LSBMSB(bad_data)

    test "test endian mismatch":
        # Test that exception is raised given misformatted data
        # Big Endian does not match Little Endian
        let bad_data: seq[byte] = @[
            byte(0x78),
            byte(0x56),
            byte(0x34),
            byte(0x12)
        ]

        expect(EndianMismatch):
            discard UnMarshalInt16LSBMSB(bad_data)

suite "marshal int32":
    # Test the marshaling of an int32 object to a sequence of bytes
    let test_int32_bytes: seq[byte] = @[
        byte(0x78),
        byte(0x56),
        byte(0x34),
        byte(0x12),
        byte(0x12),
        byte(0x34),
        byte(0x56),
        byte(0x78)
    ]
    var test_int32_value: int32 = 305419896

    test "successful marshalling":
        # Test that marshalling is successful
        let got: seq[byte] = MarshalInt32LSBMSB(test_int32_value)

        check got == test_int32_bytes

suite "marshal int16":
    # Test the marshaling of an int16 object to a sequence of bytes
    let test_int16_bytes: seq[byte] = @[
        byte(0x78),
        byte(0x56),
        byte(0x56),
        byte(0x78)
    ]
    var test_int16_value: int16 = 22136

    test "successful marshalling":
        # Test that marshalling is successful
        let got: seq[byte] = MarshalInt16LSBMSB(test_int16_value)

        check got == test_int16_bytes