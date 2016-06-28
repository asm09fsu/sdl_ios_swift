//
//  SDLDataPriorityQueueSpec.swift
//  SmartDeviceLink
//
//  Created by Muller, Alexander (A.) on 6/27/16.
//  Copyright © 2016 SmartDeviceLink. All rights reserved.
//

import Nimble
import Quick
import SmartDeviceLink

class SDLDataPriorityQueueSpec: QuickSpec {
    override func spec() {
        describe("A Data Priority Queue") {
            var collection = SDLDataPriorityQueue()
            
            beforeEach {
                collection = SDLDataPriorityQueue()
            }
            
            it("should be empty when first created") {
                expect(collection.count).to(equal(0))
            }
            
            it("should be able to add and retrieve a single item") {
                let data = Data(bytes: [0x01])
                collection.add(data, priority: .control)
                
                let returnData = collection.pop()!
                
                expect(returnData).to(equal(data))
            }
            
            describe("should retrieve higher priority objects first") {
                let control = Data(bytes: [0x01])
                let rpc = Data(bytes: [0x02])
                let audio = Data(bytes: [0x03])
                
                var first: Data?
                var second: Data?
                var third: Data?
                
                beforeEach {
                    collection.add(rpc, priority: .rpc)
                    collection.add(audio, priority: .audio)
                    collection.add(control, priority: .control)
                
                    first = collection.pop()!
                    second = collection.pop()!
                    third = collection.pop()!
                }
                
                it("should retrieve the highest priority first") {
                    expect(first).to(equal(control))
                }
                
                it("should retrieve the medium priority second") {
                    expect(second).to(equal(rpc))
                }

                it("should retrieve the lowest priority last") {
                    expect(third).to(equal(audio))
                }

            }
        }
    }
}
