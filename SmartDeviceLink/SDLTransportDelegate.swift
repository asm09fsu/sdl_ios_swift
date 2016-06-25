//
//  SDLTransportDelegate.swift
//  SmartDeviceLink
//
//  Created by Muller, Alexander (A.) on 6/16/16.
//  Copyright © 2016 SmartDeviceLink. All rights reserved.
//

import Foundation

public protocol SDLTransportDelegate: class {
    func connected(to transport: SDLTransport)
    func received(_ data: Data?)
}
