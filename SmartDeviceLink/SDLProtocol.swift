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

public protocol SDLProtocolListener {
    func protocolOpened()
    func protocolCloseed()
}

public class SDLProtocol: SDLTransportDelegate {

    private var protocolDelegates: HashTable<AnyObject>
    
    // this is 4 * maxMTUSize
    private var incomingBuffer: Data = Data(capacity: 4 * 131084)!
    
    private var sendQueue: DispatchQueue
    
    public var transport: SDLTransport?
    
    public init() {
        protocolDelegates = HashTable()
        sendQueue = DispatchQueue(label: "com.sdl.protocol.transmit", attributes: .serial)
    }
    
    public func add(protocolDelegate: AnyObject) {
        protocolDelegates.add(protocolDelegate)
    }
    
    public func startSession(for type: SDLServiceType) {
        send(data: Data(bytes: [0x10, 0x07, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00]), for: type)
    }
    
    public func send(data: Data, for service: SDLServiceType) {
        sendQueue.async { 
            self.transport!.send(data: data)
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
}
