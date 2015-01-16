//
//  BitcoinTestNetParamaters.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 1/15/15.
//  Copyright (c) 2015 DoubleSha. All rights reserved.
//

import Foundation

public class BitcoinTestNetParameters: BitcoinParameters {

  public class func get() -> BitcoinTestNetParameters {
    // TODO: Remove this once Swift supports class vars.
    struct Static {
      static let instance = BitcoinTestNetParameters()
    }
    return Static.instance
  }

  public var transactionVersion: UInt32 {
    return 1
  }
}
