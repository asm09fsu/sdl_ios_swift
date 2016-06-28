//
//  SDLV2ProtocolHeader.swift
//  SmartDeviceLink
//
//  Created by Muller, Alexander (A.) on 6/25/16.
//  Copyright © 2016 SmartDeviceLink. All rights reserved.
//

import Foundation

public class SDLV2ProtocolHeader: SDLProtocolHeader {
    
    public var messageID: UInt32 = 0
    
    convenience init(version: UInt8) {
        self.init(size: 12, version: version)
    }
    
    public override func parse(_ data: Data) {
        super.parse(data)
        
        let pointer = UnsafeMutablePointer<UInt32>(allocatingCapacity: size)
        let bytes = UnsafeMutableBufferPointer<UInt32>(start: pointer, count: size)
        _ = data.copyBytes(to: bytes)
        bytesInPayload = CFSwapInt32BigToHost(bytes[1])
        messageID = CFSwapInt32BigToHost(bytes[2])
    }
}
