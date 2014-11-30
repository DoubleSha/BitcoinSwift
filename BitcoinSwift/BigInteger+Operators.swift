//
//  BigInteger+Operators.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 11/29/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

public func ==(lhs: BigInteger, rhs: BigInteger) -> Bool {
  return lhs.isEqual(rhs)
}

public func <(lhs: BigInteger, rhs: BigInteger) -> Bool {
  return lhs.lessThan(rhs)
}

public func <=(lhs: BigInteger, rhs: BigInteger) -> Bool {
  return lhs.lessThanOrEqual(rhs)
}

public func >(lhs: BigInteger, rhs: BigInteger) -> Bool {
  return lhs.greaterThan(rhs)
}

public func >=(lhs: BigInteger, rhs: BigInteger) -> Bool {
  return lhs.greaterThanOrEqual(rhs)
}

public func +(lhs: BigInteger, rhs: BigInteger) -> BigInteger {
  return lhs.add(rhs)
}

public func -(lhs: BigInteger, rhs: BigInteger) -> BigInteger {
  return lhs.subtract(rhs)
}

public func *(lhs: BigInteger, rhs: BigInteger) -> BigInteger {
  return lhs.multiply(rhs)
}

public func /(lhs: BigInteger, rhs: BigInteger) -> BigInteger {
  return lhs.divide(rhs)
}

public func %(lhs: BigInteger, rhs: BigInteger) -> BigInteger {
  return lhs.modulo(rhs)
}

public func <<(lhs: BigInteger, rhs: Int) -> BigInteger {
  return lhs.shiftLeft(Int32(rhs))
}

public func >>(lhs: BigInteger, rhs: Int) -> BigInteger {
  return lhs.shiftRight(Int32(rhs))
}

// TODO: Make this conform to IntegerArithmeticType? BitwiseOperationsType?
extension BigInteger: Comparable, IntegerLiteralConvertible {}
