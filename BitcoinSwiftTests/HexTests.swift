//
//  HexTests.Swift
//  BitcoinSwift
//
//  Created by Huang Yu on 8/26/15.
//  Copyright (c) 2015 DoubleSha. All rights reserved.
//

import BitcoinSwift
import XCTest

class HexTests: XCTestCase {
    
    let hexBytes: [UInt8] = [
        117, 237, 64, 210, 129, 165, 199, 156,
        22, 53, 205, 67, 164, 232, 47, 176,
        116, 141, 39, 28, 140, 131, 36, 89,
        168, 215, 146, 122, 74, 61, 211, 81
    ]
    
    var hexData: NSData!
    
    let hexString = "51d33d4a7a92d7a85924838c1c278d74b02fe8a443cd35169cc7a581d240ed75"
    let invalidHexStrings = [ "wronghex", " ", "123%(*&" ]
    override func setUp() {
        super.setUp()
        hexData = NSData(bytes: hexBytes.reverse(), length: hexBytes.count)
    }
    
    func testHexEncoding() {
        XCTAssertEqual(hexData.hexString, hexString)
    }
    
    func testHexEncodingWithEmptyData() {
        XCTAssertEqual(NSData().hexString, "")
    }
    
    func testHexDecoding() {
        if let testHexData = NSData.fromHexString(hexString) {
            XCTAssertEqual(testHexData, hexData)
        } else {
            XCTFail("Failed to parse hexData")
        }
    }
    
    func testHexDecodingWithInvalidHexString() {
        for invalidHexString in invalidHexStrings {
            XCTAssertNil(NSData.fromHexString(invalidHexString))
        }
    }
    
    func testHexDecodingWithEmptyData() {
        if let testHexData = NSData.fromHexString("") {
            XCTAssertEqual(testHexData, NSData())
        } else {
            XCTFail("Failed to parse empty hexData")
        }
    }
}
