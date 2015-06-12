//
//  HomesInterfaceController.swift
//  HMWatch
//
//  Created by Khaos Tian on 6/11/15.
//  Copyright © 2015 Oltica. All rights reserved.
//

import WatchKit
import Foundation
import HomeKit

@available(watchOSApplicationExtension 20000, *)
class HomesInterfaceController: WKInterfaceController {
    
    @IBOutlet var homesTable: WKInterfaceTable!
    weak var accessoriesInterfaceController: AccessoriesInterfaceController!
    var homes: [HMHome]!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if let context = context as? [String : AnyObject] {
            if let cHomes = context["Homes"] as? [HMHome] {
                self.homes = cHomes
            }
            if let aic = context["AIC"] as? AccessoriesInterfaceController {
                self.accessoriesInterfaceController = aic
            }
            
            self.homesTable.setNumberOfRows(self.homes.count, withRowType: "HomeCell")
            for index in 0..<self.homes.count {
                let row = self.homesTable.rowControllerAtIndex(index) as! HomeCell
                let home = self.homes[index]
                row.nameLabel.setText("\(home.name)")
            }
        }
    }

    override func willActivate() {
        super.willActivate()
    }

    override func didDeactivate() {
        super.didDeactivate()
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        if table == self.homesTable {
            let home = self.homes[rowIndex]
            self.accessoriesInterfaceController.currentHome = home
            self.dismissController()
        }
    }
    
}
