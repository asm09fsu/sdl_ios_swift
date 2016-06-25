//
//  SDLDebugTool.swift
//  SmartDeviceLink-iOS
//
//  Created by Muller, Alexander (A.) on 6/16/16.
//  Copyright © 2016 smartdevicelink. All rights reserved.
//

import Foundation

enum SDLDebugType: Int {
    case debug = 0
    case iapTransport = 1
    case tcpTransport = 2
    case prot = 3
    case rpc = 4
    case app = 5
}

enum SDLDebugOutput: Int {
    case all = 0xFF
    case device = 1
    case debugTool = 2
    case file = 4
}

public class SDLDebugTool {
//    class func add(console: SDLDebugToolConsole) {
//        
//    }
//    
//    class func add(console: SDLDebugToolConsole, to group:String) {
//        
//    }
//    
//    class func remove(console: SDLDebugToolConsole) {
//        
//    }
//    
//    class func remove(console: SDLDebugToolConsole, to group:String) {
//        
//    }
    
    class func log(_ info: String?) {
        
    }
    
    class func log(_ info: String?, with type:SDLDebugType) {
        
    }
    
    class func log(_ info: String?, with type:SDLDebugType, to output:SDLDebugOutput) {
        
    }
    
    class func log(_ info: String?, with type:SDLDebugType, to output:SDLDebugOutput, of group:String) {
        
    }
    
    class func log(info: inout String?, and data:Data?, with type:SDLDebugType, to output:SDLDebugOutput) {
        if info == nil {
            info = String()
        }
        
        if data != nil {
            autoreleasepool {
                if let dataString = SDLHexUtility.string(from: data!) {
                    info?.append(dataString)
                }
            }
        }
        
        SDLDebugTool.log(info, with: type, to: output, of: "default")
    }

    class func enableDebugToLogFile() {
        
    }
    
    class func disableDebugToLogFile() {
        
    }
    
    class func write(info: String) {

    }
    
    class func string(for type:SDLDebugType) {
        
    }
}

/*
  
 // The designated logInfo method. All outputs should be performed here.
 + (void)logInfo:(NSString *)info withType:(SDLDebugType)type toOutput:(SDLDebugOutput)output toGroup:(NSString *)consoleGroupName {
    // Format the message, prepend the thread id
    NSString *outputString = [NSString stringWithFormat:@"[%li] %@", (long)[[NSThread currentThread] threadIndex], info];
 
    //  Output to the various destinations
 
    //Output To DeviceConsole
    if (output & SDLDebugOutput_DeviceConsole) {
        NSLog(@"%@", outputString);
    }
 
    //Output To DebugToolConsoles
    if (output & SDLDebugOutput_DebugToolConsole) {
        NSSet *consoleListeners = [self getConsoleListenersForGroup:consoleGroupName];
        for (NSObject<SDLDebugToolConsole> *console in consoleListeners) {
            [console logInfo:outputString];
        }
    }
 
    //Output To LogFile
    if (output & SDLDebugOutput_File) {
        [SDLDebugTool writeToLogFile:outputString];
    }
 
    //Output To Siphon
    [SDLSiphonServer init];
    [SDLSiphonServer _siphonNSLogData:outputString];
 }
 */
