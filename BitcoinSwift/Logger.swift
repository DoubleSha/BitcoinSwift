//
//  Logger.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 10/9/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public class Logger {

  // TODO: Add support for logging to a file.

  public class func info(message: String) {
    println("\(Logger.currentDateString()) INFO \(message)")
  }

  public class func debug(message: String) {
    println("\(Logger.currentDateString()) DEBUG \(message)")
  }

  public class func warn(message: String) {
    println("\(Logger.currentDateString()) WARN \(message)")
  }

  public class func error(message: String) {
    println("\(Logger.currentDateString()) ERROR \(message)")
  }

  public class func currentDateString() -> String {
    return NSDate().description
  }
}
