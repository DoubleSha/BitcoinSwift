//
//  QRCode.swift
//  BitcoinSwift
//
//  Created by Huang Yu on 8/17/15.
//  Copyright (c) 2015 DoubleSha. All rights reserved.
//

import UIKit

public class QRCode: NSObject {
    public class func image(string: String, size: CGSize, scale:CGFloat) -> UIImage? {
        var filter = CIFilter(name: "CIQRCodeGenerator")
        let data = string.dataUsingEncoding(NSISOLatin1StringEncoding, allowLossyConversion: false)
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("L", forKey: "inputCorrectionLevel")
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context = UIGraphicsGetCurrentContext()
        let cgimage = CIContext(options: nil).createCGImage(
            filter.outputImage,
            fromRect: filter.outputImage.extent())
        CGContextSetInterpolationQuality(context, kCGInterpolationNone)
        CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgimage)
        let image = UIImage(
            CGImage: UIGraphicsGetImageFromCurrentImageContext().CGImage,
            scale: scale,
            orientation: UIImageOrientation.DownMirrored)
        UIGraphicsEndImageContext()
        return image
    }
}
