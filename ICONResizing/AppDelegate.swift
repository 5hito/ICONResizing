//
//  AppDelegate.swift
//  ICONResizing
//
//  Created by Artem Kandaurov on 19.05.17.
//  Copyright © 2017 Artem Kandaurov. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let mainColor: NSColor = NSColor(calibratedRed: 61/255.0, green: 143/255.0, blue: 182/255.0, alpha: 1)
    var iOSiconSides = [ 20, 29, 40, 50, 57, 58, 60, 72, 76, 80, 87, 100, 114, 120, 144, 152, 167, 180 ]
    var macOSiconSides = [ 16, 32, 64, 128, 256, 512, 1024 ]
    var watchOSiconSides = [ 48, 55, 58, 80, 87, 88, 172, 196 ]

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}

