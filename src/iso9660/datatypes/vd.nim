import vdh
import bvdb
import pvdb


type
    VolumeDescriptor* = tuple
        header: VolumeDescriptorHeader
        boot:   BootVolumeDescriptorBody
        primary:    PrimaryVolumeDescriptorBody