//
//  SDLV1ProtocolHeader.swift
//  SmartDeviceLink
//
//  Created by Muller, Alexander (A.) on 6/25/16.
//  Copyright © 2016 SmartDeviceLink. All rights reserved.
//

import Foundation

public class SDLV1ProtocolHeader: SDLProtocolHeader {
    convenience init() {
        self.init(size: 8, version: 1)
    }
    
    public override func parse(_ data: Data) {
        super.parse(data)

        let pointer = UnsafeMutablePointer<UInt32>(allocatingCapacity: size)
        let bytes = UnsafeMutableBufferPointer<UInt32>(start: pointer, count: size)
        _ = data.copyBytes(to: bytes)

        bytesInPayload = CFSwapInt32BigToHost(bytes[1])
    }
}
