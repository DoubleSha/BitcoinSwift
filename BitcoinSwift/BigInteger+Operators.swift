//
//  BigInteger+Operators.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 11/29/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

public func ==(left: BigInteger, right: BigInteger) -> Bool {
  return left.isEqual(right)
}

public func <(left: BigInteger, right: BigInteger) -> Bool {
  return left.lessThan(right)
}

public func <=(left: BigInteger, right: BigInteger) -> Bool {
  return left.lessThanOrEqual(right)
}

public func >(left: BigInteger, right: BigInteger) -> Bool {
  return left.greaterThan(right)
}

public func >=(left: BigInteger, right: BigInteger) -> Bool {
  return left.greaterThanOrEqual(right)
}

public func +(left: BigInteger, right: BigInteger) -> BigInteger {
  return left.add(right)
}

public func -(left: BigInteger, right: BigInteger) -> BigInteger {
  return left.subtract(right)
}

public func *(left: BigInteger, right: BigInteger) -> BigInteger {
  return left.multiply(right)
}

public func /(left: BigInteger, right: BigInteger) -> BigInteger {
  return left.divide(right)
}

public func %(left: BigInteger, right: BigInteger) -> BigInteger {
  return left.modulo(right)
}

public func <<(left: BigInteger, right: Int) -> BigInteger {
  return left.shiftLeft(Int32(right))
}

public func >>(left: BigInteger, right: Int) -> BigInteger {
  return left.shiftRight(Int32(right))
}

// TODO: Make this conform to IntegerArithmeticType? BitwiseOperationsType?
extension BigInteger: Comparable, IntegerLiteralConvertible {}
