//
//  ObserverTest.swift
//  Demo
//
//  Created by sword on 2018/8/16.
//  Copyright © 2018年 Sword. All rights reserved.
//

import Foundation

class ObserverTest: NSObject {
    
    var test: Int? {
        didSet {
            
            print("newValue \(test.debugDescription)")
        }
    }
}
