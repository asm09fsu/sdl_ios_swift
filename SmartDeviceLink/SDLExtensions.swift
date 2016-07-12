//
//  SDLExtensions.swift
//  SmartDeviceLink
//
//  Created by Muller, Alexander (A.) on 7/10/16.
//  Copyright © 2016 SmartDeviceLink. All rights reserved.
//

import Foundation

public extension Data {
    mutating func append( _ uint32: UInt32) {
        var uint32 = uint32
        let bytePtr = withUnsafePointer(&uint32) {
            UnsafeBufferPointer<UInt8>(start: UnsafePointer($0), count: sizeofValue(uint32))
        }
        self.append(bytePtr)
    }
    
    mutating func append(_ uint8: UInt8) {
        var uint8 = uint8
        self.append(&uint8, count: 1)
    }
}
