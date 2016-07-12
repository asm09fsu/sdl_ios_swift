//
//  SDLProtocolMessageDisassembler.swift
//  SmartDeviceLink
//
//  Created by Muller, Alexander (A.) on 7/7/16.
//  Copyright © 2016 SmartDeviceLink. All rights reserved.
//

import Foundation

class SDLProtocolMessageDisassembler {
    class func disassemble(_ message: SDLProtocolMessage, limit: UInt) -> [SDLProtocolMessage]? {
        let headerSize = message.header.size
        
        let payloadSize = message.data!.count - headerSize
        
        let numberOfMessages = Int(ceil(Double(payloadSize) / (Double(limit) - Double(headerSize))))
        
        let bytesPerMessage = Int(limit) - headerSize
        
        var messages = [SDLProtocolMessage]()
        messages.reserveCapacity(numberOfMessages + 1)
        
        let firstFrameHeader = message.header.copy() as! SDLProtocolHeader
        
        firstFrameHeader.frame.type = .first
        
        var firstFramePayload = Data()
        firstFramePayload.append(CFSwapInt32HostToBig(UInt32(message.payload!.count)))
        firstFramePayload.append(CFSwapInt32HostToBig(UInt32(numberOfMessages)))
        
        firstFrameHeader.bytesInPayload = UInt32(firstFramePayload.count)
        
        let firstMessage = SDLProtocolMessage(header: firstFrameHeader, payload: firstFramePayload)
        
        messages.append(firstMessage)
        
        for index in 0 ..< (numberOfMessages - 1) {
            // Frame # after 255 must cycle back to 1, not 0.
            // A 0 signals last frame.
            let frameNumber = (index % 255) + 1
            
            let nextFrameHeader = message.header.copy() as! SDLProtocolHeader
            nextFrameHeader.frame.type = .consecutive
            nextFrameHeader.frame.data = UInt8(frameNumber)
            
            let offset = headerSize + (index * bytesPerMessage)
            
            let nextFramePayload = message.data?.subdata(in: offset ..< (offset + bytesPerMessage))
            nextFrameHeader.bytesInPayload = UInt32(nextFramePayload!.count)
            
            let nextMessage = SDLProtocolMessage(header: nextFrameHeader, payload: nextFramePayload)
            messages.append(nextMessage)
        }

        // Create the last message
        let lastFrameHeader = message.header.copy() as! SDLProtocolHeader
        lastFrameHeader.frame.type = .consecutive
        lastFrameHeader.frame.data = SDLFrameData.lastConsecutiveFrame
        
        let createdMessages = numberOfMessages - 1
        let bytesSent = createdMessages * bytesPerMessage
        let offset = headerSize + bytesSent
        
        let lastFramePayload = message.data?.subdata(in: offset ..< (message.data?.count)!)
        lastFrameHeader.bytesInPayload = UInt32(lastFramePayload!.count)
        
        let lastMessage = SDLProtocolMessage(header: lastFrameHeader, payload: lastFramePayload)
        messages.append(lastMessage)
        
        return messages
    }
}
