//
//  SDLProtocolMessageRouter.swift
//  SmartDeviceLink
//
//  Created by Muller, Alexander (A.) on 6/25/16.
//  Copyright © 2016 SmartDeviceLink. All rights reserved.
//

import Foundation

protocol SDLMessageRouterProtocol {
    func handleProtocolStartSessionACK(for type: SDLServiceType, sessionID: UInt8, version: UInt8)
    func handleProtocolStartSessionNACK(for type: SDLServiceType)
    func handleProtocolEndSessionACK(for type: SDLServiceType)
    func handleProtocolEndSessionNACK(for type: SDLServiceType)
    func handleHeartbeat(for sessionID: UInt8)
    func handleHeartbeatACK()
    func protocolReceived(message: SDLProtocolMessage)

}

class SDLProtocolMessageRouter {
    var delegate: SDLMessageRouterProtocol?
    
    private var interpreters = [UInt8 : SDLProtocolMessageAssembler]()
    
    init() { }
    
    func handle(_ message: SDLProtocolMessage) {
        switch message.header.frame.type {
        case .control:
            dispatchControlMessage(for: message)
            break
        case .single:
            dispatchProtocolMessage(for: message)
            break
        case .first, .consecutive:
            dispatchMultiPartMessage(for: message)
            break
        }
    }
        
    private func dispatchControlMessage(for message: SDLProtocolMessage) {
        switch message.header.frame.data {
        case SDLFrameData.heartbeat:
            delegate?.handleHeartbeat(for: message.header.sessionID)
            break
        case SDLFrameData.heartbeatACK:
            delegate?.handleHeartbeatACK()
            break
        case SDLFrameData.startSessionACK:
            delegate?.handleProtocolStartSessionACK(for: message.header.serviceType,
                                                    sessionID: message.header.sessionID,
                                                    version: message.header.version)
            break
        case SDLFrameData.startSessionNACK:
            delegate?.handleProtocolStartSessionNACK(for: message.header.serviceType)
            break
        case SDLFrameData.endSessionACK:
            delegate?.handleProtocolEndSessionACK(for: message.header.serviceType)
            break
        case SDLFrameData.endSessionNACK:
            delegate?.handleProtocolEndSessionNACK(for: message.header.serviceType)
            break
        default:
            break
        }
    }

    private func dispatchMultiPartMessage(for message: SDLProtocolMessage) {
        var interpreter = interpreters[message.header.sessionID]
        
        if interpreter == nil {
            interpreter = SDLProtocolMessageAssembler(sessionID: message.header.sessionID)
            interpreters[message.header.sessionID] = interpreter
        }
        
        interpreter?.assemble(message: message) { (complete, message) in
            if complete {
                self.dispatchProtocolMessage(for: message!)
            }
        }
    }

    private func dispatchProtocolMessage(for message: SDLProtocolMessage) {
        delegate?.protocolReceived(message: message)
    }
}
