#!/usr/bin/swift

import Foundation

// Change this to the bytes you want printed in reverse.
let bytes: [UInt8] = [
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x0a, 0x72, 0xd2, 0xe6, 0x63, 0x4a, 0x71, 0x6f,
    0x3c, 0x51, 0x92, 0x1e, 0xe4, 0x47, 0x4c, 0x25,
    0x33, 0x48, 0x0b, 0xa7, 0x44, 0xd8, 0xf7, 0x24]

func reverseBytes(originalBytes: [UInt8]) -> [UInt8] {
  var bytes = originalBytes
  var tmp: UInt8 = 0
  for i in 0..<(bytes.count / 2) {
    tmp = bytes[i]
    bytes[i] = bytes[bytes.count - i - 1]
    bytes[bytes.count - i - 1] = tmp
  }
  return bytes
}

let reversedBytes = reverseBytes(bytes)
println("let bytes: [UInt8] = [")
for i in 0..<reversedBytes.count {
  if i % 8 == 0 {
    if i > 0 {
      println()
    }
    print("    ")
  }
  let byte = reversedBytes[i]
  print(String(format: "0x%02x", byte))
  if i == reversedBytes.count - 1 {
    print("]")
  } else if i % 8 == 7 {
    print(",")
  } else {
    print(", ")
  }
}
println()
