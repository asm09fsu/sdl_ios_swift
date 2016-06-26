//
//  SDLProxy.swift
//  SmartDeviceLink
//
//  Created by Muller, Alexander (A.) on 6/17/16.
//  Copyright © 2016 SmartDeviceLink. All rights reserved.
//

import Foundation

public class SDLProxy: SDLProtocolListener {
    private let transport: SDLTransport
    private let `protocol`: SDLProtocol
    
    public init(transport: SDLTransport, `protocol`: SDLProtocol) {
        self.transport = transport
        self.`protocol` = `protocol`
        self.`protocol`.transport = self.transport
        self.`protocol`.add(protocolDelegate: self)
        self.transport.delegate = self.`protocol`
        
        self.transport.connectTransport()
    }
    
    public func protocolOpened() {
        print("protocolOpenend")
        `protocol`.startSession(for: .rpc)
    }
    
    public func protocolClosed() {
        print("protocolClosed")        
    }
}
