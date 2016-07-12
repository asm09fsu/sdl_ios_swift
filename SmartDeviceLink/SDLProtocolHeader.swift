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
        public var data: UInt8 = SDLFrameData.startSession
    }
    
    private var _size: Int = 8
    private var _version: UInt8 = 1
    
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
    public var messageID: UInt32 = 0
    
    public var data: Data {
        if var data = Data(capacity: size) {
            let version: UInt8 = (self.version & 0xF) << 4
            let encrypted: UInt8 = (self.encrypted ? 1 : 0) << 3
            let frameType: UInt8 = frame.type.rawValue & 0x7
            
            data.append(version | encrypted | frameType)
            data.append(serviceType.rawValue)
            data.append(frame.data)
            data.append(sessionID)
            data.append(CFSwapInt32HostToBig(bytesInPayload))
            
            if self.version >= 2 {
                data.append(CFSwapInt32HostToBig(messageID))
            }
            
            return data
        } else {
            assert(false, "could not initialize data with capacity \(size)")
        }
    }
    
    init(version: UInt8 = UInt8(SDLGlobals.protocolVersion), type: SDLServiceType = .control, sessionID: UInt8 = 0) {
        _version = version
        if self.version < 2 {
            _size = 8
        } else {
            _size = 12
        }
        
        serviceType = type
        self.sessionID = sessionID
    }
    
    public func parse(_ data: Data) {
        let firstByte = data[0]
        encrypted = (firstByte & 0x08) != 0
        frame.type = SDLFrameType(rawValue: (firstByte & 0x07))!
        serviceType = SDLServiceType(rawValue: data[1])!
        frame.data = data[2]
        sessionID = data[3]
        
        let pointer = UnsafeMutablePointer<UInt32>(allocatingCapacity: size)
        let bytes = UnsafeMutableBufferPointer<UInt32>(start: pointer, count: size)
        _ = data.copyBytes(to: bytes)
        
        bytesInPayload = CFSwapInt32BigToHost(bytes[1])

        if version >= 2 {
            messageID = CFSwapInt32BigToHost(bytes[2])
        }
    }
}

extension SDLProtocolHeader: NSCopying {
    public func copy(with zone: NSZone? = nil) -> AnyObject {
        let header = SDLProtocolHeader(version: self.version, type: self.serviceType, sessionID: self.sessionID)
        header.frame.data = self.frame.data
        header.frame.type = self.frame.type
        header.encrypted = self.encrypted
        header.bytesInPayload = self.bytesInPayload
        header.messageID = self.messageID
        return header
    }
}
