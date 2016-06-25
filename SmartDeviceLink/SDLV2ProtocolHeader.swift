//
//  SDLV2ProtocolHeader.swift
//  SmartDeviceLink
//
//  Created by Muller, Alexander (A.) on 6/25/16.
//  Copyright © 2016 SmartDeviceLink. All rights reserved.
//

import Foundation

public class SDLV2ProtocolHeader: SDLProtocolHeader {
    convenience init(version: UInt8) {
        self.init(size: 8, version: version)
    }
    
}
