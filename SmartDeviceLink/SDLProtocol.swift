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

public struct SDLFrameData {
    public static let heartbeat: UInt8 = 0x00
    public static let startSession: UInt8 = 0x01
    public static let startSessionACK: UInt8 = 0x02
    public static let startSessionNACK: UInt8 = 0x03
    public static let endSession: UInt8 = 0x04
    public static let endSessionACK: UInt8 = 0x05
    public static let endSessionNACK: UInt8 = 0x06
    public static let serviceDataACK: UInt8 = 0xFE
    public static let heartbeatACK: UInt8 = 0xFF

    public static let singleFrame: UInt8 = 0x00
    public static let firstFrame: UInt8 = 0x00
    public static let lastConsecutiveFrame: UInt8 = 0x00
    
    
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

public class SDLProtocol {

    private var protocolDelegates = HashTable<AnyObject>()
    private var messageDelegates = HashTable<AnyObject>()
    private var incomingBuffer: Data = Data(capacity: 4 * Int(SDLGlobals.maxMTUSize))!
    private var messageRouter = SDLProtocolMessageRouter()
    private var dataPriorityQueue = SDLDataPriorityQueue()
    private var receiveQueue = DispatchQueue(label: "com.sdl.protocol.receive", attributes: .serial)
    private var sendQueue = DispatchQueue(label: "com.sdl.protocol.transmit", attributes: .serial)
    private var sessionIDs = Dictionary<SDLServiceType, UInt8>()
    private var currentSessionID: UInt8 = 0

    public var transport: SDLTransport?
    
    public init() { }
    
    public func add(protocolDelegate: AnyObject) {
        protocolDelegates.add(protocolDelegate)
    }
    
    public func add(messagesDelegate: AnyObject) {
        messageDelegates.add(messagesDelegate)
    }
    
    public func startSession(for type: SDLServiceType) {
        let header = SDLProtocolHeader(type: type, sessionID: sdl_getSessionID(for: type))
        if let message = SDLProtocolMessage.message(with: header)  {
            send(data: message.data, for: type)
        }
    }
    
    public func send(data: Data?, for service: SDLServiceType) {
        // we cannot do this in init because of self.init
        if messageRouter.delegate == nil {
            messageRouter.delegate = self
        }
        
        if let data = data {
            dataPriorityQueue.add(data, priority: service)
    
            sendQueue.async {
                while let currentData = self.dataPriorityQueue.pop() {
                    self.transport!.send(currentData)
                }
            }
        }
    }
    
    // MARK: Private Functions
    private func sdl_processPendingMessages() {
        let incomingVersion = SDLProtocolMessage.version(from: incomingBuffer)

        let header = SDLProtocolHeader(version: incomingVersion)
        if header.size <= incomingBuffer.count {
            header.parse(incomingBuffer)
        } else {
            return
        }
        
        let messageSize = header.size + Int(header.bytesInPayload)
        var message: SDLProtocolMessage
        if messageSize <= incomingBuffer.count {
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
    }
    
    private func sdl_getSessionID(for type: SDLServiceType) -> UInt8 {
        if let id = sessionIDs[type] {
            return id
        } else {
            print("Warning: Tried to retrieve sessionID for serviceType \(type), but no sessionID is saved for that service type.")
            return 0
        }
    }
    
    private func sdl_setSessionID(_ sessionID: UInt8, for type: SDLServiceType) {
        sessionIDs[type] = sessionID
    }
    
    private func sdl_performOnProtocolListeners(block: (listener: SDLProtocolListener) -> Void) {
        for case let listener as SDLProtocolListener in protocolDelegates.allObjects {
            block(listener: listener)
        }
    }
    
    private func sdl_performOnMessageRouterListeners(block: (listener: SDLMessageRouterProtocol) -> Void) {
        for case let listener as SDLMessageRouterProtocol in messageDelegates.allObjects {
            block(listener: listener)
        }
    }
}

// MARK: SDLTransportDelegate
extension SDLProtocol: SDLTransportDelegate {
    public func connected(to transport: SDLTransport) {
        sdl_performOnProtocolListeners { (listener) in
            listener.protocolOpened()
        }
    }
    
    public func disconnected(from transport: SDLTransport) {
        sdl_performOnProtocolListeners { (listener) in
            listener.protocolClosed()
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
}

// MARK: SDLMessageRouterProtocol
extension  SDLProtocol: SDLMessageRouterProtocol {
    func handleProtocolStartSessionACK(for type: SDLServiceType, sessionID: UInt8, version: UInt8) {
        switch type {
        case .rpc:
            currentSessionID = sessionID
            SDLGlobals.maxHeadUnitVersion = UInt(version)
            break
        default:
            break
        }
        
        sdl_setSessionID(sessionID, for: type)
        
        sdl_performOnMessageRouterListeners { (listener) in
            listener.handleProtocolStartSessionACK(for: type,
                                                   sessionID: sessionID,
                                                   version: version)
        }
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
}
