//
//  StoredBlockHeader.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 11/29/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public struct StoredBlockHeader {

  let blockHeader: BlockHeader
  let height: Int32
  let chainWork: BigInteger
}
