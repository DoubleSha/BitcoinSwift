//
//  NSStream+Binding.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 9/1/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

extension NSStream {

  /// Creates an input/output stream pair that are bound together using a buffer of size bufferSize.
  /// Data written to outputStream will be received by inputStream, and vice versa.
  class func boundStreamsWithBufferSize(bufferSize: Int) ->
      (inputStream: NSInputStream, outputStream: NSOutputStream) {
    var readStream: Unmanaged<CFReadStream>?;
    var writeStream: Unmanaged<CFWriteStream>?;
    CFStreamCreateBoundPair(nil, &readStream, &writeStream, bufferSize)
    return (readStream!.takeUnretainedValue(), writeStream!.takeUnretainedValue())
  }
}
