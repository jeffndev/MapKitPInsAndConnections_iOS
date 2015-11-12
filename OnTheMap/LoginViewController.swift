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
    
    
    /* SAMPLE DATA
    {
    "account":{
            "registered":true,
            "key":"3903878747"
            },
    "session":{
            "id":"1457628510Sc18f2ad4cd3fb317fb8e028488694088",
            "expiration":"2015-05-10T16:48:30.760460Z"
            }
    }
    */
    @IBAction func loginAction(sender: UIButton) {
        let LOGIN_SESSION_METHOD = "session"
        
        let requestString = UdacityProvider.BASE_API_URL_STRING + LOGIN_SESSION_METHOD
        print(requestString)
        guard let requestUrl = NSURL(string: requestString) else {
            //TODO: implement log and user feedback mechanism
            return
        }
        let request = NSMutableURLRequest(URL: requestUrl)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let postParameters = "{\"udacity\": {\"username\": \"\(emailTextField.text!)\", \"password\": \"\(passwordTextField.text!)\"}}"
        request.HTTPBody = postParameters.dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            guard (error == nil) else {
                //TODO: implement log and user feedback mechanism
                //print("There was an error with your request: \(error)")
                return
            }
            //TODO: think about how to handle 403 errors...could indicate to user that their credentials not recognized..
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    //TODO: implement log and user feedback mechanism
                    //print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                    //TODO: LET USER KNOW if there is a 403 response, indicating probable bad credentials entered..
                } else if let response = response {
                    //TODO: implement log and user feedback mechanism
                    //print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    //TODO: implement log and user feedback mechanism
                    //print("Your request returned an invalid response!")
                }
                return
            }
            
            guard let data = data else {
                //TODO: implement log and user feedback mechanism
                return
            }
            let trimmedData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(trimmedData, options: .AllowFragments)
            } catch {
                //TODO: implement log and user feedback mechanism
                return
            }
            print(parsedResult)
            //get the Account object registered: Bool, key: Int
            guard let accountInfo = parsedResult["account"] as? [String: AnyObject] else {
                //TODO: implement log and user feedback mechanism
                return
            }
            guard let registered = accountInfo["registered"] as? Bool else {
                //TODO: implement log and user feedback mechanism
                return
            }
            guard registered == true else {
                //TODO: show not registered status feedback to user...direct them to sign up
                return
            }
            guard let udacityUserId = accountInfo["key"] as? String else {
                //TODO: probably can't move forward, since need this for all future request...
                //...then again, there is a lot of Public functionality, so maybe this might
                //....be better to just fail gracefully when those non-public api's are called..
                return
            }
            print("my userid: \(udacityUserId)")
            dispatch_async(dispatch_get_main_queue()) {
                    let vc = self.storyboard!.instantiateViewControllerWithIdentifier("MainTabScreen") as! UITabBarController
                    self.presentViewController(vc, animated: true, completion: nil)
            }
        }
        
        task.resume()
    }
}
