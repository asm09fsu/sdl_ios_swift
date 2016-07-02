//
//  SDLProtocolMessageInterpreter.swift
//  SmartDeviceLink
//
//  Created by Muller, Alexander (A.) on 6/27/16.
//  Copyright © 2016 SmartDeviceLink. All rights reserved.
//

// In charge of both assembling and disassembling messages
class SDLProtocolMessageInterpreter {
    
    let kFirstFrameIdentifier: Int = -1
    
    var sessionID: UInt8 {
        return _sessionID
    }
    
    private var _sessionID: UInt8 = 0
    private var expectedBytes: UInt32 = 0
    private var frameCount: UInt32 = 0
    
    private var messageParts: [Int: Data]?
    
    init(sessionID: UInt8) {
        _sessionID = sessionID
        messageParts = [Int: Data]()
    }
    
    func assemble(message: SDLProtocolMessage, handler: ((complete: Boolean, message: SDLProtocolMessage) -> Void)?) {
        if message.header.sessionID != sessionID {
            print("Error: message part sent to wrong assembler.")
            return
        }
        
        if messageParts != nil {
            messageParts = [Int: Data]()
        }
        
        if message.header.frame.type == .first {
            
            let pointer = UnsafeMutablePointer<UInt32>(allocatingCapacity: message.size)
            let bytes = UnsafeMutableBufferPointer<UInt32>(start: pointer, count: message.size)
            _ = message.payload?.copyBytes(to: bytes)
            
            
            expectedBytes = CFSwapInt32BigToHost(bytes[0])
            frameCount = CFSwapInt32BigToHost(bytes[1])
            
            messageParts![kFirstFrameIdentifier] = message.payload
            
        } else if message.header.frame.type == .consecutive {
            messageParts![Int(message.header.frame.data.rawValue)] = message.payload
        }
        
        if messageParts!.count == Int(frameCount + 1) {
            let header = message.header
            header.frame.type = .single
            header.frame.data = .control
            
            var payload = Data()
            for frame in 1 ..< frameCount {
                if let data = messageParts![Int(frame)] {
                    payload.append(data)
                }
            }

            if let data = messageParts![0] {
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
            
            messageParts = nil
        }
    }
    
//    class func disassemble(_ message: SDLProtocolMessage, limit: Int) -> [SDLProtocolMessage] {
//        
//    }
}
