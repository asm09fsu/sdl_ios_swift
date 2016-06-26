//
//  SDLGlobalsSpec.swift
//  SmartDeviceLink
//
//  Created by Muller, Alexander (A.) on 6/26/16.
//  Copyright © 2016 SmartDeviceLink. All rights reserved.
//

import Quick
import Nimble
import SmartDeviceLink

class SDLGlobalsSpec: QuickSpec {
    override func spec() {
        describe("The SDLGlobals class") { 
            let v1And2MTUSize: UInt = 1024
            let v3And4MTUSize: UInt = 131084
            
            describe("when just initialized") {
                it("should properly set protocol version") {
                    expect(SDLGlobals.protocolVersion).to(equal(1))
                }
                it("should properly set max head unit version") {
                    expect(SDLGlobals.maxHeadUnitVersion).to(equal(0))
                }
                it("should properly set max MTU size") {
                    expect(SDLGlobals.maxMTUSize).to(equal(v1And2MTUSize))
                }
            }
            
            describe("setting max head unit version should alter negotiated protocol version") {
                it("should use the max head unit version when lower than max proxy version") {
                    let someIntLowerThanMaxProxyVersion: UInt = 2
                    SDLGlobals.maxHeadUnitVersion = someIntLowerThanMaxProxyVersion
                    expect(SDLGlobals.protocolVersion).to(equal(someIntLowerThanMaxProxyVersion))
                    expect(SDLGlobals.maxHeadUnitVersion).to(equal(someIntLowerThanMaxProxyVersion))
                }
                it("should use the max proxy version when lower than max head unit version") {
                    let someIntHigherThanMaxProxyVersion: UInt = 1000
                    SDLGlobals.maxHeadUnitVersion = someIntHigherThanMaxProxyVersion
                    expect(SDLGlobals.protocolVersion).to(beLessThan(someIntHigherThanMaxProxyVersion))
                    expect(SDLGlobals.maxHeadUnitVersion).to(equal(someIntHigherThanMaxProxyVersion))
                }
            }
            
            describe("getting the max MTU size") {
                context("when protocol version is 1 - 2") {
                    it("should return the correct value when protocol version is 1") {
                        SDLGlobals.maxHeadUnitVersion = 1
                        expect(SDLGlobals.maxMTUSize).to(equal(v1And2MTUSize))
                    }
                    it("should return the correct value when protocol version is 2") {
                        SDLGlobals.maxHeadUnitVersion = 2
                        expect(SDLGlobals.maxMTUSize).to(equal(v1And2MTUSize))
                    }
                }
                context("when protocol version is 3 - 4") {
                    it("should return the correct value when protocol version is 3") {
                        SDLGlobals.maxHeadUnitVersion = 3
                        expect(SDLGlobals.maxMTUSize).to(equal(v3And4MTUSize))
                    }
                    it("should return the correct value when protocol version is 4") {
                        SDLGlobals.maxHeadUnitVersion = 4
                        expect(SDLGlobals.maxMTUSize).to(equal(v3And4MTUSize))
                    }
                    describe("when the max proxy version is lower than max head unit version") {
                        beforeEach {
                            let someIntHigherThanMaxProxyVersion: UInt = 1000
                            SDLGlobals.maxHeadUnitVersion = someIntHigherThanMaxProxyVersion
                        }
                        it("should return the v1 - 2 value") {
                            expect(SDLGlobals.maxMTUSize).to(equal(v1And2MTUSize))
                        }
                    }
                }
            }
        }
    }
}
