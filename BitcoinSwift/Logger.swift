//
//  Logger.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 10/9/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

/// Use this class to write log message. By default log messages are written to stderr.
/// To log to a custom file location, set outputFileHandle.
public class Logger {

  private static let queue = NSOperationQueue()

  /// The location where log messages will be written.
  public static var outputFileHandle = NSFileHandle.fileHandleWithStandardError()

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

  /// Log a message with log level .Debug.
  /// The log message will be written to the location specified by Logger.outputFileHandle.
  public class func debug(message: String) {
    Logger.log(.Debug, message: message)
  }

  /// Log a message with log level .Info.
  /// The log message will be written to the location specified by Logger.outputFileHandle.
  public class func info(message: String) {
    Logger.log(.Info, message: message)
  }

  /// Log a message with log level .Notice.
  /// The log message will be written to the location specified by Logger.outputFileHandle.
  public class func notice(message: String) {
    Logger.log(.Notice, message: message)
  }

  /// Log a message with log level .Warn.
  /// The log message will be written to the location specified by Logger.outputFileHandle.
  public class func warn(message: String) {
    Logger.log(.Warn, message: message)
  }

  /// Log a message with log level .Error.
  /// The log message will be written to the location specified by Logger.outputFileHandle.
  public class func error(message: String) {
    Logger.log(.Error, message: message)
  }

  /// Log a message with log level .Critical.
  /// The log message will be written to the location specified by Logger.outputFileHandle.
  public class func critical(message: String) {
    Logger.log(.Critical, message: message)
  }

  /// Log a message with log level .Alert.
  /// The log message will be written to the location specified by Logger.outputFileHandle.
  public class func alert(message: String) {
    Logger.log(.Alert, message: message)
  }

  /// Log a message with log level .Emergency.
  /// The log message will be written to the location specified by Logger.outputFileHandle.
  public class func emergency(message: String) {
    Logger.log(.Emergency, message: message)
  }

  /// Log a message the the specified log level. In general, you should use one of the other
  /// methods for logging rather than calling this directly (e.g. Logger.info()).
  /// The log message will be written to the location specified by Logger.outputFileHandle.
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
