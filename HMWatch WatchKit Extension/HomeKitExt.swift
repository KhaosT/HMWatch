//
//  HomeKitExt.swift
//  HMWatch
//
//  Created by Khaos Tian on 6/11/15.
//  Copyright © 2015 Oltica. All rights reserved.
//

import Foundation
import HomeKit

@available(watchOSApplicationExtension 20000, *)
extension HMAccessory {
    func representType() -> String {
        if let typeStr = Core.sharedInstance.typeCache[self.uniqueIdentifier] {
            return typeStr
        }
        
        var typeStr = "Unknown"
        var priority = 0
        
        for service in self.services {
            switch service.serviceType {
            case HMServiceTypeLightbulb:
                if priority < 2 {
                    typeStr = "Lightbulb"
                    priority = 2
                }
            case HMServiceTypeSwitch:
                if priority < 2 {
                    typeStr = "Switch"
                    priority = 2
                }
            case HMServiceTypeThermostat:
                if priority < 3 {
                    typeStr = "Thermostat"
                    priority = 3
                }
            case HMServiceTypeGarageDoorOpener:
                if priority < 5 {
                    typeStr = "GarageDoorOpener"
                    priority = 5
                }
            case HMServiceTypeAccessoryInformation:
                if priority < 1 {
                    typeStr = "Bridge"
                    priority = 1
                }
            case HMServiceTypeFan:
                if priority < 2 {
                    typeStr = "Fan"
                    priority = 2
                }
            case HMServiceTypeOutlet:
                if priority < 2{
                    typeStr = "Outlet"
                    priority = 2
                }
            case HMServiceTypeLockManagement, HMServiceTypeLockMechanism:
                if priority < 5 {
                    typeStr = "Lock"
                    priority = 5
                }
            default:
                continue
            }
        }
        
        Core.sharedInstance.typeCache[self.uniqueIdentifier] = typeStr
        
        return typeStr
    }
}