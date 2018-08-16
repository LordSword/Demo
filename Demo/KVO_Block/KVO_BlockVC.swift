//
//  KVO_BlockVC.swift
//  Demo
//
//  Created by sword on 2018/8/16.
//  Copyright © 2018年 Sword. All rights reserved.
//

import Foundation

class KVO_BlockVC: UIViewController {
    
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    var test:ObserverTest? = ObserverTest()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        test?.test = 100
        
        test?.sAddObserver(observer: self, forKey: "test") { [weak self] (observed, oldValue, newValue) in
            
            self?.text.text = newValue as? String
        }
        
        test?.test = 200
    }
    @IBAction func setTextValue(_ sender: UIButton) {
        
        self.textField.text = self.textField.text
    }
}
