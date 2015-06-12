//
//  Core.swift
//  HMWatch
//
//  Created by Khaos Tian on 6/11/15.
//  Copyright © 2015 Oltica. All rights reserved.
//

import Foundation

class Core {
    static let sharedInstance = Core()
    
    lazy var typeCache = [NSUUID : String]()
}