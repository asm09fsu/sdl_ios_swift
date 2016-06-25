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
        if let headerData = header.data {
            data?.append(headerData)
        }
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
    
    init(header: SDLProtocolHeader, payload: Data?) {
        self.header = header
        self.payload = payload
    }
    
    public class func create(with header: SDLProtocolHeader, _ payload: Data? = nil) -> SDLProtocolMessage? {
        if header.version == 1 {
            return SDLV1ProtocolMessage(header: header, payload: payload)
        } else if header.version >= 2 {
            return SDLV2ProtocolMessage(header: header, payload: payload)
        } else {
            return nil
        }
    }
}
