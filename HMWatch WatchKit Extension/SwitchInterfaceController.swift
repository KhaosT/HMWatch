//
//  SwitchInterfaceController.swift
//  HMWatch
//
//  Created by Khaos Tian on 6/11/15.
//  Copyright © 2015 Oltica. All rights reserved.
//

import WatchKit
import Foundation
import HomeKit

@available(watchOSApplicationExtension 20000, *)
class SwitchInterfaceController: WKInterfaceController {
    
    @IBOutlet var currentStateLabel: WKInterfaceLabel!
    @IBOutlet var currentStateImage: WKInterfaceImage!
    @IBOutlet var brightnessSlider: WKInterfaceSlider!
    @IBOutlet var brightnessPicker: WKInterfacePicker!
    
    var currentState: Bool = false
    var typeStr: String = "Unknown"
    
    weak var targetCharacteristic: HMCharacteristic!
    weak var brightnessCharacteristic: HMCharacteristic?

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        self.setTitle("Done")
        
        if let context = context as? [String: AnyObject] {
            if let type = context["Type"] as? String {
                self.typeStr = type
            }
            
            if let characteristic = context["Characteristic"] as? HMCharacteristic {
                self.targetCharacteristic = characteristic
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "didUpdatePowerState:", name: "HMWatchdidUpdateValueForCharacteristic", object: self.targetCharacteristic)

                if let value = self.targetCharacteristic.value as? Bool {
                    self.currentState = value
                }
            }
            
            if let bChar = context["BrightnessChar"] as? HMCharacteristic {
                self.brightnessCharacteristic = bChar
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "didUpdateBrightness:", name: "HMWatchdidUpdateValueForCharacteristic", object: self.brightnessCharacteristic)
                
                var pickerItems = [WKPickerItem]()
                let pickerItem = WKPickerItem()
                
                for _ in 0 ... 100 {
                    pickerItems.append(pickerItem)
                }
                
                self.brightnessPicker.setItems(pickerItems)
                
                if let value = self.brightnessCharacteristic?.value as? Int {
                    self.brightnessPicker.setSelectedItemIndex(value)
                    self.brightnessSlider.setValue(Float(value))
                }
            } else {
                self.brightnessPicker.setHidden(true)
                self.brightnessSlider.setHidden(true)
                self.brightnessPicker.setEnabled(false)
                self.brightnessSlider.setEnabled(false)
            }
        }
    }
    
    @IBAction func didPressPower() {
        self.currentState = !self.currentState
        
        self.targetCharacteristic.writeValue(self.currentState, completionHandler: {
            error in
            if let error = error {
                NSLog("Update Power Error: \(error)")
            }
        })
        
        self.updateLocalContent()
    }
    
    @IBAction func didUpdateBrightnessPicker(value: Int) {
        self.brightnessSlider.setValue(Float(value))
        self.updateBrightnessChar(value)
    }
    
    @IBAction func didUpdateBrightnessSlider(value: Float) {
        self.brightnessPicker.setSelectedItemIndex(Int(value))
        self.updateBrightnessChar(Int(value))
    }
    
    func updateBrightnessChar(value: Int) {
        self.brightnessCharacteristic?.writeValue(value, completionHandler: {
            error in
            if let error = error {
                NSLog("Update Brightness Error: \(error)")
            }
        })
    }
    
    func updateLocalContent() {
        let stateStr = self.currentState ? "On" : "Off"
        self.currentStateLabel.setText(stateStr)
        self.currentStateImage.setImageNamed("\(self.typeStr)-\(stateStr)")
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        self.updateLocalContent()
        
        if self.brightnessCharacteristic != nil {
            self.brightnessPicker.focusForCrownInput()
        }

    }
    
    func didUpdatePowerState(notification: NSNotification) {
        if let value = self.targetCharacteristic.value as? Bool {
            self.currentState = value
            self.updateLocalContent()
        }
    }
    
    func didUpdateBrightness(notification: NSNotification) {
        if let value = self.brightnessCharacteristic?.value as? Int {
            self.brightnessPicker.setSelectedItemIndex(value)
            self.brightnessSlider.setValue(Float(value))
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}
