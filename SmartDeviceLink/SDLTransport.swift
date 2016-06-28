//
//  SDLTransport.swift
//  SmartDeviceLink
//
//  Created by Muller, Alexander (A.) on 6/16/16.
//  Copyright © 2016 SmartDeviceLink. All rights reserved.
//

import Foundation

public class SDLTransport {
    public weak var delegate: SDLTransportDelegate? = nil
    var retryDelay: Double = 0.0

    
    // we cannot use connect() because of an issue with c-based connect() function
    func connectTransport() { }
    func disconnect() { }
    func send(_ data: Data) { }
    func cleanUp() { }
}
