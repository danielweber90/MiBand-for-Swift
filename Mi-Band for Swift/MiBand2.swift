//
//  MiBand2.swift
//  Mi-Band for Swift
//
//  Created by Daniel Weber on 29.07.17.
//  Copyright © 2017 zero2one. All rights reserved.
//

import Foundation
import CoreBluetooth

class MiBand2{
    
    let peripheral: CBPeripheral
    
    init(_ peripheral: CBPeripheral){
        self.peripheral = peripheral
    }
    
    func startVibrate(){
        vibrationAction(MiBand2Service.ALERT_LEVEL_VIBRATE_ONLY)
    }
    
    func stopVibrate(){
        vibrationAction(MiBand2Service.ALERT_LEVEL_NONE)
    }
    
    func vibrationAction(_ alert: [Int8]){
        if let service = peripheral.services?.first(where: {$0.uuid == MiBand2Service.UUID_SERVICE_ALERT}), let characteristic = service.characteristics?.first(where: {$0.uuid == MiBand2Service.UUID_CHARACTERISTIC_VIBRATION_CONTROL}){
            var vibrationType = alert
            let data = NSData(bytes: &vibrationType, length: vibrationType.count)
            peripheral.writeValue(data as Data, for: characteristic, type: .withoutResponse)
        }
    }
    
    func getBattery(batteryData:Data) -> Int{
        print("--- UPDATING Battery Data..")
        
        var buffer = [UInt8](batteryData)
        print("\(buffer[1]) % charged")
        
        return Int(buffer[1])
    }
    
    
    func getSteps()->(Int, Int, Int)?{
        if let service = peripheral.services?.first(where: {$0.uuid == MiBand2Service.UUID_SERVICE_MIBAND2_SERVICE}), let characteristic = service.characteristics?.first(where: {$0.uuid == MiBand2Service.UUID_CHARACTERISTIC_7_REALTIME_STEPS}), let data = characteristic.value{
            print("--- UPDATING Steps ..")
            var buffer = [UInt8](data)
            data.copyBytes(to: &buffer, count: buffer.count)
            
            let steps = (UInt16(buffer[1] & 255) | (UInt16(buffer[2] & 255) << 8))
            let distance = (((UInt32(buffer[5] & 255) | (UInt32(buffer[6] & 255) << 8)) | UInt32(buffer[7] & 255)) | (UInt32(buffer[8] & 255) << 24));
            let calories = (((UInt32(buffer[9] & 255) | (UInt32(buffer[10] & 255) << 8)) | UInt32(buffer[11] & 255)) | (UInt32(buffer[12] & 255) << 24));
            
            return (Int.init(steps), Int.init(distance), Int.init(calories))
        }else{
            print("Characteristic or Service could nit be found")
            return nil
        }
    }
    
    func measureHeartRate(){
        if let service = peripheral.services?.first(where: {$0.uuid == MiBand2Service.UUID_SERVICE_HEART_RATE}), let characteristic = service.characteristics?.first(where: {$0.uuid == MiBand2Service.UUID_CHARACTERISTIC_HEART_RATE_CONTROL}){
            let data = NSData(bytes: MiBand2Service.COMMAND_START_HEART_RATE_MEASUREMENT, length: MiBand2Service.COMMAND_START_HEART_RATE_MEASUREMENT.count)
            peripheral.writeValue(data as Data, for: characteristic, type: .withResponse)
        }
    }
    
    func getHeartRate(heartRateData:Data) -> Int{
        print("--- UPDATING Heart Rate..")
        var buffer = [UInt8](repeating: 0x00, count: heartRateData.count)
        heartRateData.copyBytes(to: &buffer, count: buffer.count)
        
        var bpm:UInt16?
        if (buffer.count >= 2){
            if (buffer[0] & 0x01 == 0){
                bpm = UInt16(buffer[1]);
            }else {
                bpm = UInt16(buffer[1]) << 8
                bpm =  bpm! | UInt16(buffer[2])
            }
        }
        
        if let actualBpm = bpm{
            return Int(actualBpm)
        }else {
            return Int(bpm!)
        }
    }
}
