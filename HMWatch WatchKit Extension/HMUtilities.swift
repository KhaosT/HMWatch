//
//  HMUtilities.swift
//  HMWatch
//
//  Created by Khaos Tian on 6/12/15.
//  Copyright © 2015 Oltica. All rights reserved.
//

import Foundation
import HomeKit

@available(watchOSApplicationExtension 20000, *)
class HMUtilities {
    class func lightbulbServiceToCharacteristics(service: HMService) -> (power: HMCharacteristic, saturation: HMCharacteristic?, brightness: HMCharacteristic?, hue: HMCharacteristic?) {
        
        var p: HMCharacteristic!
        var s: HMCharacteristic!
        var b: HMCharacteristic!
        var h: HMCharacteristic!
        
        for characteristic in service.characteristics {
            switch characteristic.characteristicType {
            case HMCharacteristicTypePowerState:
                p = characteristic
            case HMCharacteristicTypeSaturation:
                s = characteristic
            case HMCharacteristicTypeBrightness:
                b = characteristic
            case HMCharacteristicTypeHue:
                h = characteristic
            default:
                NSLog("Unknow Char")
            }
        }
        
        return (p,s,b,h)
    }
    
    class func thermostatServiceToCharacteristics(service: HMService) -> (currentCH: HMCharacteristic, targetCH: HMCharacteristic, currentTemp: HMCharacteristic, targetTemp: HMCharacteristic, displayUnit: HMCharacteristic) {
        var currentCoolingHeating: HMCharacteristic!
        var targetCoolingHeating: HMCharacteristic!
        var currentTemperature: HMCharacteristic!
        var targetTemperature: HMCharacteristic!
        var displayUnitChar: HMCharacteristic!
        
        for characteristic in service.characteristics {
            switch characteristic.characteristicType {
            case HMCharacteristicTypeCurrentHeatingCooling:
                currentCoolingHeating = characteristic
            case HMCharacteristicTypeTargetHeatingCooling:
                targetCoolingHeating = characteristic
            case HMCharacteristicTypeCurrentTemperature:
                currentTemperature = characteristic
            case HMCharacteristicTypeTargetTemperature:
                targetTemperature = characteristic
            case HMCharacteristicTypeTemperatureUnits:
                displayUnitChar = characteristic
            default:
                NSLog("Unknow Char")
            }
        }
        
        return (currentCoolingHeating, targetCoolingHeating, currentTemperature, targetTemperature, displayUnitChar)
    }
}