//
//  ViewController.swift
//  Mi-Band for Swift
//
//  Created by Daniel Weber on 29.07.17.
//  Copyright © 2017 zero2one. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // MARK: Outlets
    
    @IBOutlet weak var connectionImageView: UIImageView!
    @IBOutlet weak var batteryImageView: UIImageView!
    @IBOutlet weak var heartRateImageView: UIImageView!
    
    @IBOutlet weak var connectionLabel: UILabel!
    @IBOutlet weak var batteryLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var heartRateLabel: UILabel!
    
    
    
    // MARK: Attributes
    
    var centralManager:CBCentralManager!
    var miBand:MiBand2!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager()
        centralManager.delegate = self
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state{
        case .poweredOn:
            print("poweredOn")
            
            let lastPeripherals = centralManager.retrieveConnectedPeripherals(withServices: [MiBand2Service.UUID_SERVICE_MIBAND2_SERVICE])
            
            if lastPeripherals.count > 0{
                let device = lastPeripherals.first! as CBPeripheral;
                miBand = MiBand2(device);
                centralManager.connect(miBand.peripheral, options: nil)
            }
            else {
                centralManager.scanForPeripherals(withServices: nil, options: nil)
            }
            
            
            
        default:
            print(central.state)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if(peripheral.name == "MI Band 2"){
            miBand = MiBand2(peripheral)
            print("try to connect to \(peripheral.name)")
            centralManager.connect(miBand.peripheral, options: nil)
        }else{
            print("discovered: \(peripheral.name)")
        }
        
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        miBand.peripheral.delegate = self
        miBand.peripheral.discoverServices(nil)
        self.connectionLabel.text = miBand.peripheral.name
        self.connectionImageView.image = #imageLiteral(resourceName: "connectionFilled")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let servicePeripherals = peripheral.services as [CBService]!
        {
            for servicePeripheral in servicePeripherals
            {
                peripheral.discoverCharacteristics(nil, for: servicePeripheral)
                
            }
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let charactericsArr = service.characteristics  as [CBCharacteristic]!{
            for cc in charactericsArr{
                switch cc.uuid.uuidString{
                case MiBand2Service.UUID_CHARACTERISTIC_6_BATTERY_INFO.uuidString:
                    peripheral.readValue(for: cc)
                    break
                case MiBand2Service.UUID_CHARACTERISTIC_HEART_RATE_DATA.uuidString:
                    peripheral.setNotifyValue(true, for: cc)
                    break
                case MiBand2Service.UUID_CHARACTERISTIC_7_REALTIME_STEPS.uuidString:
                    self.updateSteps()
                case MiBand2Service.UUID_CHARACTERISTIC_3_CONFIGURATION.uuidString:
                    // set time format: var rawArray:[UInt8] = [0x06,0x02, 0x00, 0x01]
                    var rawArray:[UInt8] = [0x0a,0x20, 0x00, 0x00]
                    let data = NSData(bytes: &rawArray, length: rawArray.count)
                    peripheral.writeValue(data as Data, for: cc, type: .withoutResponse)
                default:
                    print("Service: "+service.uuid.uuidString+" Characteristic: "+cc.uuid.uuidString)
                    break
                }
            }
            
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid.uuidString{
        case "FF06":
            var u16:Int
            if (characteristic.value != nil){
                u16 = (characteristic.value! as NSData).bytes.bindMemory(to: Int.self, capacity: characteristic.value!.count).pointee
            }else{
                u16 = 0
            }
            print("\(u16) steps")
        case MiBand2Service.UUID_CHARACTERISTIC_6_BATTERY_INFO.uuidString:
            updateBattery(miBand.getBattery(batteryData: characteristic.value!))
        case MiBand2Service.UUID_CHARACTERISTIC_HEART_RATE_DATA.uuidString:
            updateHeartRate(miBand.getHeartRate(heartRateData: characteristic.value!))
        default:
            print(characteristic.uuid.uuidString)
        }
    }
    
    // MARK: methods
    
    func updateSteps(){
        if let (steps, distance, calories) = miBand.getSteps(){
            self.stepsLabel.text = steps.description
            self.distanceLabel.text = distance.description+" m"
            self.caloriesLabel.text = calories.description+" kcal"
        }
    }
    
    func updateHeartRate(_ heartRate:Int){
        self.stopHeartBeatAnimation()
        miBand.startVibrate()
        self.heartRateLabel.text = heartRate.description
    }
    
    func updateBattery(_ battery:Int){
        if battery > 75{
            self.batteryImageView.image = #imageLiteral(resourceName: "batteryFull")
        }else if battery > 50{
            self.batteryImageView.image = #imageLiteral(resourceName: "battery75")
        }else if battery > 25{
            self.batteryImageView.image = #imageLiteral(resourceName: "battery50")
        }else{
            self.batteryImageView.image = #imageLiteral(resourceName: "battery25")
        }
        self.batteryLabel.text = battery.description+"%"
    }
    
    
    func startHeartBeatAnimation(){
        let pulse1 = CASpringAnimation(keyPath: "transform.scale")
        pulse1.duration = 0.6
        pulse1.fromValue = 1.0
        pulse1.toValue = 1.12
        pulse1.autoreverses = true
        pulse1.repeatCount = 1
        pulse1.initialVelocity = 0.5
        pulse1.damping = 0.8
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 1.5
        animationGroup.repeatCount = 1000
        animationGroup.animations = [pulse1]
        
        self.heartRateImageView.layer.add(animationGroup, forKey: "pulse")
    }
    
    func stopHeartBeatAnimation(){
        self.heartRateImageView.layer.removeAllAnimations()
    }

    
    // MARK: Actions
    @IBAction func getHeartRate(_ sender: Any) {
        miBand.measureHeartRate()
        self.startHeartBeatAnimation()
    }
    
    
    
}

