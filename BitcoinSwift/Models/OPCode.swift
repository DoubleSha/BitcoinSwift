//
//  OpCode.swift
//  BitcoinSwift
//
//  Created by Huang Yu on 8/24/15.
//  Copyright (c) 2015 DoubleSha. All rights reserved.
//

import Foundation

public func ==(left: OPCode, right: OPCode) -> Bool {
  return left.rawValue == right.rawValue
}

public func <(left: OPCode, right: OPCode) -> Bool {
  return left.rawValue < right.rawValue
}

public func <=(left: OPCode, right: OPCode) -> Bool {
  return left.rawValue <= right.rawValue
}

public func >(left: OPCode, right: OPCode) -> Bool {
  return left.rawValue > right.rawValue
}

public func >=(left: OPCode, right: OPCode) -> Bool {
  return left.rawValue >= right.rawValue
}

public enum OPCode: UInt8, Comparable {
  case OP_0 = 0
  public static var OP_FALSE:OPCode {
    get {
      return OP_0
    }
  }
  case OP_PUSHDATA1 = 76
  case OP_PUSHDATA2 = 77
  case OP_PUSHDATA4 = 78
  case OP_1NEGATE = 79
  case OP_RESERVED = 80
  case OP_1 = 81
  public static var OP_TRUE:OPCode {
    get {
      return OP_1
    }
  }
  case OP_2 = 82
  case OP_3 = 83
  case OP_4 = 84
  case OP_5 = 85
  case OP_6 = 86
  case OP_7 = 87
  case OP_8 = 88
  case OP_9 = 89
  case OP_10 = 90
  case OP_11 = 91
  case OP_12 = 92
  case OP_13 = 93
  case OP_14 = 94
  case OP_15 = 95
  case OP_16 = 96
  
  case OP_NOP = 97
  case OP_VER = 98
  case OP_IF = 99
  case OP_NOTIF = 100
  case OP_VERIF = 101
  case OP_VERNOTIF = 102
  case OP_ELSE = 103
  case OP_ENDIF = 104
  case OP_VERIFY = 105
  case OP_RETURN = 106
  
  case OP_TOALTSTACK = 107
  case OP_FROMALTSTACK = 108
  case OP_2DROP = 109
  case OP_2DUP = 110
  case OP_3DUP = 111
  case OP_2OVER = 112
  case OP_2ROT = 113
  case OP_2SWAP = 114
  case OP_IFDUP = 115
  case OP_DEPTH = 116
  case OP_DROP = 117
  case OP_DUP = 118
  case OP_NIP = 119
  case OP_OVER = 120
  case OP_PICK = 121
  case OP_ROLL = 122
  case OP_ROT = 123
  case OP_SWAP = 124
  case OP_TUCK = 125
  
  case OP_CAT = 126
  case OP_SUBSTR = 127
  case OP_LEFT = 128
  case OP_RIGHT = 129
  case OP_SIZE = 130
  
  case OP_INVERT = 131
  case OP_AND = 132
  case OP_OR = 133
  case OP_XOR = 134
  case OP_EQUAL = 135
  case OP_EQUALVERIFY = 136
  case OP_RESERVED1 = 137
  case OP_RESERVED2 = 138
  
  case OP_1ADD = 139
  case OP_1SUB = 140
  case OP_2MUL = 141
  case OP_2DIV = 142
  case OP_NEGATE = 143
  case OP_ABS = 144
  case OP_NOT = 145
  case OP_0NOTEQUAL = 146
  case OP_ADD = 147
  case OP_SUB = 148
  case OP_MUL = 149
  case OP_DIV = 150
  case OP_MOD = 151
  case OP_LSHIFT = 152
  case OP_RSHIFT = 153
  
  case OP_BOOLAND = 154
  case OP_BOOLOR = 155
  case OP_NUMEQUAL = 156
  case OP_NUMEQUALVERIFY = 157
  case OP_NUMNOTEQUAL = 158
  case OP_LESSTHAN = 159
  case OP_GREATERTHAN = 160
  case OP_LESSTHANOREQUAL = 161
  case OP_GREATERTHANOREQUAL = 162
  case OP_MIN = 163
  case OP_MAX = 164
  
  case OP_WITHIN = 165
  
  case OP_RIPEMD160 = 166
  case OP_SHA1 = 167
  case OP_SHA256 = 168
  case OP_HASH160 = 169
  case OP_HASH256 = 170
  case OP_CODESEPARATOR = 171
  case OP_CHECKSIG = 172
  case OP_CHECKSIGVERIFY = 173
  case OP_CHECKMULTISIG = 174
  case OP_CHECKMULTISIGVERIFY = 175
  
  case OP_NOP1 = 176
  case OP_NOP2 = 177
  case OP_NOP3 = 178
  case OP_NOP4 = 179
  case OP_NOP5 = 180
  case OP_NOP6 = 181
  case OP_NOP7 = 182
  case OP_NOP8 = 183
  case OP_NOP9 = 184
  case OP_NOP10 = 185
  
  case OP_PUBKEYHASH = 253
  case OP_PUBKEY = 254
  case OP_INVALIDOPCODE = 255
}
