//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Jeff Newell on 11/10/15.
//  Copyright © 2015 Jeff Newell. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        
        let leftSpacerFrame = CGRectMake(0.0, 0.0, 13.0, 0.0)
        emailTextField.leftView = UIView(frame: leftSpacerFrame)
        emailTextField.leftViewMode = .Always
        passwordTextField.leftView = UIView(frame: leftSpacerFrame)
        passwordTextField.leftViewMode = .Always
        
        
    }
    
    @IBAction func facebookSignInAction(sender: UIButton) {
    }
    @IBAction func loginAction(sender: UIButton) {
    }
}
