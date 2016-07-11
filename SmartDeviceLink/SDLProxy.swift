//
//  SDLProxy.swift
//  SmartDeviceLink
//
//  Created by Muller, Alexander (A.) on 6/17/16.
//  Copyright © 2016 SmartDeviceLink. All rights reserved.
//

import Foundation

public class SDLProxy {
    private let transport: SDLTransport
    private let `protocol`: SDLProtocol
    
    public init(transport: SDLTransport, `protocol`: SDLProtocol) {
        self.transport = transport
        self.`protocol` = `protocol`
        self.`protocol`.transport = self.transport
        self.`protocol`.add(protocolDelegate: self)
        self.`protocol`.add(messagesDelegate: self)
        self.transport.delegate = self.`protocol`
        
        self.transport.connectTransport()
    }
}

// MARK: SDLProtocolListener
extension SDLProxy: SDLProtocolListener {
    public func protocolOpened() {
        print("protocolOpenend")
        `protocol`.startSession(for: .rpc)
    }
    
    public func protocolClosed() {
        print("protocolClosed")
    }
}

// MARK: SDLMessageRouterProtocol
extension SDLProxy: SDLMessageRouterProtocol {
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
}
