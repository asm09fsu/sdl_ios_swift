//
//  SDLProtocolMessage.swift
//  SmartDeviceLink
//
//  Created by Muller, Alexander (A.) on 6/25/16.
//  Copyright © 2016 SmartDeviceLink. All rights reserved.
//

import Foundation

public class SDLProtocolMessage {
    public class func version(from buffer: Data) -> UInt8 {
        if let firstByte = buffer.first {
            return firstByte >> 4
        } else {
            return 0
        }
    }
}
