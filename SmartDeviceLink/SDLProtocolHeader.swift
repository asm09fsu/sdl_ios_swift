//
//  SDLProtocolHeader.swift
//  SmartDeviceLink
//
//  Created by Muller, Alexander (A.) on 6/25/16.
//  Copyright © 2016 SmartDeviceLink. All rights reserved.
//

import Foundation

public class SDLProtocolHeader {
    public struct Frame {
        public var type: SDLFrameType = .control
        public var data: SDLFrameData = .control
    }
    
    private var _size: Int = 0
    private var _version: UInt8 = 0
    
    public var size: Int {
        return _size
    }
    
    public var version: UInt8 {
        return _version
    }
    
    public var frame: Frame = Frame()
    public var serviceType: SDLServiceType = .control
    public var sessionID: UInt8 = 0
    public var bytesInPayload: UInt32 = 0
    public var encrypted = false
    
    public var data: Data? {
        return nil
    }
    
    init(size: Int, version: UInt8) {
        _size = size
        _version = version
    }
    
    public class func header(for type: SDLServiceType, sessionID: UInt8) -> SDLProtocolHeader? {
        var header = self.header(for: SDLGlobals.protocolVersion)
        
        switch type {
            case .rpc:
                header = SDLV1ProtocolHeader()
            default: break
        }
        
        header?.frame.data = .startSession
        header?.serviceType = type
        header?.sessionID = sessionID
        
        return header
    }
    
    public class func header(for version: UInt) -> SDLProtocolHeader? {
        return header(for: UInt8(version))
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
    
    public func parse(_ data: Data) {
        let firstByte = data[0]
        encrypted = (firstByte & 0x08) != 0
        frame.type = SDLFrameType(rawValue: (firstByte & 0x07))!
        serviceType = SDLServiceType(rawValue: data[1])!
        frame.data = SDLFrameData(rawValue: data[2])!
        sessionID = data[3]
    }
}
