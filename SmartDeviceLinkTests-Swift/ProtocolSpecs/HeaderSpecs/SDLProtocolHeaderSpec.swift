//
//  SDLProtocolHeaderSpec.swift
//  SmartDeviceLink
//
//  Created by Muller, Alexander (A.) on 7/11/16.
//  Copyright © 2016 SmartDeviceLink. All rights reserved.
//

import Nimble
import SmartDeviceLink
import Quick

class SDLProtocolHeaderSpec: QuickSpec {
    override func spec() {
        var header: SDLProtocolHeader?
        var testData: Data?
        
        describe("SDLProtocolHeader Version 1") {
            
            beforeEach {
                header = SDLProtocolHeader(version: 1)
                header!.encrypted = true
                header!.frame.type = .control
                header!.serviceType = .rpc
                header!.frame.data = SDLFrameData.startSession
                header!.sessionID = 0x53
                header!.bytesInPayload = 0x1234
                
                let testBytes: [UInt8] = [0x18 | (SDLFrameType.control.rawValue & 0xFF), SDLServiceType.rpc.rawValue, SDLFrameData.startSession, 0x53, 0x00, 0x00, 0x12, 0x34]
                testData = Data(bytes: testBytes)
            }
            
            context("Getter/Setter Tests") {
                it("Should get readonly values correctly") {
                    expect(header!.version).to(equal(1))
                    expect(header!.size).to(equal(8))
                }
                
                it("Should set and get correctly") {
                    expect(header!.encrypted).to(beTruthy())
                    expect(header!.frame.type).to(equal(SDLFrameType.control))
                    expect(header!.serviceType).to(equal(SDLServiceType.rpc))
                    expect(header!.frame.data).to(equal(SDLFrameData.startSession))
                    expect(header!.sessionID).to(equal(0x53))
                    expect(header!.bytesInPayload).to(equal(0x1234))
                    expect(header!.messageID).to(equal(0))
                }
            }
            
            context("Copy Tests") {
                it("Should copy correctly") {
                    let headerCopy = header!.copy() as! SDLProtocolHeader
                    
                    expect(headerCopy.version).to(equal(1))
                    expect(headerCopy.encrypted).to(beTruthy())
                    expect(headerCopy.frame.type).to(equal(SDLFrameType.control))
                    expect(headerCopy.serviceType).to(equal(SDLServiceType.rpc))
                    expect(headerCopy.frame.data).to(equal(SDLFrameData.startSession))
                    expect(headerCopy.sessionID).to(equal(0x53))
                    expect(headerCopy.bytesInPayload).to(equal(0x1234))
                    expect(headerCopy.messageID).to(equal(0))

                    expect(headerCopy).toNot(beIdenticalTo(header))
                 }
            }
            
            context("Data Tests") {
                it("Should convert to byte data correctly") {
                    expect(header!.data).to(equal(testData!))
                }
            }
            
            context("RPC Payload Data Test") {
                it("Should convert from byte data correctly") {
                    let constructedHeader = SDLProtocolHeader(version: 1)
                    constructedHeader.parse(testData!)
                    
                    expect(constructedHeader.version).to(equal(1))
                    expect(constructedHeader.encrypted).to(beTruthy())
                    expect(constructedHeader.frame.type).to(equal(SDLFrameType.control))
                    expect(constructedHeader.serviceType).to(equal(SDLServiceType.rpc))
                    expect(constructedHeader.frame.data).to(equal(SDLFrameData.startSession))
                    expect(constructedHeader.sessionID).to(equal(0x53))
                    expect(constructedHeader.bytesInPayload).to(equal(0x1234))
                    expect(constructedHeader.messageID).to(equal(0))
                }
            }
        }
        
        describe("SDLProtocolHeader Version 2+") {
            beforeEach {
                header = SDLProtocolHeader(version: 2)
                header!.encrypted = true
                header!.frame.type = .control
                header!.serviceType = .rpc
                header!.frame.data = SDLFrameData.startSession
                header!.sessionID = 0x53
                header!.bytesInPayload = 0x1234
                header!.messageID = 0x6DAB424F
                
                let testBytes: [UInt8] = [0x28 | (SDLFrameType.control.rawValue & 0xFF), SDLServiceType.rpc.rawValue, SDLFrameData.startSession, 0x53, 0x00, 0x00, 0x12, 0x34, 0x6D, 0xAB, 0x42, 0x4F]
                testData = Data(bytes: testBytes)
            }
            
            context("Getter/Setter Tests") {
                it("Should get readonly values correctly") {
                    expect(header!.version).to(equal(2))
                    expect(header!.size).to(equal(12))
                }
                
                it("Should set and get correctly") {
                    expect(header!.encrypted).to(beTruthy())
                    expect(header!.frame.type).to(equal(SDLFrameType.control))
                    expect(header!.serviceType).to(equal(SDLServiceType.rpc))
                    expect(header!.frame.data).to(equal(SDLFrameData.startSession))
                    expect(header!.sessionID).to(equal(0x53))
                    expect(header!.bytesInPayload).to(equal(0x1234))
                    expect(header!.messageID).to(equal(0x6DAB424F))
                }
            }
            
            context("Copy Tests") {
                it("Should copy correctly") {
                    let headerCopy = header!.copy() as! SDLProtocolHeader
                    
                    expect(headerCopy.version).to(equal(2))
                    expect(headerCopy.encrypted).to(beTruthy())
                    expect(headerCopy.frame.type).to(equal(SDLFrameType.control))
                    expect(headerCopy.serviceType).to(equal(SDLServiceType.rpc))
                    expect(headerCopy.frame.data).to(equal(SDLFrameData.startSession))
                    expect(headerCopy.sessionID).to(equal(0x53))
                    expect(headerCopy.bytesInPayload).to(equal(0x1234))
                    expect(headerCopy.messageID).to(equal(0x6DAB424F))
                    
                    expect(headerCopy).toNot(beIdenticalTo(header))
                }
            }
            
            context("Data Tests") {
                it("Should convert to byte data correctly") {
                    expect(header!.data).to(equal(testData!))
                }
            }
            
            context("RPC Payload Data Test") {
                it("Should convert from byte data correctly") {
                    let constructedHeader = SDLProtocolHeader(version: 2)
                    constructedHeader.parse(testData!)
                    
                    expect(constructedHeader.version).to(equal(2))
                    expect(constructedHeader.encrypted).to(beTruthy())
                    expect(constructedHeader.frame.type).to(equal(SDLFrameType.control))
                    expect(constructedHeader.serviceType).to(equal(SDLServiceType.rpc))
                    expect(constructedHeader.frame.data).to(equal(SDLFrameData.startSession))
                    expect(constructedHeader.sessionID).to(equal(0x53))
                    expect(constructedHeader.bytesInPayload).to(equal(0x1234))
                    expect(constructedHeader.messageID).to(equal(0x6DAB424F))
                }
            }
        }
    }
}
