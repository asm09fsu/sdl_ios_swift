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
    func protocolClosed()
}

public class SDLProtocol: SDLTransportDelegate, SDLMessageRouterProtocol {

    private var protocolDelegates = HashTable<AnyObject>()
    private var incomingBuffer: Data = Data(capacity: 4 * Int(SDLGlobals.maxMTUSize))!
    private var messageRouter = SDLProtocolMessageRouter()
    private var receiveQueue = DispatchQueue(label: "com.sdl.protocol.receive", attributes: .serial)
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
        // we cannot do this in init because of self.init
        if messageRouter.delegate == nil {
            messageRouter.delegate = self
        }
        
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
    
    // MARK: SDLMessageRouterProtocol
    func handleProtocolStartSessionACK(for type: SDLServiceType, sessionID: UInt8, version: UInt8) {
        print("handleProtocolStartSessionACK")
    }
    
    func handleProtocolStartSessionNACK(for type: SDLServiceType) {
        print("handleProtocolStartSessionNACK")
    }
    
    func handleProtocolEndSessionACK(for type: SDLServiceType) {
        print("handleProtocolEndSessionACK")
    }
    
    func handleProtocolEndSessionNACK(for type: SDLServiceType) {
        print("handleProtocolEndSessionNACK")
    }
    
    func handleHeartbeat(for sessionID: UInt8) {
        print("handleHeartbeat")
    }
    
    func handleHeartbeatACK() {
        print("handleHeartbeatACK")
    }
    
    func protocolReceived(message: SDLProtocolMessage) {
        print("protocolReceived")
    }
    
    // MARK: Private Functions
    private func sdl_processPendingMessages() {
        let incomingVersion = SDLProtocolMessage.version(from: incomingBuffer)
        
        if let header = SDLProtocolHeader.header(for: incomingVersion) {
            if header.size < incomingBuffer.count {
                header.parse(incomingBuffer)
            } else {
                return
            }
            
            let messageSize = header.size + Int(header.bytesInPayload)
            var message: SDLProtocolMessage
            if messageSize < incomingBuffer.count {
                let offset = header.size
                let size = Int(header.bytesInPayload)
                let payload = incomingBuffer.subdata(in: offset ..< (size + offset))
                message = SDLProtocolMessage(header: header, payload: payload)
                print("message complete.")
            } else {
                print("header complete. message incomplete, waiting for \(messageSize - incomingBuffer.count) more bytes.")
                return
            }
            
            incomingBuffer = incomingBuffer.subdata(in: message.size ..< incomingBuffer.count)
            
            receiveQueue.async {
                self.messageRouter.handle(message)
            }
            
            if incomingBuffer.count > 0 {
                sdl_processPendingMessages()
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
