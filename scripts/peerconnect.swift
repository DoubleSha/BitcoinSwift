#!/usr/bin/env xcrun swift -sdk /Applications/Xcode6-Beta6.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk

import Cocoa
let alert = NSAlert()
alert.messageText = "Hello!"
alert.runModal()
