//
//  BitcoinUnitTestParameters.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 2/27/15.
//  Copyright (c) 2015 DoubleSha. All rights reserved.
//

import BitcoinSwift
import Foundation

class BitcoinUnitTestParameters: BitcoinMainNetParameters {

  override var blockChainStoreFileName: String {
    return "blockchain_unittest"
  }
}
