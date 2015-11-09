//
//  BitcoinParameters.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 1/15/15.
//  Copyright (c) 2015 DoubleSha. All rights reserved.
//

import Foundation

public protocol BitcoinParameters: TransactionParameters, AddressParameters,
    BlockHeaderParameters, BlockChainStoreParameters, ExtendedKeyVersionParameters {}
