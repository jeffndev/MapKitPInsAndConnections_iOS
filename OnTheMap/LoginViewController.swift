//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Jeff Newell on 11/10/15.
//  Copyright © 2015 Jeff Newell. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var udacityLoginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var tapRecognizer: UITapGestureRecognizer?
    var keyboardAdjusted = false

    
    //MARK: Lifecycle overrides..
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftSpacerFrame = CGRectMake(0.0, 0.0, 13.0, 0.0)
        emailTextField.leftView = UIView(frame: leftSpacerFrame)
        emailTextField.leftViewMode = .Always
        passwordTextField.leftView = UIView(frame: leftSpacerFrame)
        passwordTextField.leftViewMode = .Always
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        
        setupFacebookLoginButton()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        view.addGestureRecognizer(tapRecognizer!)
        registerForKeyboardNotifications()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let token = FBSDKAccessToken.currentAccessToken() {
            if let tokenString = token.tokenString {
                udacityLoginWithFacebookToken(tokenString)
            }
        }
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
    //FacebookLogin Delegates
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        //print(FBSDKSettings.sdkVersion())
        guard let token = FBSDKAccessToken.currentAccessToken() where token.tokenString != nil else {
            let alert = UIAlertController(title: "Facebook Login Alert", message: "Could not authenticate with Facebook.", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        udacityLoginWithFacebookToken(token.tokenString)
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        //empty
    }
    
    //MARK: helper functions
    func udacityLoginWithFacebookToken(fbookToken: String) {
        UdacityUserCredentials.sharedInstance.facebookLogin(fbookToken) { (success, errMsg, handlerType) in
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
                            shortMsg = "Udacity Login Failure, Sign-up if no account."
                        } else {
                            shortMsg = "Network Failure, could not Login to Udacity."
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
    //MARK: Helper methods UI
    func setupFacebookLoginButton() {
        //setup facebook login button...
        let fbookLogin = FBSDKLoginButton()
        
        fbookLogin.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fbookLogin)
        let alignLeadingToLoginBtn = NSLayoutConstraint(item: fbookLogin, attribute: .Leading, relatedBy: .Equal, toItem: udacityLoginButton, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        let alignTrailingToLoginBtn = NSLayoutConstraint(item: fbookLogin, attribute: .Trailing, relatedBy: .Equal, toItem: udacityLoginButton, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        let pinToBottonLayout = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: fbookLogin , attribute: .BottomMargin, multiplier: 1.0, constant: 26.0)
        let btnHeight = NSLayoutConstraint(item: fbookLogin, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40.0)
        
        fbookLogin.readPermissions = ["public_profile", "email", "user_friends"]
        fbookLogin.delegate = self
        NSLayoutConstraint.activateConstraints([alignLeadingToLoginBtn, alignTrailingToLoginBtn, pinToBottonLayout, btnHeight])
    }
    
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
