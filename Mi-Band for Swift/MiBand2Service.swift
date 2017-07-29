//
//  Services.swift
//  Mi-Band for Swift
//
//  Created by Daniel Weber on 29.07.17.
//  Copyright © 2017 zero2one. All rights reserved.
//

import Foundation
import CoreBluetooth

struct MiBand2Service{
    
    //
    
    public static let UUID_SERVICE_MIBAND2_SERVICE: CBUUID = CBUUID(string: "FEE0")
    public static let UUID_SERVICE_HEART_RATE: CBUUID = CBUUID(string: "180D")
    public static let UUID_SERVICE_ALERT: CBUUID = CBUUID(string: "1802")
    
    
    public static let UUID_CHARACTERISTIC_FIRMWARE: CBUUID = CBUUID(string: "00001531-0000-3512-2118-0009af100700")
    public static let UUID_CHARACTERISTIC_FIRMWARE_DATA: CBUUID = CBUUID(string: "00001532-0000-3512-2118-0009af100700")
    
    public static let UUID_CHARACTERISTIC_HEART_RATE_CONTROL: CBUUID = CBUUID(string: "2A39")
    public static let UUID_CHARACTERISTIC_HEART_RATE_DATA: CBUUID = CBUUID(string: "2A37")
    
    public static let UUID_CHARACTERISTIC_VIBRATION_CONTROL: CBUUID = CBUUID(string: "2A06")
    
    /**
     * Alarms, Display and other configuration.
     */
    public static let UUID_CHARACTERISTIC_3_CONFIGURATION: CBUUID = CBUUID(string: "00000003-0000-3512-2118-0009af100700");
    public static let UUID_CHARACTERISTIC_5_ACTIVITY_DATA: CBUUID = CBUUID(string: "00000005-0000-3512-2118-0009af100700");
    public static let UUID_CHARACTERISTIC_6_BATTERY_INFO: CBUUID = CBUUID(string: "00000006-0000-3512-2118-0009af100700");
    public static let UUID_CHARACTERISTIC_7_REALTIME_STEPS: CBUUID = CBUUID(string: "00000007-0000-3512-2118-0009af100700");
    
    // service uuid fee1
    public static let UUID_CHARACTERISTIC_AUTH: CBUUID = CBUUID(string: "00000009-0000-3512-2118-0009af100700");
    public static let UUID_CHARACTERISTIC_10_BUTTON: CBUUID = CBUUID(string: "00000010-0000-3512-2118-0009af100700");
    
    // for vibration characvteristic
    public static let ALERT_LEVEL_CUSTOM:[Int8] = [-1, 2, 2, 1, 1, 3]; //[Custom Flag, Duration, Duration, Break, Break, Repetitions]
    public static let ALERT_LEVEL_NONE:[Int8] = [0];
    public static let ALERT_LEVEL_MESSAGE:[Int8] = [1];
    public static let ALERT_LEVEL_PHONE_CALL:[Int8] = [2];
    public static let ALERT_LEVEL_VIBRATE_ONLY:[Int8] = [3];
    
    public static let COMMAND_START_HEART_RATE_MEASUREMENT:[UInt8] = [21, 2, 1];
    
    
    
}
