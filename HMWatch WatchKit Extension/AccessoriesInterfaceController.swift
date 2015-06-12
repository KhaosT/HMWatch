//
//  InterfaceController.swift
//  HMWatch WatchKit Extension
//
//  Created by Khaos Tian on 6/11/15.
//  Copyright © 2015 Oltica. All rights reserved.
//

import WatchKit
import Foundation
import HomeKit

@available(watchOSApplicationExtension 20000, *)
class AccessoriesInterfaceController: WKInterfaceController, HMHomeManagerDelegate, HMHomeDelegate, HMAccessoryDelegate {
    
    @IBOutlet var statusLabel: WKInterfaceLabel!
    @IBOutlet var accessoriesTable: WKInterfaceTable!
    @IBOutlet var noAccessoryGroup: WKInterfaceGroup!
    var presenting: Bool = false
    var isHomeKitReady: Bool = false
    
    let homeManager = HMHomeManager()
    var currentHome: HMHome? {
        didSet {
            self.updateHome()
        }
    }
    
    lazy var accessories = [HMAccessory]()

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        self.homeManager.delegate = self
    }
    
    @IBAction func didPressSelectHome() {
        self.presentControllerWithName("HomesInterfaceController", context: ["Homes":self.homeManager.homes, "AIC" : self])
    }
    
    func updateHome() {
        if !self.isHomeKitReady {
            return
        }
        
        if let home = self.currentHome {
            home.delegate = self
            
            if self.presenting {
                self.dismissController()
                self.presenting = false
            }
            
            self.setTitle(home.name)
            self.accessoriesTable.setHidden(false)
            self.statusLabel.setHidden(true)
            
            if self.accessories.count > 0 {
                self.accessories = home.accessories
            } else {
                self.accessories += home.accessories
            }
            
            if self.accessories.count > 0 {
                self.accessoriesTable.setHidden(false)
                self.noAccessoryGroup.setHidden(true)
                self.accessoriesTable.setNumberOfRows(self.accessories.count, withRowType: "AccessoryCell")
                
                for index in 0..<self.accessories.count {
                    let row = self.accessoriesTable.rowControllerAtIndex(index) as! AccessoryCellController
                    let accessory = self.accessories[index]
                    accessory.delegate = self

                    self.updateRow(row, accessory: accessory)
                    self.updateAccessory(accessory)
                }
            } else {
                self.accessoriesTable.setHidden(true)
                self.noAccessoryGroup.setHidden(false)
            }
        } else {
            self.accessoriesTable.setHidden(true)
            if self.homeManager.homes.count > 0 {
                self.didPressSelectHome()
            } else {
                self.presentNoHomeErrorInfo()
            }
        }
    }
    
    func generateControllersAndContextsForAccessory(accessory: HMAccessory) -> (controllers: [String], contexts: [AnyObject]) {
        var controllers = [String]()
        var contexts = [AnyObject]()
        
        switch accessory.representType() {
        case "Lightbulb":
            for service in accessory.services {
                if service.serviceType == HMServiceTypeLightbulb {
                    let characteristics = HMUtilities.lightbulbServiceToCharacteristics(service)
                    
                    let power = characteristics.power
                    controllers.append("SwitchInterfaceController")
                    var context = ["Type": "Lightbulb", "Characteristic": power]
                    if let b = characteristics.brightness {
                        context["BrightnessChar"] = b
                    }
                    contexts.append(context)
                    
                    if let hue = characteristics.hue, let saturation = characteristics.saturation {
                        controllers.append("ColorsInterfaceController")
                        contexts.append(["HueChar": hue, "SaturationChar": saturation])
                    }
                    
                    break
                }
            }
        case "Thermostat":
            for service in accessory.services {
                if service.serviceType == HMServiceTypeThermostat {
                    let characteristics = HMUtilities.thermostatServiceToCharacteristics(service)
                    
                    controllers.append("ThermostatInterfaceController")
                    contexts.append(["cCH": characteristics.currentCH, "tCH": characteristics.targetCH, "cTemp": characteristics.currentTemp, "tTemp": characteristics.targetTemp, "unit": characteristics.displayUnit])
                    
                    break
                }
            }
        default:
            NSLog("Unsupported Accessory")
        }
        
        return (controllers, contexts)
    }

    override func willActivate() {
        super.willActivate()
        self.updateHome()
    }

    override func didDeactivate() {
        super.didDeactivate()
    }
    
    func updateRow(row: AccessoryCellController, accessory: HMAccessory) {
        if accessory.reachable {
            row.stateIndicator.setBackgroundColor(UIColor.greenColor())
        } else {
            row.stateIndicator.setBackgroundColor(UIColor.redColor())
        }
        
        row.accessoryImage.setImageNamed(accessory.representType())
        row.accessoryLabel.setText("\(accessory.name)")
    }
    
    func updateAccessory(accessory: HMAccessory) {
        if accessory.reachable {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                for service in accessory.services {
                    for char in service.characteristics {
                        if char.properties.contains(HMCharacteristicPropertyReadable) {
                            char.readValueWithCompletionHandler {
                                error in
                                if let error = error {
                                    NSLog("Error On Read: \(error)")
                                }
                            }
                        }
                        if char.properties.contains(HMCharacteristicPropertySupportsEventNotification) {
                            char.enableNotification(true, completionHandler: {
                                error in
                                if let error = error {
                                    NSLog("Error On Write: \(error)")
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    func presentNoHomeErrorInfo() {
        if self.presenting {
            self.dismissController()
        }
        
        self.presenting = true
        let errorObject = ErrorObject(title: "No Home Available", details: "Please make sure there is at least one home in HomeKit database.")
        errorObject.dismissText = "OK"
        self.presentControllerWithName("ErrorInfoController", context: errorObject)
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        if table == self.accessoriesTable {
            let accessory = self.accessories[rowIndex]
            let interfaceControllersAndContexts = self.generateControllersAndContextsForAccessory(accessory)
            switch interfaceControllersAndContexts.contexts.count {
            case 0:
                let errorObject = ErrorObject(title: "Unsupported Accessory", details: "The selected accessory isn't currently being supported.")
                errorObject.dismissText = "OK"
                self.presentControllerWithName("ErrorInfoController", context: errorObject)
            case 1:
                self.presentControllerWithName(interfaceControllersAndContexts.controllers.first!, context: interfaceControllersAndContexts.contexts.first!)
            default:
                self.presentControllerWithNames(interfaceControllersAndContexts.controllers, contexts: interfaceControllersAndContexts.contexts)
            }
        }
    }
    
    func homeManagerDidUpdateHomes(manager: HMHomeManager) {
        self.isHomeKitReady = true
        if self.currentHome == nil {
            if manager.primaryHome != nil {
                self.currentHome = manager.primaryHome
            } else {
                if manager.homes.count > 0 {
                    self.didPressSelectHome()
                } else {
                    self.presentNoHomeErrorInfo()
                }
            }
        }
    }
    
    func homeManager(manager: HMHomeManager, didAddHome home: HMHome) {
        if self.currentHome == nil {
            self.currentHome = home
        }
    }
    
    func homeManager(manager: HMHomeManager, didRemoveHome home: HMHome) {
        if self.currentHome == home {
            self.currentHome = nil
        }
    }
    
    func homeDidUpdateName(home: HMHome) {
        self.setTitle(home.name)
    }
    
    func home(home: HMHome, didAddAccessory accessory: HMAccessory) {
        self.accessories.append(accessory)
        let index = self.accessories.count - 1
        self.accessoriesTable.insertRowsAtIndexes(NSIndexSet(index: index), withRowType: "AccessoryCell")
        
        let row = self.accessoriesTable.rowControllerAtIndex(index) as! AccessoryCellController
        accessory.delegate = self
        
        self.updateRow(row, accessory: accessory)
        self.updateAccessory(accessory)
    }
    
    func home(home: HMHome, didRemoveAccessory accessory: HMAccessory) {
        if let index = self.accessories.indexOf(accessory) {
            self.accessories.removeAtIndex(index)
            self.accessoriesTable.removeRowsAtIndexes(NSIndexSet(index: index))
        }
    }
    
    func accessoryDidUpdateReachability(accessory: HMAccessory) {
        if let index = self.accessories.indexOf(accessory) {
            let row = self.accessoriesTable.rowControllerAtIndex(index) as! AccessoryCellController
            self.updateRow(row, accessory: accessory)
            self.updateAccessory(accessory)
        }
    }
    
    func accessory(accessory: HMAccessory, service: HMService, didUpdateValueForCharacteristic characteristic: HMCharacteristic) {
        NSNotificationCenter.defaultCenter().postNotificationName("HMWatchdidUpdateValueForCharacteristic", object: characteristic)
    }
}
