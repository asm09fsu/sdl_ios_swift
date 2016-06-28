//
//  SDLDataPriorityQueue.swift
//  SmartDeviceLink
//
//  Created by Muller, Alexander (A.) on 6/27/16.
//  Copyright © 2016 SmartDeviceLink. All rights reserved.
//

import Foundation

class SDLDataPriorityQueue {
    private var objects = [SDLDataPriorityObject]()
    
    var count: Int {
        return objects.count
    }
    
    func add(_ data:Data, priority: SDLServiceType) {
        objects.append(SDLDataPriorityObject(data: data, priority: priority.rawValue))
        
        var index = objects.count - 2
        while index >= 0 && objects[index].priority > objects[index + 1].priority {
                swap(&objects[index], &objects[index + 1])
                index -= 1
        }
    }
    
    func pop() -> Data? {
        if objects.count > 0 {
            let first = objects.removeFirst()
            return first.data
        } else {
            return nil
        }
    }
}

private class SDLDataPriorityObject {
    var data: Data
    var priority: UInt8
    
    init(data: Data, priority: UInt8) {
        self.data = data
        self.priority = priority
    }
}
