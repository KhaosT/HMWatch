//
//  ThermostatInterfaceController.swift
//  HMWatch
//
//  Created by Khaos Tian on 6/12/15.
//  Copyright © 2015 Oltica. All rights reserved.
//

import WatchKit
import Foundation
import HomeKit

@available(watchOSApplicationExtension 20000, *)
class ThermostatInterfaceController: WKInterfaceController {

    @IBOutlet var currentTemperatureLabel: WKInterfaceLabel!
    @IBOutlet var temperatureButton: WKInterfaceButton!
    @IBOutlet var temperatureLabel: WKInterfaceLabel!
    @IBOutlet var temperaturePicker: WKInterfacePicker!
    
    weak var currentCH: HMCharacteristic!
    weak var targetCH: HMCharacteristic!
    weak var currentTemp: HMCharacteristic!
    weak var targetTemp: HMCharacteristic!
    weak var unit: HMCharacteristic!
    
    var tempUnit = "℃"
    var tempPickerState = false
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        self.setTitle("Done")
        self.temperaturePicker.setEnabled(false)
        
        if let context = context as? [String: AnyObject] {
            if let dUnit = context["unit"] as? HMCharacteristic {
                self.unit = dUnit
                
                if let value = dUnit.value as? Int {
                    if value == 1 {
                        self.tempUnit = "℉"
                    }
                }
            }
            
            if let cCH = context["cCH"] as? HMCharacteristic {
                self.currentCH = cCH;
            }
            
            if let tCH = context["tCH"] as? HMCharacteristic {
                self.targetCH = tCH
            }
            
            if let cTemp = context["cTemp"] as? HMCharacteristic {
                self.currentTemp = cTemp
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "didUpdateCurrentTemp:", name: "HMWatchdidUpdateValueForCharacteristic", object: self.currentTemp)

                if let value = cTemp.value as? Float {
                    self.currentTemperatureLabel.setText("\(Int(value))")
                }
            }
            
            if let tTemp = context["tTemp"] as? HMCharacteristic {
                self.targetTemp = tTemp
                
                var tempRange = 28
                
                if let metadata = tTemp.metadata {
                    if let min = metadata.minimumValue, let max = metadata.maximumValue {
                        tempRange = max.integerValue - min.integerValue
                    }
                }
                
                var pickerItems = [WKPickerItem]()
                let pickerItem = WKPickerItem()
                for _ in 0...tempRange {
                    pickerItems.append(pickerItem)
                }
                self.temperaturePicker.setItems(pickerItems)
                
                if let value = tTemp.value as? Float, min = tTemp.metadata?.minimumValue {
                    self.temperaturePicker.setSelectedItemIndex(Int(value - min.floatValue))
                }
            }
        }
        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    func didUpdateCurrentTemp(notification: NSNotification) {
        if let value = self.currentTemp.value as? Float {
            self.currentTemperatureLabel.setText("\(Int(value))")
        }
    }
    
    @IBAction func didPressTemperatureButton() {
        if self.tempPickerState {
            self.tempPickerState = false
            self.temperaturePicker.setEnabled(false)
        } else {
            self.tempPickerState = true
            self.temperaturePicker.setEnabled(true)
            self.temperaturePicker.focusForCrownInput()
        }
    }
    
    @IBAction func temperaturePickerDidChange(value: Int) {
        let targetValue = value + 10
        self.temperatureLabel.setText("\(targetValue)")
        self.updateTargetTemerature(targetValue)
    }
    
    func updateTargetTemerature(value: Int) {
        self.targetTemp.writeValue(value, completionHandler: {
            error in
            if let error = error {
                NSLog("Update Target Temp Error: \(error)")
            }
        })
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
