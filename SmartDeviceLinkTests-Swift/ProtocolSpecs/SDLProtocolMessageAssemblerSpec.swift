//
//  SDLProtocolMessageAssemblerSpec.swift
//  SmartDeviceLink
//
//  Created by Muller, Alexander (A.) on 7/2/16.
//  Copyright © 2016 SmartDeviceLink. All rights reserved.
//

import Nimble
import SmartDeviceLink
import Quick

class SDLProtocolMessageAssemblerSpec: QuickSpec {
    override func spec() {
        describe("handle message tests") {
            it("should assemble the message properly") {
                let dataLength = 2000
                
                let dummyBytes = [UInt8](repeating: 0, count: dataLength)
                
                let bytes: [UInt8] = [0x20, 0x55, 0x64, 0x73, 0x12, 0x34, 0x43, 0x21, UInt8((dataLength >> 24) & 0xFF), UInt8((dataLength >> 16) & 0xFF), UInt8((dataLength >> 8) & 0xFF), UInt8(dataLength & 0xFF)]
                
                var payload = Data(bytes: bytes)
                payload.append(dummyBytes, count: dataLength)
                
                let testHeader = SDLProtocolHeader()
                
                testHeader.frame.type = .first
                testHeader.frame.data = SDLFrameData.startSession
                testHeader.serviceType = .bulkData
                testHeader.sessionID = 0x16
                testHeader.bytesInPayload = 8
                
                let firstPayloadBytes: [UInt8] = [UInt8((dataLength >> 24) & 0xFF), UInt8((dataLength >> 16) & 0xFF), UInt8((dataLength >> 8) & 0xFF), UInt8(dataLength & 0xFF), 0x00, 0x00, 0x00, UInt8(ceil(Double(dataLength) / 500.0))]
                
                let firstPayload = Data(bytes: firstPayloadBytes)
                
                let testMessage = SDLV2ProtocolMessage(header: testHeader, payload: firstPayload)
                
                let interpreter = SDLProtocolMessageAssembler(sessionID: 0x16)
                
                var verified = false
                
                let incompleteHandler: SDLMessageAssemblyCompletionHandler = { (complete: Boolean, message: SDLProtocolMessage?) in
                    verified = true
                    
                    expect(complete).to(beFalsy())
                    expect(message).to(beNil())
                }
                
                interpreter.assemble(message: testMessage, handler: incompleteHandler)
                
                expect(verified).to(beTruthy())
                verified = false
                
                testMessage.header.frame.type = .consecutive
                testMessage.header.bytesInPayload = 500
                
                var frameNumber: UInt8 = 1
                var offset = 0
                
                while (offset + 500) < dataLength {
                    testMessage.header.frame.data = frameNumber
                    testMessage.payload = payload.subdata(in: offset ..< (offset + 500))
                    
                    interpreter.assemble(message: testMessage, handler: incompleteHandler)
                    
                    expect(verified).to(beTruthy())
                    verified = false
                    
                    frameNumber += 1
                    offset += 500
                    
                }
                
                testMessage.header.frame.data = SDLFrameData.singleFrame
                testMessage.payload = payload.subdata(in: offset ..< dataLength)
                
                interpreter.assemble(message: testMessage) { (complete, message) in
                    verified = true
                    
                    expect(complete).to(beTruthy())
                    
                    expect(message!.header.frame.type).to(equal(SDLFrameType.single))
                    expect(message!.header.frame.data).to(equal(SDLFrameData.singleFrame))
                    expect(message!.header.serviceType).to(equal(SDLServiceType.bulkData))
                    expect(message!.header.sessionID).to(equal(0x16))
                    expect(message!.header.bytesInPayload).to(equal(UInt32(dataLength)))
                }
                
                expect(verified).to(beTruthy())
            }
        }
    }
}
