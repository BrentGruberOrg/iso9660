# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest
import std/times
import iso9660/image_reader
  

suite "test reading image":

  let loremIpsum: string = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

  test "open image":
    # Test that we can successfully open an image file
    

  # test "test image read":
  #   let recordTime = initDateTime(monthday=25, month=mJul, year=2018, hour=22, minute=1, second=2)
    
  #   let f = open("../fixtures/test.iso")
  #   defer: f.close()

  #   let image = OpenImage(f)
    
  #   check:
  #     len(image.VolumeDescriptors) == 2
  #     image.VolumeDescriptors[0].Header.Type == volumeTypePrimary
  #     image.volumeDescriptors[1].Header.Type == volumeTypeTerminator

  #   let rootDir = image.RootDir()

  #   check:
  #     dirExists(rootDir)
  #     rootDir.Name() == "name"
  #     rootDir.Size() == int64(sectorSize)
  #     rootDir.ModTime() == recordTime

  #   let children = rootDir.GetChildren()
  #   check(len(children) == 4)

  #   let cicero = children[0]
  #   let dir1 = children[1]
  #   let dir2 = children[2]
  #   let dir4 = children[3]

  #   check:
  #     cicero.Name() == "CICERO.TXT"
  #     cicero.Size() == int64(845)
  #     dir1.Name() == "DIR1"
  #     dir2.Name() == "DIR2"
  #     dir4.Name() == "DIR4"

  #   # test dir1
  #   let dir1Children = dir1.GetChildren()
  #   check(len(dir1Children) == 1)

  #   let loremFile = dir1Children[0]

  #   check:
  #     loremFile.Name() == "LOREM_IP.TXT"
  #     loremFile.Size() == int64(446)

  #   let data = readFile(loremFile)

  #   check(data == loremIpsum)


  #   # test dir2
  #   let dir2Children = dir2.GetChildren()
  #   check:
  #     len(dir2Children) == 2
  #     dir2Children[0].Name() == "DIR3"

  #   let dir3Children = dir2Children[0].GetChildren()

  #   check:
  #     len(dir3Children) == 1
  #     dir3Children[0].Name() == "DATA.BIN"
  #     dir3Children[0].Size() == int64(512)
  #     dir2Children[1].Name() == "LARGE.TXT"
  #     dir2Children[1].Size() == int64(2808)
  #     dirExists(dir2Children[1])

    
  #   let dir4Children = dir4.GetChildren()

  #   check:
  #     len(dir4Children) == 1000
  #     dir4CHildren[12].Name() == "FILE1012"
