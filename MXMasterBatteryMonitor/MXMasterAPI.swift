//
//  MXMasterAPI.swift
//  MXMasterBatteryMonitor
//
//  Created by John Fansler on 6/4/17.
//  Copyright © 2017 John Fansler. All rights reserved.
//

import Foundation
import Cocoa
import CoreBluetooth

let MXMasterBatteryService = CBUUID(string: "180F")
let MXMasterBatteryCharacteristic = CBUUID(string: "2A19")
let MXMasterService = CBUUID(string: "00010000-0000-1000-8000-011F2000046D")
let MXMasterService2 = CBUUID(string: "0F0A93FE-0AF3-433B-B702-9FD910375C4C")

class MXMasterBluetoothAPI: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var savedPeripheral:CBPeripheral?
    var manager: CBCentralManager!
    var delegate: CBCentralManagerDelegate?
    
    private(set) var connectedPeripheral : CBPeripheral?
    private(set) var connectedServices : [CBService]?
    
    var statusItem:NSStatusItem?
    
    func setStatusItem(menu: NSStatusItem){
        statusItem = menu
         manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func getIcon(forValue: UInt8) -> NSImage? {
        var ImageName = "statusNone"
        switch(forValue){
        case 0:
            ImageName = "statusNone"
        case 1...20:
            ImageName = "statusLow"
        case 21...50:
            ImageName = "statusHalf"
        case 51...80:
            ImageName = "statusHalf"
        case 81...99:
            ImageName = "statusCharged"
        case 100:
            ImageName = "statusFull"
        default:
            ImageName = "statusNone"
        }
        let icon = NSImage(named: ImageName)
        icon?.isTemplate = true // best for dark mode
        return icon
    }
    func getLevel(){
        
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if (manager.state == .poweredOn){
            print("*** BLE powered on and ready ***")
            // scan for any peripheral with any service.
            // centralManager.scanForPeripherals(withServices: nil, options: nil)
            // calls centralManager(_:didDiscover:advertisementData:rssi)
            
            // scan for specific peripherals with specific services
            // use option [CBCentralManagerScanOptionAllowDuplicatesKey:true] to see each broudcast
            
                scanBLEDevice()
            
        } else {
            print("*** BLE not on ***")
            return
        }
        
    }
    
    func scanBLEDevice(){
        print("starting scan")
        let a = manager.retrieveConnectedPeripherals(withServices: [MXMasterService])
        print(a)
        if (a.count<1){
            manager.scanForPeripherals(withServices: nil, options: nil)
        } else {
            manager.connect(a[0], options: nil)
            savedPeripheral = a[0]
        }
    }
    func stopScanForBLEDevice(){
        manager?.stopScan()
        print("scan stopped")
    }
    
    //CBCentralManagerDelegate code
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // a peripheral was discovered
        print("DidDiscover: \(peripheral)\n****************************")

        
    }
    func centralManager(_ central: CBCentralManager, didRetrieveConnectedPeripherals peripherals: [CBPeripheral]) {
        print("Got something")
        print(peripherals)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // pass reference to connected peripheral to parentview
        
        peripheral.delegate=self
        peripheral.discoverServices(nil)
        
        
        print("connected!")
        print(savedPeripheral as Any)
        
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(error!)
    }
    
    func centralManager(_ central: CBCentralManager, didRetrievePeripherals peripherals: [CBPeripheral]) {
        print(peripherals)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("found services")
        if let error = error {
            print("error discovering services: \(error)")
            return
        }

        if let services = peripheral.services {
            print("Found \(services.count) services!\n****************************")
            
            for service in services {
                //print("service: \(service)")
                if service.uuid == MXMasterBatteryService {
                    print("*** found MX Master Battery Service ***")
                    print("service: \(service)")
                    peripheral.discoverCharacteristics(nil, for: service)
                    // calls peripheral(_:didDiscoverCharacteristicsFor:error)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("peripheral(_:didDiscoverCharacteristicsFor:error)")
        
        if let error = error {
            print("error discovering characteristics: \(error)")
            return
        }
        
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == MXMasterBatteryCharacteristic {
                    print("*** found MX MXaster Battery Characteristic ***")
                    print("UUID: \(characteristic.uuid)")
                    // subscribe to the characteristic
                    peripheral.readValue(for: characteristic)
                    peripheral.setNotifyValue(true, for: characteristic)
                    // calls peripheral(_:didUpdateValueFor:error)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // the value that we subscribed to was updated
        print("peripheral(_:didUpdateValueFor:error)")
        
        if let error = error {
            print("error reading characteristic: \(error)")
            return
        }
        
        if let theValue = characteristic.value {
            let theRealValue = theValue[0]
            print(theRealValue)
            let icon = getIcon(forValue: theRealValue)
            statusItem!.image = icon
            
        }
    }
    
//    func peripheral(
//        peripheral: CBPeripheral,
//        didDiscoverServices error: NSError?) {
//        for service in peripheral.services! {
//            let thisService = service as CBService
//
//            print("foundServices!")
//            print(thisService)
////            if service.UUID == BEAN_SERVICE_UUID {
////                peripheral.discoverCharacteristics(
////                    nil,
////                    forService: thisService
////                )
////            }
//        }
//    }
    
}
