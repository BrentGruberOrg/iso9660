import unittest

import std/times
import iso9660/datatypes/rts

# Testing Marshalling and unmarshalling of rts data structure
suite "Recording Time Stamp":
    var test_rts: RecordingTimeStamp = initDateTime(
        30,
        mMar,
        2017,
        8,
        41,
        17
    )
    test_rts.utcOffset = -8 * 60 * 15

    let test_binary: seq[byte] = @[
        byte(117), 
        byte(3), 
        byte(30), 
        byte(8), 
        byte(41), 
        byte(17), 
        byte(40)
    ]

    # Test successful unmarshaling
    test "Unmarshal Recording Timestamp":
        let got: RecordingTimeStamp = UnMarshalRTS(test_binary)
        let want: RecordingTimeStamp = test_rts
        check(got == want)

    # Test unmarshaling with too few bytes
    test "Short byte seq":
        let test_data: seq[byte] = @[
            byte(1),
            byte(2),
            byte(3)
        ]
        
        expect EOFError:
            discard UnMarshalRTS(test_data)

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
            discard UnMarshalRTS(test_data)

    # # Test Marshaling
    test "marshal":
        let got: seq[byte] = MarshalRTS(test_rts)
        let want: seq[byte] = test_binary

        check(got == want)

    # # Test end to end
    test "end to end":
        let data: RecordingTimeStamp = now()

        let marshalled: seq[byte] = MarshalRTS(data)

        let unmarshalled: RecordingTimeStamp = UnMarshalRTS(marshalled)

        check:
            unmarshalled.year == data.year
            unmarshalled.month == data.month
            unmarshalled.monthday == data.monthday
            unmarshalled.hour == data.hour
            unmarshalled.minute == data.minute
            unmarshalled.second == data.second
            unmarshalled.utcOffset == data.utcOffset
    

