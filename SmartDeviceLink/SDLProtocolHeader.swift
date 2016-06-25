//
//  SDLProtocolHeader.swift
//  SmartDeviceLink
//
//  Created by Muller, Alexander (A.) on 6/25/16.
//  Copyright © 2016 SmartDeviceLink. All rights reserved.
//

import Foundation

public class SDLProtocolHeader {
    private var _size: UInt = 0
    private var _version: UInt8 = 0
    
    public var size: UInt {
        return _size
    }
    
    public var version: UInt8 {
        return _version
    }
    
    public var bytesInPayload: UInt32 = 0
    
    init(size: UInt, version: UInt8) {
        _size = size
        _version = version
    }
    
    public class func header(for version: UInt8) -> SDLProtocolHeader? {
        switch version {
            case 1:
                return SDLV1ProtocolHeader()
            case 2, 3, 4:
                return SDLV2ProtocolHeader(version: version)
            default:
                return nil
        }
    }
    
    public func parse(_ buffer: Data) { }
}
