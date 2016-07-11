//
//  SDLProtocolMessageDisassemblerSpec.swift
//  SmartDeviceLink
//
//  Created by Muller, Alexander (A.) on 7/7/16.
//  Copyright © 2016 SmartDeviceLink. All rights reserved.
//

import Nimble
import SmartDeviceLink
import Quick

class SDLProtocolMessageDisassemblerSpec : QuickSpec {
    override func spec() {
        describe("Disassemble Tests") {
            beforeEach {
                SDLGlobals.maxHeadUnitVersion = 0
            }
            
            it("Should disassemble the message properly") {
                let dataLength = 2000
                
                let dummyBytes = [UInt8](repeating: 0, count: dataLength)

                SDLGlobals.maxHeadUnitVersion = 2
                
                let bytes: [UInt8] = [0x20, 0x55, 0x64, 0x73, 0x12, 0x34, 0x43, 0x21, UInt8((dataLength >> 24) & 0xFF), UInt8((dataLength >> 16) & 0xFF), UInt8((dataLength >> 8) & 0xFF), UInt8(dataLength & 0xFF)]

                var payload = Data(bytes: bytes)
                payload.append(dummyBytes, count: dataLength)

                let testHeader = SDLProtocolHeader()
                testHeader.frame.type = .single
                testHeader.frame.data = SDLFrameData.singleFrame
                testHeader.serviceType = .bulkData
                testHeader.sessionID = 0x84
                testHeader.bytesInPayload = UInt32(payload.count)
                
                let testMessage = SDLV2ProtocolMessage(header: testHeader, payload: payload)
                
                if let messages = SDLProtocolMessageDisassembler.disassemble(testMessage, limit: SDLGlobals.maxMTUSize) {
                    let payloadLength = 1012
                    
                    let firstPayloadBytes: [UInt8] = [UInt8((payload.count >> 24) & 0xFF), UInt8((payload.count >> 16) & 0xFF), UInt8((payload.count >> 8) & 0xFF), UInt8(payload.count & 0xFF), 0x00, 0x00, 0x00, UInt8(ceil(Double((1.0 * Double(payload.count)) / Double(payloadLength))))]
                    
                    let firstPayload = Data(bytes: firstPayloadBytes)
                    
                    if var message = messages.first {
                        // First Frame
                        expect(message.payload).to(equal(firstPayload))
                        var header = message.header
                        expect(header.frame.type).to(equal(SDLFrameType.first))
                        expect(header.frame.data).to(equal(SDLFrameData.firstFrame))
                        expect(header.serviceType).to(equal(SDLServiceType.bulkData))
                        expect(header.sessionID).to(equal(0x84))
                        expect(header.bytesInPayload).to(equal(8))
                        
                        var offset = 0
                    
                        // Consecutive Frames
                        for index in 1 ..< (messages.count - 1) {
                            message = messages[index]
                            
                            expect(message.payload).to(equal(payload.subdata(in: offset ..< payloadLength)))
                            let header = message.header
                            expect(header.frame.type).to(equal(SDLFrameType.consecutive))
                            expect(header.frame.data).to(equal(UInt8(index)))
                            expect(header.serviceType).to(equal(SDLServiceType.bulkData))
                            expect(header.sessionID).to(equal(0x84))
                            expect(header.bytesInPayload).to(equal(UInt32(payloadLength)))
                            
                            offset += payloadLength
                        }
                        
                        message = messages.last!
                        
                        // Last Frame
                        expect(message.payload).to(equal(payload.subdata(in: offset ..< payload.count)))
                        
                        header = message.header
                        expect(header.frame.type).to(equal(SDLFrameType.consecutive))
                        expect(header.frame.data).to(equal(SDLFrameData.lastConsecutiveFrame))
                        expect(header.serviceType).to(equal(SDLServiceType.bulkData))
                        expect(header.sessionID).to(equal(0x84))
                        expect(header.bytesInPayload).to(equal(UInt32(payload.count - offset)))
                        
                    } else {
                        fail("messages list did not contain any messages")
                    }
                } else {
                    fail("disassembler failed to disassemble.")
                }
            }
        }
    }
}
