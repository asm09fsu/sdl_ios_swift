//
//  SDLGlobals.swift
//  SmartDeviceLink
//
//  Created by Muller, Alexander (A.) on 6/25/16.
//  Copyright © 2016 SmartDeviceLink. All rights reserved.
//

import Foundation

public class SDLGlobals {
    private static let maxProxyVersion: UInt = 4
    
    private static var _protocolVersion: UInt = 1
    private static var _maxHeadUnitVersion: UInt = 0
    
    public class var protocolVersion: UInt {
        return _protocolVersion
    }
    
    public class var maxMTUSize: UInt {
        switch _protocolVersion {
        case 1, 2:
            return 1024
        case 3, 4:
            if (maxHeadUnitVersion > maxProxyVersion) {
                return 1024
            } else {
                return 131084
            }
        default:
            print("Unknown version number: \(_protocolVersion)")
            return 0
        }
    }
    
    public class var maxHeadUnitVersion: UInt {
        set {
            _protocolVersion = min(newValue, maxProxyVersion)
            self.maxHeadUnitVersion = newValue
        }
        get {
            return self.maxHeadUnitVersion
        }
    }
}
