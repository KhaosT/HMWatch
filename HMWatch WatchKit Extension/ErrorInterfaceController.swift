//
//  ErrorInterfaceController.swift
//  HMWatch
//
//  Created by Khaos Tian on 6/11/15.
//  Copyright © 2015 Oltica. All rights reserved.
//

import WatchKit
import Foundation

class ErrorObject {
    var title: String?
    var details: String?
    var dismissText: String?
    
    var actionButton: String?
    var action: ((WKInterfaceController)->())?
    
    init(title: String, details: String) {
        self.title = title
        self.details = details
    }
}

class ErrorInterfaceController: WKInterfaceController {

    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    @IBOutlet weak var detailLabel: WKInterfaceLabel!
    @IBOutlet weak var actionButton: WKInterfaceButton!
    
    var action: ((WKInterfaceController) -> ())?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if let context = context as? ErrorObject {
            if let dismissText = context.dismissText {
                self.setTitle(dismissText)
            }
            if let title = context.title {
                self.titleLabel.setText(title)
            }
            if let details = context.details {
                self.detailLabel.setText(details)
            }
            if let actionButtonText = context.actionButton {
                self.action = context.action
                self.actionButton.setTitle(actionButtonText)
                self.actionButton.setHidden(false)
            }
        }
        // Configure interface objects here.
    }
    
    @IBAction func didPressActionButton() {
        if let action = self.action {
            action(self)
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

}
