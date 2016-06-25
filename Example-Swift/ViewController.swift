//
//  ViewController.swift
//  Example-Swift
//
//  Created by Muller, Alexander (A.) on 6/16/16.
//  Copyright © 2016 SmartDeviceLink. All rights reserved.
//

import UIKit

import SmartDeviceLink

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        SDLProxy(transport: SDLTCPTransport(), protocol: SDLProtocol())
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

