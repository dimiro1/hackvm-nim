import std/strformat

type BadAddress* = object of IndexDefect
  ## Raised if an memory address is out of bounds.

type BadOpcode* = object of Defect
  ## Raised if an invalid opcode is given.

proc newBadOpcode(opcode: int): ref BadOpcode =
  result = newException(BadOpcode, fmt"invalid opcode {opcode:#04X}")

proc newBadAddress(address: int): ref BadAddress =
  result = newException(BadAddress, fmt"invalid memory address {address:#04X}")

proc u16[T: SomeInteger](i: T): int {.noSideEffect.} =
  result = i and 0xFFFF

type Computer* = object
  ram: array[0..0x6000, int]
  rom: array[0..0x8000, int]
  a: int
  d: int
  pc: int

proc newComputer*(): Computer {.noSideEffect.} =
  result.a = 0
  result.d = 0
  result.pc = 0

proc loadRom*(c: var Computer, data: seq[int]) =
  for i, d in data:
    c.rom[i] = d

proc readRom(c: Computer, address: int): int =
  try:
    result = c.rom[address].u16
  except IndexDefect:
    raise newBadAddress(address)

proc readRam*(c: Computer, address: int): int =
  try:
    result = c.ram[address].u16
  except IndexDefect:
    raise newBadAddress(address)

proc readWithCompM(c: Computer, compm: bool): int =
  if compm:
    result = c.readRam(c.a)
  else:
    result = c.a

proc writeRam(c: var Computer, address: int, value: int) =
  try:
    c.ram[address] = value.u16
  except IndexDefect:
    raise newBadAddress(address)

proc step*(c: var Computer) =
  let opc = c.readRom(c.pc)

  case (opc and 0x8000) shr 15:
    of 0:
      c.a = opc and 0x7FFF
      c.pc += 1
    of 1:
      let
        compm = ((opc and 0x1000) shr 12) == 1
        comp = opc and 0xFC0
        dest = (opc and 0x038) shr 3
        desta = ((dest and 0x4) shr 2) == 1
        destd = ((dest and 0x2) shr 1) == 1
        destm = (dest and 0x1) == 1

      let aluOut = case comp
        of 0xA80: 0
        of 0xFC0: 1
        of 0xE80: -1
        of 0x300: c.d
        of 0xC00: c.readWithCompM(compm)
        of 0x340: (not c.d) and 0xFF
        of 0xC40: not c.readWithCompM(compm)
        of 0x3C0: -c.d
        of 0xCC0: -c.a
        of 0x7C0: c.d+1
        of 0xDC0: c.readWithCompM(compm) + 1
        of 0x380: c.d-1
        of 0xC80: c.readWithCompM(compm) - 1
        of 0x080: c.d + c.readWithCompM(compm)
        of 0x4C0: c.d - c.readWithCompM(compm)
        of 0x1C0: c.readWithCompM(compm) - c.d
        of 0x000: c.d and c.readWithCompM(compm)
        of 0x540: c.d or c.readWithCompM(compm)
        else:
          raise newBadOpcode(opc)

      if destm:
        c.writeRam(c.a, aluOut)

      if desta:
        c.a = aluOut

      if destd:
        c.d = aluOut

      let jump = case opc and 0x7
        of 0: false
        of 1: aluOut > 0
        of 2: aluOut == 0
        of 3: aluOut >= 0
        of 4: aluOut < 0
        of 5: aluOut != 0
        of 6: aluOut <= 0
        of 7: true
        else: false

      if jump:
        c.pc = c.a
      else:
        c.pc += 1
    else:
      raise newBadOpcode(opc)

proc keyUp*(c: var Computer) =
  c.writeRam(0x6000, 0)

proc keyDown*(c: var Computer, key: string) =
  let keyCode = case key
    of " ": 32
    of "!": 33
    of "\"": 34
    of "#": 35
    of "$": 36
    of "%": 37
    of "&": 38
    of "'": 39
    of "(": 40
    of ")": 41
    of "*": 42
    of "+": 43
    of ",": 44
    of "-": 45
    of ".": 46
    of "0": 48
    of "1": 49
    of "2": 50
    of "3": 51
    of "4": 52
    of "5": 53
    of "6": 54
    of "7": 55
    of "8": 56
    of "9": 57
    of ":": 58
    of ";": 59
    of "<": 60
    of "=": 61
    of ">": 62
    of "?": 63
    of "@": 64
    of "A": 65
    of "B": 66
    of "C": 67
    of "D": 68
    of "E": 69
    of "F": 70
    of "G": 71
    of "H": 72
    of "I": 73
    of "J": 74
    of "K": 75
    of "L": 76
    of "M": 77
    of "N": 78
    of "O": 79
    of "P": 80
    of "Q": 81
    of "R": 82
    of "S": 83
    of "T": 84
    of "U": 85
    of "V": 86
    of "W": 87
    of "X": 88
    of "Y": 89
    of "Z": 90
    of "[": 91
    of "/": 92
    of "]": 93
    of "^": 94
    of "_": 95
    of "`": 96
    of "a": 97
    of "b": 98
    of "c": 99
    of "d": 100
    of "e": 101
    of "f": 102
    of "g": 103
    of "h": 104
    of "i": 105
    of "j": 106
    of "k": 107
    of "l": 108
    of "m": 109
    of "n": 110
    of "o": 111
    of "p": 112
    of "q": 113
    of "r": 114
    of "s": 115
    of "t": 116
    of "u": 117
    of "v": 118
    of "w": 119
    of "x": 120
    of "y": 121
    of "z": 122
    of "{": 123
    of "|": 124
    of "}": 125
    of "~": 126
    of "Enter": 138
    of "Backspace": 129
    of "ArrowLeft": 130
    of "ArrowUp": 131
    of "ArrowRight": 132
    of "ArrowDown": 133
    of "Home": 134
    of "End": 135
    of "PageUp": 136
    of "PageDown": 137
    of "Insert": 138
    of "Delete": 139
    of "Escape": 140
    of "F1": 141
    of "F2": 142
    of "F3": 143
    of "F4": 144
    of "F5": 145
    of "F6": 146
    of "F7": 147
    of "F8": 148
    of "F9": 149
    of "F10": 150
    of "F11": 121
    of "F12": 152
    else: 0

  c.writeRam(0x6000, keyCode)

proc main() =
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

when isMainModule:
  main()
