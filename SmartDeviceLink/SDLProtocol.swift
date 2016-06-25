//
//  SDLProtocol.swift
//  SmartDeviceLink
//
//  Created by Muller, Alexander (A.) on 6/17/16.
//  Copyright © 2016 SmartDeviceLink. All rights reserved.
//

import Foundation

public enum SDLServiceType: UInt8 {
    case control = 0x00
    case rpc = 0x07
    case audio = 0x0A
    case video = 0x0B
    case bulkData = 0x0F
}

public enum SDLFrameData: UInt8 {
    case control = 0x00
    case startSession = 0x01
    case startSessionACK = 0x02
    case startSessionNACK = 0x03
    case endSession = 0x04
    case endSessionACK = 0x05
    case endSessionNACK = 0x06
    case serviceDataACK = 0xFE
    case heartbeatACK = 0xFF
}

public enum SDLFrameType: UInt8 {
    case control = 0x00
    case single = 0x01
    case first = 0x02
    case consecutive = 0x03
}

public protocol SDLProtocolListener {
    func protocolOpened()
    func protocolCloseed()
}

public class SDLProtocol: SDLTransportDelegate {

    private var protocolDelegates = HashTable<AnyObject>()
    private var incomingBuffer: Data = Data(capacity: 4 * Int(SDLGlobals.maxMTUSize))!
    private var sendQueue = DispatchQueue(label: "com.sdl.protocol.transmit", attributes: .serial)
    private var sessionIDs = Dictionary<SDLServiceType, UInt8>()
    private var currentSessionID: UInt8 = 0

    public var transport: SDLTransport?
    
    public init() { }
    
    public func add(protocolDelegate: AnyObject) {
        protocolDelegates.add(protocolDelegate)
    }
    
    public func startSession(for type: SDLServiceType) {
        if let header = SDLProtocolHeader.header(for: type, sessionID: sdl_getSessionID(for: type)),
            let message = SDLProtocolMessage.message(with: header)  {
                send(data: message.data, for: type)
        }
    }
    
    public func send(data: Data?, for service: SDLServiceType) {
        if let data = data {
            sendQueue.async {
                self.transport!.send(data: data)
            }
        }
    }
    
    // MARK: SDLTransportDelegate
    public func connected(to transport: SDLTransport) {
        for case let listener as SDLProtocolListener in protocolDelegates.allObjects {
            listener.protocolOpened()
        }
    }
    
    public func received(_ data: Data?) {
        if let data = data {
            print("Received \(data.count) bytes: \(data)")
            incomingBuffer.append(data)
            
            sdl_processPendingMessages()
        } else {
            print("received empty data")
        }
    }
    
    // MARK: Private Functions
    private func sdl_processPendingMessages() {
        let incomingVersion = SDLProtocolMessage.version(from: incomingBuffer)
        
        if let header = SDLProtocolHeader.header(for: incomingVersion) {
            if Int(header.size) < incomingBuffer.count {
                header.parse(incomingBuffer)
            } else {
                return
            }
        } else {
            return
        }
    }
    
    private func sdl_getSessionID(for type: SDLServiceType) -> UInt8 {
        if let id = sessionIDs[type] {
            return id
        } else {
            print("Warning: Tried to retrieve sessionID for serviceType \(type), but no sessionID is saved for that service type.")
            return 0
        }
    }
}
