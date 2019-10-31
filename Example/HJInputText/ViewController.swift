//
//  ViewController.swift
//  HJInputText
//
//  Created by trongnhan68 on 10/31/2019.
//  Copyright (c) 2019 trongnhan68. All rights reserved.
//

import UIKit
import HJInputText

class ViewController: UIViewController, HJInputTextProtocol {
    func actionButtonDidTap() {
        
    }
    
    func textDidChanged(_ text: String?) {
        
    }
    
    
    func validateText(_ text: String?) -> HJInputTextValidation {
        if let text = text, text.count > 3 && text.count < 10 {
            textfield.hintText = "Your email is valid!"
            return .valid(nil)
        } else {
            var actionButtonTitle: String? = nil
            if let text = text, !text.isEmpty {
                actionButtonTitle = "Try again?"
            }
            textfield.hintText = "Please enter your email"
            return .invalid("Please enter valid text", actionButtonTitle)
        }
    }
    

    @IBOutlet weak var textfield: HJInputText!
    override func viewDidLoad() {
        super.viewDidLoad()
        var property = HJInputTextProperty()
        property.titleLabelTitle = "Email"
        property.titleLabelTextColorNormal = .black
        property.rightInvalidIcon = UIImage(named: "invalid.pdf")
        property.rightValidIcon = UIImage(named: "valid.pdf")

        textfield.hintText = "Please enter your email"
        
        textfield.delegate = self

        textfield.setProperty(property)
    }

}

