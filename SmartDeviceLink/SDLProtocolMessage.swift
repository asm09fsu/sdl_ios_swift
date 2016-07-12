//
//  SDLProtocolMessage.swift
//  SmartDeviceLink
//
//  Created by Muller, Alexander (A.) on 6/25/16.
//  Copyright © 2016 SmartDeviceLink. All rights reserved.
//

import Foundation

public class SDLProtocolMessage {
    public var header: SDLProtocolHeader
    public var payload: Data?
    
    public var size: Int {
        if let payload = payload {
            return header.size + payload.count
        } else {
            return header.size
        }
    }
    
    public var data: Data? {
        var data = Data(capacity: size)
        
        data?.append(header.data)
        
        if let payload = payload {
            data?.append(payload)
        }
        return data
    }
    
    public class func version(from buffer: Data) -> UInt8 {
        if let firstByte = buffer.first {
            return firstByte >> 4
        } else {
            return 0
        }
    }
    
    init(header: SDLProtocolHeader, payload: Data? = nil) {
        self.header = header
        self.payload = payload
    }
}

extension SDLProtocolMessage: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "Version: \(header.version), sessionID: \(header.sessionID), encrypted: \(header.encrypted), frame: (type: \(header.frame.type), data: \(header.frame.data)), serviceType: \(header.serviceType), payload: \(payload!.count) bytes"
    }
}
