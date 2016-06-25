//
//  SDLV1ProtocolHeader.swift
//  SmartDeviceLink
//
//  Created by Muller, Alexander (A.) on 6/25/16.
//  Copyright © 2016 SmartDeviceLink. All rights reserved.
//

import Foundation

public class SDLV1ProtocolHeader: SDLProtocolHeader {
    public override var data: Data? {
        var bytes = [UInt8](repeating: 0, count: size)
        
        let version: UInt8 = (self.version & 0xF) << 4
        let encrypted: UInt8 = (self.encrypted ? 1 : 0) << 3
        let frameType: UInt8 = frame.type.rawValue & 0x7
        
        bytes[0] = version | encrypted | frameType
        bytes[1] = serviceType.rawValue
        bytes[2] = frame.data.rawValue
        bytes[3] = sessionID
        
        for i in 0..<sizeof(UInt32) {
            bytes[4 + i] = UInt8(bytesInPayload >> UInt32(sizeof(UInt32) - 1 - i))
        }
        
        let data = Data(bytes: bytes, count: size)
        return data
    }
    
    convenience init() {
        self.init(size: 8, version: 1)
    }
    
    public override func parse(_ buffer: Data) {
        
    }
}
