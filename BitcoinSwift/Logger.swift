//
//  Logger.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 10/9/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

/// Use this class to write log message. By default log messages are written to stderr.
/// TODO: Add support for logging to a file.
public class Logger {

  private static let queue = NSOperationQueue()
  private static var outputFileHandle = NSFileHandle.fileHandleWithStandardError()

  public enum LogLevel: String {
    case Debug     = "DEBUG   "
    case Info      = "INFO    "
    case Notice    = "NOTICE  "
    case Warn      = "WARN    "
    case Error     = "ERROR   "
    case Critical  = "CRITICAL"
    case Alert     = "ALERT   "
    case Emergency = "EMERGENCY"
  }

  public class func debug(message: String) {
    Logger.log(.Debug, message: message)
  }

  public class func info(message: String) {
    Logger.log(.Info, message: message)
  }

  public class func notice(message: String) {
    Logger.log(.Notice, message: message)
  }

  public class func warn(message: String) {
    Logger.log(.Warn, message: message)
  }

  public class func error(message: String) {
    Logger.log(.Error, message: message)
  }

  public class func critical(message: String) {
    Logger.log(.Critical, message: message)
  }

  public class func alert(message: String) {
    Logger.log(.Alert, message: message)
  }

  public class func emergency(message: String) {
    Logger.log(.Emergency, message: message)
  }

  public class func log(logLevel: LogLevel, message: String) {
    Logger.queue.addOperationWithBlock {
      Logger.outputFileHandle.writeData(
          "\(logLevel.rawValue) [\(Logger.currentTimeString)] \(message)\n"
              .dataUsingEncoding(NSUTF8StringEncoding)!)
    }
  }

  private class var currentTimeString: String {
    var time = time_t(NSDate().timeIntervalSince1970)
    var timeStruct = gmtime(&time)
    var timeBuffer = [Int8](count: 20, repeatedValue: 0)
    strftime(&timeBuffer, 20, "%Y-%m-%d %H:%M:%S", timeStruct)
    return NSString(CString: timeBuffer, encoding: NSASCIIStringEncoding)! as String
  }
}
