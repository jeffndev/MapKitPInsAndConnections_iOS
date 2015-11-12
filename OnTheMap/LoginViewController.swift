//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Jeff Newell on 11/10/15.
//  Copyright © 2015 Jeff Newell. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        
        let leftSpacerFrame = CGRectMake(0.0, 0.0, 13.0, 0.0)
        emailTextField.leftView = UIView(frame: leftSpacerFrame)
        emailTextField.leftViewMode = .Always
        passwordTextField.leftView = UIView(frame: leftSpacerFrame)
        passwordTextField.leftViewMode = .Always
        
        //TODO: use imageEdgeInset and titleEdgeInset on the facebookLoginButton to add the facebook logo to the right side
        //
    }
    
    @IBAction func udacitySignUpAction(sender: UIButton) {
        
        if let udacitySignUpUrl = NSURL(string: UdacityProvider.SIGNUP_URL_STRING) {
            UIApplication.sharedApplication().openURL(udacitySignUpUrl)
        }
    }
    @IBAction func facebookSignInAction(sender: UIButton) {
        
    }
    
    
    @IBAction func loginAction(sender: UIButton) {
        guard let emailText = emailTextField!.text where emailText.characters.count > 0 else {
            //TODO: notify that need to enter email!
            return
        }
        
        
        guard let passwordText = passwordTextField!.text where passwordText.characters.count > 0 else {
            //TODO: notify that need to enter password
            return
        }
        
        UdacityProvider.loginAction(emailText, password: passwordText) { (success, errMsg) in
            if success == true {
                dispatch_async(dispatch_get_main_queue()) {
                    let vc = self.storyboard!.instantiateViewControllerWithIdentifier("MainTabScreen") as! UITabBarController
                    self.presentViewController(vc, animated: true, completion: nil)
                }
            }else {
                //TODO: notifi of error
                print(errMsg!)
            }
        }
    }
        
}
