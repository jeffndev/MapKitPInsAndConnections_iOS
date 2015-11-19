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
    
    var tapRecognizer: UITapGestureRecognizer?
    var keyboardAdjusted = false

    
    //MARK: Lifecycle overrides..
    override func viewDidLoad() {
        let leftSpacerFrame = CGRectMake(0.0, 0.0, 13.0, 0.0)
        emailTextField.leftView = UIView(frame: leftSpacerFrame)
        emailTextField.leftViewMode = .Always
        passwordTextField.leftView = UIView(frame: leftSpacerFrame)
        passwordTextField.leftViewMode = .Always
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        view.addGestureRecognizer(tapRecognizer!)
        registerForKeyboardNotifications()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        view.removeGestureRecognizer(tapRecognizer!)
        unregisterForKeyboardNotifications()
    }
    
    
    //MARK: Actions...
    @IBAction func udacitySignUpAction(sender: UIButton) {
        if let udacitySignUpUrl = NSURL(string: UdacityProvider.SIGNUP_URL_STRING) {
            UIApplication.sharedApplication().openURL(udacitySignUpUrl)
        }
    }
    @IBAction func facebookSignInAction(sender: UIButton) {
        //TODO:
    }
    
    
    @IBAction func loginAction(sender: UIButton) {
        var oldPlaceholder = emailTextField!.placeholder
        guard let emailText = emailTextField!.text where emailText.characters.count > 0 else {
            emailTextField.placeholder = "Please Enter Your Email!"
            return
        }
        emailTextField.placeholder = oldPlaceholder
        oldPlaceholder = passwordTextField.placeholder
        guard let passwordText = passwordTextField!.text where passwordText.characters.count > 0 else {
            passwordTextField.placeholder = "Please Enter Your Password!"
            return
        }
        passwordTextField.placeholder = oldPlaceholder
        UdacityUserCredentials.sharedInstance.login(emailText, password: passwordText) { (success, errMsg, handlerType) in
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    let vc = self.storyboard!.instantiateViewControllerWithIdentifier("MainTabScreen") as! UITabBarController
                    self.presentViewController(vc, animated: true, completion: nil)
                }
            } else {
                if let customErrorType = handlerType where [AppDelegate.ErrorsForUserFeedback.FAILED_NETWORK, AppDelegate.ErrorsForUserFeedback.AUTHENTICATION_EXCEPTION].contains(customErrorType){
                    dispatch_async(dispatch_get_main_queue()){
                        var shortMsg: String
                        if customErrorType == AppDelegate.ErrorsForUserFeedback.AUTHENTICATION_EXCEPTION {
                            shortMsg = "Login Failure, Sign-up if no account."
                        } else {
                            shortMsg = "Network Failure, could not Login."
                        }
                        let alert = UIAlertController(title: "Login Alert", message: shortMsg, preferredStyle: .Alert)
                        let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                        alert.addAction(okAction)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    //MARK: helper functions
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    func keyboardWillShow(notification: NSNotification) {
        if !keyboardAdjusted {
            self.view.superview?.frame.origin.y -= getKeyboardHeight(notification)/2
            keyboardAdjusted = true
        }
    }
    func keyboardWillHide(notification: NSNotification) {
        if keyboardAdjusted {
            self.view.superview?.frame.origin.y += getKeyboardHeight(notification)/2
            keyboardAdjusted = false
        }
    }
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func registerForKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    func unregisterForKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

}
