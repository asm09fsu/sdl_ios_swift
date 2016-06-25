//
//  SDLV1ProtocolHeader.swift
//  SmartDeviceLink
//
//  Created by Muller, Alexander (A.) on 6/25/16.
//  Copyright © 2016 SmartDeviceLink. All rights reserved.
//

import Foundation

public class SDLV1ProtocolHeader: SDLProtocolHeader {
    convenience init() {
        self.init(size: 8, version: 1)
    }
    
    public override func parse(_ buffer: Data) {
        
    }
}
