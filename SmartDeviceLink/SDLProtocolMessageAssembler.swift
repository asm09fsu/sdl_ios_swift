//
//  SDLProtocolMessageAssembler.swift
//  SmartDeviceLink
//
//  Created by Muller, Alexander (A.) on 6/27/16.
//  Copyright © 2016 SmartDeviceLink. All rights reserved.
//

import Foundation

typealias SDLMessageAssemblyCompletionHandler = (complete: Boolean, message: SDLProtocolMessage?) -> Void

class SDLProtocolMessageAssembler {
    
    let FirstFrameIdentifier: Int = -1
    let LastFrameIdentifier: Int = 0
    
    
    var sessionID: UInt8 {
        return _sessionID
    }
    
    private var _sessionID: UInt8 = 0
    private var expectedBytes: UInt32 = 0
    private var frameCount: UInt32 = 0
    
    private var messageParts = [Int: Data]()
    
    init(sessionID: UInt8 = 0) {
        _sessionID = sessionID
    }
    
    func assemble(message: SDLProtocolMessage, handler: SDLMessageAssemblyCompletionHandler? = nil) {
        if message.header.sessionID != sessionID {
            print("Error: message part sent to wrong assembler.")
            return
        }
        
        if message.header.frame.type == .first {
            
            guard let bytes = message.payload?.bufferPointer() else {
                print("Error: could not convert data")
                return
            }

            expectedBytes = CFSwapInt32BigToHost(bytes[0])
            frameCount = CFSwapInt32BigToHost(bytes[1])
            
            messageParts[FirstFrameIdentifier] = message.payload
            
        } else if message.header.frame.type == .consecutive {
            messageParts[Int(message.header.frame.data)] = message.payload
        }
        
        if messageParts.count == Int(frameCount + 1) {
            let header = message.header
            header.frame.type = .single
            header.frame.data = SDLFrameData.singleFrame
            
            var payload = Data()
            for frame in 1 ..< frameCount {
                if let data = messageParts[Int(frame)] {
                    payload.append(data)
                }
            }

            if let data = messageParts[LastFrameIdentifier] {
                payload.append(data)
            }
            
            header.bytesInPayload = UInt32(payload.count)
            if header.bytesInPayload != expectedBytes {
                print("Warning: collected bytes size of \(payload.count) not equal to expected size of \(expectedBytes).")
            }
            
            let message = SDLProtocolMessage(header: header, payload: payload)
            
            if let handler = handler {
                handler(complete: true, message: message)
            }
            
            messageParts.removeAll()
        } else {
            handler?(complete: false, message: nil)
        }
    }
}
