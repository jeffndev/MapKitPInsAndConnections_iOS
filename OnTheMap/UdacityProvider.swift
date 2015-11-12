//
//  UdacityProvider.swift
//  OnTheMap
//
//  Created by Jeff Newell on 11/11/15.
//  Copyright © 2015 Jeff Newell. All rights reserved.
//

import Foundation

class UdacityProvider {
    static let SIGNUP_URL_STRING = "https://www.udacity.com/account/auth#!/signup"
    static let BASE_API_URL_STRING = "https://www.udacity.com/api/"
    
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
    static func loginAction(email: String, password: String, completion: (success: Bool, errMsg: String?) -> Void) {
        let LOGIN_SESSION_METHOD = "session"
        
        let requestString = UdacityProvider.BASE_API_URL_STRING + LOGIN_SESSION_METHOD
        //print(requestString)
        guard let requestUrl = NSURL(string: requestString) else {
            //TODO: implement log and user feedback mechanism
            completion(success: false, errMsg: "could not parse a URL from \(requestString)")
            return
        }
        let request = NSMutableURLRequest(URL: requestUrl)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let postParameters = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}"
        request.HTTPBody = postParameters.dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            guard (error == nil) else {
                //TODO: implement log and user feedback mechanism
                completion(success: false, errMsg: "There was an error with your request: \(error)")
                return
            }
            //TODO: think about how to handle 403 errors...could indicate to user that their credentials not recognized..
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    //TODO: implement log and user feedback mechanism
                    completion(success: false, errMsg: "Your request returned an invalid response! Status code: \(response.statusCode)!")
                    //TODO: LET USER KNOW if there is a 403 response, indicating probable bad credentials entered..
                } else if let response = response {
                    //TODO: implement log and user feedback mechanism
                    completion(success: false, errMsg: "Your request returned an invalid response! Response: \(response)!")
                } else {
                    //TODO: implement log and user feedback mechanism
                    completion(success: false, errMsg: "Your request returned an invalid response!")
                }
                return
            }
            
            guard let data = data else {
                //TODO: implement log and user feedback mechanism
                completion(success: false, errMsg: "data from JSON request came up empty")
                return
            }
            let trimmedData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(trimmedData, options: .AllowFragments)
            } catch {
                //TODO: implement log and user feedback mechanism
                completion(success: false, errMsg: "Data could not be parsed as JSON")
                return
            }
            //print(parsedResult)
            //get the Account object registered: Bool, key: Int
            guard let accountInfo = parsedResult["account"] as? [String: AnyObject] else {
                //TODO: implement log and user feedback mechanism
                completion(success: false, errMsg: "could not find account information in JSON response")
                return
            }
            guard let registered = accountInfo["registered"] as? Bool else {
                //TODO: implement log and user feedback mechanism
                completion(success: false, errMsg: "could not find valid registration in JSON response")
                return
            }
            guard registered == true else {
                //TODO: show not registered status feedback to user...direct them to sign up
                completion(success: false, errMsg: "User is not registered, please sign up for a Udacity account")
                return
            }
            guard let udacityUserId = accountInfo["key"] as? String else {
                //TODO: probably can't move forward, since need this for all future request...
                //...then again, there is a lot of Public functionality, so maybe this might
                //....be better to just fail gracefully when those non-public api's are called..
                completion(success: false, errMsg: "Could not find a user id")
                return
            }
            print("my userid: \(udacityUserId)")
            
            //dispatch_async(dispatch_get_main_queue()) {
            completion(success: true, errMsg: nil)
//                let vc = self.storyboard!.instantiateViewControllerWithIdentifier("MainTabScreen") as! UITabBarController
//                self.presentViewController(vc, animated: true, completion: nil)
//            }
        }
        
        task.resume()
    }
    
}