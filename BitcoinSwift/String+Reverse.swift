//
//  String+Reverse.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 12/25/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

extension String {

  public var reversedString: String {
    var reversedString = String()
    for char in Array(self.characters.reverse()) {
      reversedString.append(char)
    }
    return reversedString
  }
}
