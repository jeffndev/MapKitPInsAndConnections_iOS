//
//  UdacityProvider.swift
//  OnTheMap
//
//  Created by Jeff Newell on 11/11/15.
//  Copyright © 2015 Jeff Newell. All rights reserved.
//

import UIKit

class UdacityProvider {
    static let SIGNUP_URL_STRING = "https://www.udacity.com/account/auth#!/signup"
    private static let BASE_API_URL_STRING = "https://www.udacity.com/api/"
    
    var UserIDKey: String?
    var SessionID: String?
    var UserFirstName: String?
    var UserLastName: String?
    var UserFacebookId: String?
    
    
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
    
    func loginDirect(email: String, password: String, completion: (success: Bool, errMsg: String?, handleStatus: AppDelegate.ErrorsForUserFeedback?) -> Void ){
        let postParameters = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}"
        loginAction(postParameters, completion: completion)
    }
    func facebookLogin(fbookToken: String, completion: (success: Bool, errMsg: String?, handleStatus: AppDelegate.ErrorsForUserFeedback?) -> Void) {
        let postParameters = "{\"facebook_mobile\": {\"access_token\": \"\(fbookToken)\"}}"
        loginAction(postParameters, completion: completion)
    }
    
    private func loginAction(loginPayloadForPOST: String, completion: (success: Bool, errMsg: String?, handleStatus: AppDelegate.ErrorsForUserFeedback?) -> Void) {
        let LOGIN_SESSION_METHOD = "session"
        
        let requestString = UdacityProvider.BASE_API_URL_STRING + LOGIN_SESSION_METHOD
        guard let requestUrl = NSURL(string: requestString) else {
            completion(success: false, errMsg: "could not parse a URL from \(requestString)", handleStatus: nil)
            return
        }
        let request = NSMutableURLRequest(URL: requestUrl)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = loginPayloadForPOST.dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            guard (error == nil) else {
                completion(success: false, errMsg: "There was an error with your request: \(error)", handleStatus: AppDelegate.ErrorsForUserFeedback.FAILED_NETWORK)
                return
            }
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    if(response.statusCode == 403){
                        completion(success: false, errMsg: "Your request returned an invalid response! Status code: \(response.statusCode)!", handleStatus: AppDelegate.ErrorsForUserFeedback.AUTHENTICATION_EXCEPTION)
                    }else {
                        completion(success: false, errMsg: "Your request returned an invalid response! Status code: \(response.statusCode)!", handleStatus: nil)
                    }
                } else if let response = response {
                    completion(success: false, errMsg: "Your request returned an invalid response! Response: \(response)!", handleStatus: nil)
                } else {
                    completion(success: false, errMsg: "Your request returned an invalid response!", handleStatus: nil)
                }
                return
            }
            
            guard let data = data else {
                completion(success: false, errMsg: "data from JSON request came up empty", handleStatus: nil)
                return
            }
            let trimmedData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(trimmedData, options: .AllowFragments)
            } catch {
                completion(success: false, errMsg: "Data could not be parsed as JSON", handleStatus: nil)
                return
            }
            //get the Account object registered: Bool, key: Int
            guard let accountInfo = parsedResult["account"] as? [String: AnyObject] else {
                completion(success: false, errMsg: "could not find account information in JSON response", handleStatus: nil)
                return
            }
            guard let registered = accountInfo["registered"] as? Bool else {
                completion(success: false, errMsg: "could not find valid registration in JSON response", handleStatus: nil)
                return
            }
            guard registered == true else {
                completion(success: false, errMsg: "User is not registered, please sign up for a Udacity account", handleStatus: AppDelegate.ErrorsForUserFeedback.AUTHENTICATION_EXCEPTION)
                return
            }
            guard let udacityUserId = accountInfo["key"] as? String else {
                //NOTE: probably can't move forward, since need this for all future request...
                //...then again, there is a lot of Public functionality, so maybe this might
                //....be better to just fail gracefully when those non-public api's are called..
                completion(success: false, errMsg: "Could not find a user id", handleStatus: nil)
                return
            }
            self.UserIDKey = udacityUserId
            if let sessionInfo = parsedResult["session"] as? [String: AnyObject] {
                if let sessionId = sessionInfo["id"] as? String {
                    self.SessionID = sessionId
                }
            }
            completion(success: true, errMsg: nil, handleStatus: nil)
        }
        
        task.resume()
    }
    
    func fetchPublicUserInfo(userId: String, completion: (success: Bool, errMsg: String?, handleStatus: AppDelegate.ErrorsForUserFeedback?) -> Void) {
        let GET_USER_METHOD = "users/\(userId)"
        
        let requestString = UdacityProvider.BASE_API_URL_STRING + GET_USER_METHOD
        guard let requestUrl = NSURL(string: requestString) else {
            completion(success: false, errMsg: "could not parse a URL from \(requestString)", handleStatus: nil)
            return
        }
        let request = NSMutableURLRequest(URL: requestUrl)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            guard (error == nil) else {
                completion(success: false, errMsg: "There was an error with your request: \(error)", handleStatus: AppDelegate.ErrorsForUserFeedback.FAILED_NETWORK)
                return
            }
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    if(response.statusCode == 403){
                        completion(success: false, errMsg: "Your request returned an invalid response! Status code: \(response.statusCode)!", handleStatus: nil)
                    }else {
                        completion(success: false, errMsg: "Your request returned an invalid response! Status code: \(response.statusCode)!", handleStatus: nil)
                    }
                } else if let response = response {
                    completion(success: false, errMsg: "Your request returned an invalid response! Response: \(response)!", handleStatus: nil)
                } else {
                    completion(success: false, errMsg: "Your request returned an invalid response!", handleStatus: nil)
                }
                return
            }
            
            guard let data = data else {
                completion(success: false, errMsg: "data from JSON request came up empty", handleStatus: nil)
                return
            }
            let trimmedData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(trimmedData, options: .AllowFragments)
            } catch {
                completion(success: false, errMsg: "Data could not be parsed as JSON", handleStatus: nil)
                return
            }
            print(parsedResult)
            guard let userInfo = parsedResult["user"] as? [String: AnyObject] else {
                completion(success: false, errMsg: "Could not parse out user information", handleStatus: nil)
                return
            }
            var parseFailures = [String]()
            if let fbookId = userInfo["_facebook_id"] as? String {
                self.UserFacebookId = fbookId
            }else {
                parseFailures.append("Facebook ID")
            }
            if let fname = userInfo["first_name"] as? String {
                self.UserFirstName = fname
            } else {
                parseFailures.append("First Name")
            }
            if let lname = userInfo["last_name"] as? String {
                self.UserLastName = lname
            } else {
                parseFailures.append("Last Name")
            }
            var parseProblemString: String? = nil
            if !parseFailures.isEmpty {
                parseProblemString = "Failed to parse User Information: " + parseFailures.joinWithSeparator(",")
            }
            completion(success: true, errMsg: parseProblemString, handleStatus: nil)
        }
        task.resume()
    }
    
    func deleteLoginSession(completion: (success: Bool, errMsg: String?, handleStatus: AppDelegate.ErrorsForUserFeedback?) -> Void){
        //TODO:
    }
}