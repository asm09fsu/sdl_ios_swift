//
//  SDLDataPriorityObjectSpec.swift
//  SmartDeviceLink
//
//  Created by Muller, Alexander (A.) on 6/27/16.
//  Copyright © 2016 SmartDeviceLink. All rights reserved.
//

import Nimble
import Quick
import SmartDeviceLink

class SDLDataPriorityObjectSpec: QuickSpec {
    override func spec() {
        describe("a prioritized object") {
            var testObject: SDLDataPriorityObject?
            
            describe("should store an object properly") {
                let data = Data(bytes: [0x01])
                
                testObject = SDLDataPriorityObject(data: data, priority: 100)
                
                it("should store the data") {
                    expect(testObject!.data).to(equal(data))
                }
                
                it("should set the priority as specified") {
                    expect(testObject!.priority).to(equal(100))
                }
            }
            
        }
    }
}
