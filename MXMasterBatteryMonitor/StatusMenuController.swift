//
//  StatusMenuController.swift
//  MXMasterBatteryMonitor
//
//  Created by John Fansler on 6/4/17.
//  Copyright © 2017 John Fansler. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject {
    
    let MXMaster = MXMasterBluetoothAPI()
    
    @IBOutlet weak var statusMenu: NSMenu!
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
    
    @IBAction func scanClicked(_ sender: NSMenuItem) {
        MXMaster.scanBLEDevice()
    }
    override func awakeFromNib() {
        
        let icon = MXMaster.getIcon(forValue: 1)
        MXMaster.scanBLEDevice()
        statusItem.image = icon
        statusItem.menu = statusMenu
    }

}
