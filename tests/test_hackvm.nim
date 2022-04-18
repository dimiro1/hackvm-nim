import unittest
import hackvm

suite "hackvm tests":
  test "keyboard":
    var c = newComputer()
    doAssert c.readRam(0x6000) == 0
    c.keyDown("$")
    doAssert c.readRam(0x6000) == 36
    c.keyUp()
    doAssert c.readRam(0x6000) == 0

  test "addition":
    var c = newComputer()
    c.loadRom(@[
      0b0000000000000010, # @2
      0b1110110000010000, # D=A
      0b0000000000000011, # @3
      0b1110000010010000, # D=D+A
      0b0000000000000000, # @0
      0b1110001100001000, # M=D
    ])

    for i in (0..5):
      c.step()

    doAssert c.readRam(0) == 5
