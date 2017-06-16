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

class MXMasterBluetoothAPI: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var peripherals:[CBPeripheral] = []
    var manager: CBCentralManager!
    
    
    required override init(){
        super.init()
        manager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
    
    func getIcon(forValue: Int) -> NSImage? {
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
    
    func scanBLEDevice(){
        print("starting scan")
        let MXMasterBattery = CBUUID(string: "2A19")
        let MXMaster=UUID(uuidString: "A2370BF4-32AB-4C4F-B355-EA058139E2D9")
        //manager?.scanForPeripherals(withServices: nil, options: nil)
        //var periferals = manager?.retrieveConnectedPeripherals(withServices: [])
        var periferals = manager?.retrievePeripherals(withIdentifiers: [MXMaster!])
        manager?.connect(periferals![0], options: nil)
        print(periferals);
        print("")
        
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 60.0) {
//            self.stopScanForBLEDevice()
//        }
        
    }
    func stopScanForBLEDevice(){
        manager?.stopScan()
        print("scan stopped")
    }
    
    //CBCentralManagerDelegate code
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Peripheral found!")
        print(advertisementData)
        
        if (!peripherals.contains(peripheral)){
            peripherals.append(peripheral)
        }
    }
    func centralManager(_ central: CBCentralManager, didRetrieveConnectedPeripherals peripherals: [CBPeripheral]) {
        print("Got something")
        print(peripherals)
    }
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("StateUpdated")
        print(central.state)
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // pass reference to connected peripheral to parentview
        peripheral.discoverServices( nil)
        // set manager's delegate view to parent so it can call relevant disconnect methods
        print("connected!")
        print(peripheral)
        
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(error!)
    }
    
    func centralManager(_ central: CBCentralManager, didRetrievePeripherals peripherals: [CBPeripheral]) {
        print(peripherals)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("found services")
        print(peripheral.services as Any)
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
