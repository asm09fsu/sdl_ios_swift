//
//  SDLTCPTransport.swift
//  SmartDeviceLink
//
//  Created by Muller, Alexander (A.) on 6/16/16.
//  Copyright © 2016 SmartDeviceLink. All rights reserved.
//

import Foundation

public class SDLTCPTransport: SDLTransport {
    var host = "127.0.0.1"
    var port = "12345"
    
    // Cannot use socket because of socket() function causing bug in Swift 3 beta
    private var socketObj: CFSocket? = nil
    private var alreadyDestructed = false
    private var sendQueue: DispatchQueue
    
    override public init() {
        sendQueue = DispatchQueue(label: "com.sdl.transport.tcp.transmit", attributes: .serial)
    }
    
    override public func connectTransport() {
        let socketId = openSocket(host: host, port: port)
        
        if socketId < 0 {
            print("failure opening socket")
            return
        }
        
        var context = CFSocketContext(version: 0,
                                      info: UnsafeMutablePointer(OpaquePointer(bitPattern: .passRetained(self))),
                                      retain: nil,
                                      release: nil,
                                      copyDescription: nil)
        
        
        
        socketObj = CFSocketCreateWithNative(kCFAllocatorDefault, socketId, CFSocketCallBackType.connectCallBack.rawValue | CFSocketCallBackType.dataCallBack.rawValue, socketCallback, &context)
        
        let currentRunLoop = RunLoop.current().getCFRunLoop()
        if let source = CFSocketCreateRunLoopSource(kCFAllocatorDefault, socketObj, 0) {
            CFRunLoopAddSource(currentRunLoop, source, .defaultMode)
        } else {
            print("error")
        }
    }
    
    override public func disconnect() {
        if socketObj != nil && CFSocketIsValid(socketObj) {
            CFSocketInvalidate(socketObj)
            socketObj = nil
        }
    }

    override public func send(data: Data) {
        sendQueue.async { 
            autoreleasepool {
                let error = CFSocketSendData(self.socketObj, nil, data as CFData, 10000)
                if error != .success {
                    var errorMessage = ""
                    switch error {
                    case .timeout:
                        errorMessage = "Socket Timeout"
                        break
                    case .error:
                        errorMessage = "Socket Error"
                    default: break
                    }
                    
                    print(errorMessage)
                } else {
                    print("Sent \(data.count) bytes: \(data)")
                }
            }
        }
    }
    
    private func openSocket(host: String?, port: String?) -> Int32 {
        var hints = addrinfo(ai_flags: 0,
                             ai_family: AF_UNSPEC,
                             ai_socktype: SOCK_STREAM,
                             ai_protocol: 0,
                             ai_addrlen: 0,
                             ai_canonname: nil,
                             ai_addr: nil,
                             ai_next: nil)
        var infoPointer = UnsafeMutablePointer<addrinfo>(nil)
        
        let hostBytes = host?.cString(using: .utf8)
        let portBytes = port?.cString(using: .utf8)
        
        var status = getaddrinfo(hostBytes, portBytes, &hints, &infoPointer)
        
        if let info = infoPointer?.pointee {
            let socketId = socket(info.ai_family, info.ai_socktype, info.ai_protocol)
            
            status = connect(socketId, info.ai_addr, info.ai_addrlen)
            if status < 0 {
                print("failure to connect socket");
                close(socketId)
                return -1
            }
            
            return socketId
        } else {
            switch status {
                case EAI_ADDRFAMILY:
                    print("address family for hostname not supported")
                    break
                case EAI_AGAIN:
                    print("temporary failure in name resolution")
                    break
                case EAI_BADFLAGS:
                    print("invalid value for ai_flags")
                    break
                case EAI_FAIL:
                    print("non-recoverable failure in name resolution")
                    break
                case EAI_FAMILY:
                    print("ai_family not supported")
                    break
                case EAI_MEMORY:
                    print("memory allocation failure")
                    break
                case EAI_NODATA:
                    print("no address associated with hostname")
                    break
                case EAI_NONAME:
                    print("hostname nor servname provided, or not known")
                    break
                case EAI_SERVICE:
                    print("ervname not supported for ai_socktype")
                    break
                case EAI_SOCKTYPE:
                    print("ai_socktype not supported")
                    break
                case EAI_SYSTEM:
                    print("system error returned in errno")
                    break
                case EAI_BADHINTS:
                    print("invalid value for hints")
                    break
                case EAI_PROTOCOL:
                    print("resolved protocol is unknown")
                    break
                case EAI_OVERFLOW:
                    print("argument buffer overflow")
                    break
                default:
                    print("unknown error")
                    break
            }
        }
        
        freeaddrinfo(infoPointer)
        
        return -1
    }
    
    private var socketCallback: CFSocketCallBack = { (socket: CFSocket?, callBack: CFSocketCallBackType, address: CFData?, data: UnsafePointer<Void>?, info: UnsafeMutablePointer<Void>?) -> Void in
        if callBack == .connectCallBack {
            print("connect callback")
            if let info = info {
                let transport = Unmanaged<SDLTCPTransport>.fromOpaque(OpaquePointer(info)).takeRetainedValue()
                transport.delegate?.connected(to: transport)
            }
        } else if callBack == .dataCallBack{
            print("data callback")
            if let info = info {
                let transport = Unmanaged<SDLTCPTransport>.fromOpaque(OpaquePointer(info)).takeRetainedValue()

                let receivedData = Data(bytes: CFDataGetBytePtr(address), count: CFDataGetLength(address))

                transport.delegate?.received(receivedData)
            }
        } else {
            print("else callback")
        }
    }
    
}
