import std/strutils
import std/strformat

import consts
import de
import vdts
import ../marshal
import ../endians2


type
    # PrimaryVolumeDescriptorBody represents the data in bytes 7-2047
    # of a Boot Record as defined in ECMA-119 8.4
    PrimaryVolumeDescriptorBody* = tuple
        systemIdentifier:   string
        volumeIdentifier:   string
        volumeSpaceSize:    int32
        volumeSetSize:      int16
        volumeSequenceNumber:   int16
        logicalBlockSize:   int16
        pathTableSize:      int32
        typeLPathTableLoc:  int32
        optTypeLPathTableLoc:   int32
        typeMPathTableLoc:  int32
        optTypeMPathTableLoc:   int32
        rootDirectoryEntry: DirectoryEntry
        volumeSetIdentifier:    string
        publisherIdentifier:    string
        dataPreparerIdentifier: string
        applicationIdentifier:  string
        copyrightFileIdentifier:  string
        abstractFileIdentifier: string
        bibliographicFileIdentifier:    string
        volumeCreationDateAndTime:  VolumeDescriptorTimestamp
        volumeModificationDateAndTIme:  VolumeDescriptorTimestamp
        volumeExpirationDateAndTime:    VolumeDescriptorTimestamp
        volumeEffectiveDateAndTime:     VolumeDescriptorTimestamp
        fileStructureVersion:   byte
        applicationUsed:    seq[byte]


# UnmarshalPVDB decodes a PrimaryVolumeDescriptorBody from binary form
proc UnmarshalPVDB*(data: seq[byte]): PrimaryVolumeDescriptorBody =
    if len(data) != 2048:
        raise newException(EOFError, &"Received {len(data)} bytes for volume descriptor timestamp, expected 2048")

    var pvdb: PrimaryVolumeDescriptorBody

    pvdb.systemIdentifier = toString(data[8 .. 39]).strip(leading=false)
    pvdb.volumeIdentifier = toString(data[40 .. 71]).strip(leading=false)

    pvdb.volumeSpaceSize = UnMarshalInt32LSBMSB(data[80 .. 87])
    pvdb.volumeSetSize = UnmarshalInt16LSBMSB(data[120 .. 123])
    pvdb.volumeSequenceNumber = UnmarshalInt16LSBMSB(data[124 .. 127])
    pvdb.logicalBlockSize = UnmarshalInt16LSBMSB(data[128 .. 131])
    pvdb.pathTableSize = UnMarshalInt32LSBMSB(data[132 .. 139])

    pvdb.typeLPathTableLoc = int32(fromBytesLE(uint32, data[140 .. 143]))
    pvdb.optTypeLPathTableLoc = int32(fromBytesLE(uint32, data[144 .. 147]))
    pvdb.typeMPathTableLoc = int32(fromBytesBE(uint32, data[148 .. 151]))
    pvdb.optTypeMPathTableLoc = int32(fromBytesBE(uint32, data[152 .. 155]))

    pvdb.rootDirectoryEntry = UnMarshalDE(data[156 .. 189])

    pvdb.volumeSetIdentifier = toString(data[190 .. 317]).strip(leading=false)
    pvdb.publisherIdentifier = toString(data[318 .. 445]).strip(leading=false)
    pvdb.dataPreparerIdentifier = toString(data[446 .. 573]).strip(leading=false)
    pvdb.applicationIdentifier = toString(data[574 .. 701]).strip(leading=false)
    pvdb.copyrightFileIdentifier = toString(data[702 .. 739]).strip(leading=false)
    pvdb.abstractFileIdentifier = toString(data[740 .. 775]).strip(leading=false)
    pvdb.bibliographicFileIdentifier = toString(data[776 .. 812]).strip(leading=false)

    pvdb.volumeCreationDateAndTime = UnmarshalVDTS(data[813 .. 829])
    pvdb.volumeModificationDateAndTIme = UnmarshalVDTS(data[830 .. 846])
    pvdb.volumeExpirationDateAndTime = UnmarshalVDTS(data[847 .. 863])
    pvdb.volumeEffectiveDateAndTime = UnmarshalVDTS(data[864 .. 880])

    pvdb.fileStructureVersion = data[881]
    pvdb.applicationUsed = data[883 .. 1394]

    return pvdb

# MarshalPVDB encodes a Primary Volume Descriptor to its binary form
proc MarshalPVDB*(pvdb: PrimaryVolumeDescriptorBody): seq[byte] =
    var data: seq[byte] = newSeq[byte](sectorSize)

    data[8 .. 39]= MarshalString(pvdb.systemIdentifier, 32)
    data[40 .. 71] = MarshalString(pvdb.volumeIdentifier, 32)

    data[80 .. 87] = MarshalInt32LSBMSB(pvdb.volumeSpaceSize)
    data[120 .. 123] = MarshalInt16LSBMSB(pvdb.volumeSetSize)
    data[124 .. 127] = MarshalInt16LSBMSB(pvdb.volumeSequenceNumber)
    data[128 .. 131] = MarshalInt16LSBMSB(pvdb.logicalBlockSize)
    data[132 .. 139] = MarshalInt32LSBMSB(pvdb.pathTableSize)

    data[140 .. 143] = toBytesLE(uint32(pvdb.typeLPathTableLoc))
    data[144 .. 147] = toBytesLE(uint32(pvdb.optTypeLPathTableLoc))
    data[148 .. 151] = toBytesBE(uint32(pvdb.typeMPathTableLoc))
    data[152 .. 155] = toBytesBE(uint32(pvdb.optTypeMPathTableLoc))

    data[156 .. 189] = MarshalDE(pvdb.rootDirectoryEntry)
    
    data[190 .. 317] = MarshalString(pvdb.volumeSetIdentifier, 128)
    data[318 .. 445] = MarshalString(pvdb.publisherIdentifier, 128)
    data[446 .. 573] = MarshalString(pvdb.dataPreparerIdentifier, 128)
    data[574 .. 701] = MarshalString(pvdb.applicationIdentifier, 128)
    data[702 .. 739] = MarshalString(pvdb.copyrightFileIdentifier, 38)
    data[740 .. 775] = MarshalString(pvdb.abstractFileIdentifier, 36)
    data[776 .. 812] = MarshalString(pvdb.bibliographicFileIdentifier, 37)

    data[813 .. 829] = MarshalVDTS(pvdb.volumeCreationDateAndTime)
    data[830 .. 846] = MarshalVDTS(pvdb.volumeModificationDateAndTIme)
    data[847 .. 863] = MarshalVDTS(pvdb.volumeExpirationDateAndTime)
    data[864 .. 880] = MarshalVDTS(pvdb.volumeEffectiveDateAndTime)

    data[881] = pvdb.fileStructureVersion
    data[882] = 0
    data[883 .. 1394] = pvdb.applicationUsed

    for i in 1395 .. 2047:
        data[i] = 0

    return data