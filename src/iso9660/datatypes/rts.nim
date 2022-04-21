import std/times


type
    # RecordingTimeStamp represents a time and date format
    # that can be encoded according to ECMA-119 9.1.5
    RecordingTimeStamp* = DateTime

# inttomonth takes as input an integer between 1 and 12 and returns
# nim's enum value for that month, I hate it
func inttomonth(month: int): Month =
    case month:
        of 1:
            return mJan
        of 2:
            return mFeb
        of 3:
            return mMar
        of 4:
            return mApr
        of 5:
            return mMay
        of 6:
            return mJun
        of 7:
            return mJul
        of 8:
            return mAug
        of 9:
            return mSep
        of 10:
            return mOct
        of 11:
            return mNov
        of 12:
            return mDec
        else:
            raise newException(ValueError, $"Received invalid month value: {month}")

# monthtoint takes as input nim's enum for a month
# and returns its integer value, I hate it
func monthtoint(month: Month): int =
    return ord(month)

# UnmarshalBinary decodes a RecordingTimestamp from binary form
# TODO: handle date not specified as noted int 9.1.5, when all values are 0
proc UnMarshalRTS*(data: seq[byte]): RecordingTimeStamp =
    if len(data) < 7:
        raise newException(EOFError, "Received too few bytes to unmarshal recording timestamp")
    if len(data) > 8:
        raise newException(ValueError, "Received too many bytes to unmarshal recording timestamp")

    let year: int = 1900 + int(data[0])
    let month: int = int(data[1])
    let day: int = int(data[2])
    let hour: int = int(data[3])
    let min: int = int(data[4])
    let sec: int = int(data[5])

    # Offset from Greenwich Mean Time in number of 15 min
    # intervals from -48 (West) to +52 (East) recorded according to 7.1.2
    let tzOffset: int = int(data[6]) - 48
    let secondsInAQuarter: int = 60 * 15

    echo "TZ Offset"
    echo tzOffset
    echo "SecondsInQuarter"
    echo secondsInAQuarter
    echo tzOffset * secondsInAQuarter

    var retval: RecordingTimestamp = initDateTime(
        year=year,
        month=inttomonth(month),
        monthday=day,
        hour=hour,
        minute=min,
        second=sec
    )
    retval.utcOffset = tzOffset * secondsInAQuarter
    return retval

# MarshalBinary encodes the RecordingTimestamp in its binary form
# to a buffer of the length of 7 or more bytes
proc MarshalRTS*(rts: RecordingTimeStamp): seq[byte] =
    var retval: seq[byte] = newSeq[byte](7) # Should this be a seq or array?

    echo "marshal utcoffset"
    echo rts.utcOffset

    let secondsInAQuarter = 60 * 15

    # Add 48 during marshaling to deal with negative
    let offsetInQuarters = (rts.utcOffset / secondsInAQuarter) + 48

    echo "offsetinquarters"
    echo offsetInQuarters 

    retval[0] = byte(rts.year - 1900)
    retval[1] = byte(monthtoint(rts.month))
    retval[2] = byte(rts.monthday)
    retval[3] = byte(rts.hour)
    retval[4] = byte(rts.minute)
    retval[5] = byte(rts.second)
    retval[6] = byte(offsetInQuarters)

    return retval
