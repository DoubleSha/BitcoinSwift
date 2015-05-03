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

  public class func debug(message: String) {
    Logger.log(message, prefix: "DEBUG   ")
  }

  public class func info(message: String) {
    Logger.log(message, prefix: "INFO    ")
  }

  public class func warn(message: String) {
    Logger.log(message, prefix: "WARN    ")
  }

  public class func error(message: String) {
    Logger.log(message, prefix: "ERROR   ")
  }

  public class func critical(message: String) {
    Logger.log(message, prefix: "CRITICAL")
  }

  private class var currentTimeString: String {
    var time = time_t(NSDate().timeIntervalSince1970)
    var timeStruct = gmtime(&time)
    var timeBuffer = [Int8](count: 20, repeatedValue: 0)
    strftime(&timeBuffer, 20, "%Y-%m-%d %H:%M:%S", timeStruct)
    return NSString(CString: timeBuffer, encoding: NSASCIIStringEncoding)! as String
  }

  private class func log(message: String, prefix: String) {
    println("\(prefix) [\(currentTimeString)] \(message)")
  }
}
