//
//  SDLProtocol.swift
//  SmartDeviceLink
//
//  Created by Muller, Alexander (A.) on 6/17/16.
//  Copyright © 2016 SmartDeviceLink. All rights reserved.
//

import Foundation

public protocol SDLProtocolListener {
    func protocolOpened()
    func protocolCloseed()
}

public class SDLProtocol: SDLTransportDelegate {

    public var protocolDelegates: HashTable<AnyObject>
    
    // this is 4 * maxMTUSize
    private var incomingBuffer: Data = Data(capacity: 4 * 131084)!
    
    public init() {
        protocolDelegates = HashTable()
    }
    
    public func add(protocolDelegate: AnyObject) {
        protocolDelegates.add(protocolDelegate)
    }
    
    public func connected(to transport: SDLTransport) {
        for case let listener as SDLProtocolListener in protocolDelegates.allObjects {
            listener.protocolOpened()
        }
    }
    
    public func received(_ data: Data?) {
        if let data = data {
            print("Received \(data.count) bytes: \(data)")
            incomingBuffer.append(data)
            
            processPendingMessages()
        } else {
            print("received empty data")
        }
    }
    
    private func processPendingMessages() {
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
