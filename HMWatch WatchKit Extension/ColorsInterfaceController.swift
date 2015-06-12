//
//  ColorsInterfaceController.swift
//  HMWatch
//
//  Created by Khaos Tian on 6/11/15.
//  Copyright © 2015 Oltica. All rights reserved.
//

import WatchKit
import Foundation
import HomeKit

@available(watchOSApplicationExtension 20000, *)
class ColorsInterfaceController: WKInterfaceController {
    @IBOutlet var picker: WKInterfacePicker!
    @IBOutlet var pickerContainer: WKInterfaceGroup!
    
    let colors = [(360,100),(123,100),(179,90),(60,96),(232,100),(295,98),(338,100),(33,98)]
    
    weak var hueChar: HMCharacteristic!
    weak var saturationChar: HMCharacteristic!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        self.setTitle("Done")
        
        if let context = context as? [String: AnyObject] {
            if let hue = context["HueChar"] as? HMCharacteristic {
                self.hueChar = hue
            }
            
            if let saturation = context["SaturationChar"] as? HMCharacteristic {
                self.saturationChar = saturation
            }
        }

        var pickerItems = [WKPickerItem]()
        
        for i in 0 ..< 8 {
            let pickerItem = WKPickerItem()
            
            pickerItem.contentImage = WKImage(imageName: "ColorPicker-\(i)")
            
            pickerItems.append(pickerItem)
        }
        
        self.picker.setItems(pickerItems)
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func didUpdateColorValue(value: Int) {
        let color = self.colors[value]
        self.hueChar.writeValue(color.0, completionHandler: {
            error in
            if let error = error {
                NSLog("Update Hue Error: \(error)")
            }
        })
        
        self.saturationChar.writeValue(color.1, completionHandler: {
            error in
            if let error = error {
                NSLog("Update Saturation Error: \(error)")
            }
        })
    }

}
