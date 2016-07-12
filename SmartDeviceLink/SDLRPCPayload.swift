//
//  SDLRPCPayload.swift
//  SmartDeviceLink
//
//  Created by Muller, Alexander (A.) on 7/12/16.
//  Copyright © 2016 SmartDeviceLink. All rights reserved.
//

import Foundation

enum SDLRPCMessageType: UInt8 {
    case request
    case response
    case notification
}

struct SDLRPCPayload {
    let RPCHeaderSize = 12
    
    var messageType: SDLRPCMessageType = .request
    var functionID: UInt32 = 0
    var correlationID: UInt32 = 0
    var json: Data? = nil
    var binary: Data? = nil
    
    var data: Data {
        var data = Data()
        
        data.append(CFSwapInt32HostToBig(functionID))
        data.append(CFSwapInt32HostToBig(correlationID))
        data.append(CFSwapInt32HostToBig(UInt32(json!.count)))
        
        let messageType = (self.messageType.rawValue & 0x0F) << 4
        data[0] &= 0x0F
        data[0] |= messageType
        
        
        data.append(self.json!)
        data.append(self.binary!)
        
        return data
    }
    
    init?(data: Data) {
        if data.count < RPCHeaderSize {
            print("Error: insfficient data to form RPC header.")
            return
        }
        
        messageType = SDLRPCMessageType(rawValue: (data[0] & 0xF0) >> 4)!
        
        let bytes = data.bufferPointer()

        functionID = CFSwapInt32BigToHost(bytes[0]) & 0x0FFFFFFF
        correlationID = CFSwapInt32BigToHost(bytes[1])
        
        let jsonSize = Int(CFSwapInt32BigToHost(bytes[2]))
        
        if jsonSize > 0 && jsonSize <= data.count - RPCHeaderSize {
            json = data.subdata(in: RPCHeaderSize ..< (RPCHeaderSize + Int(jsonSize)))
        }

        let binarySize = data.count - jsonSize - RPCHeaderSize
        if binarySize > 0 {
            let offset = RPCHeaderSize + jsonSize
            binary = data.subdata(in: offset ..< (offset + binarySize))
        }
    }

    

}
