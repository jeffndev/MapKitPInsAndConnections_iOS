//
//  UdacityUserCredentials.swift
//  OnTheMap
//
//  Created by Jeff Newell on 11/18/15.
//  Copyright © 2015 Jeff Newell. All rights reserved.
//

import Foundation
import FBSDKLoginKit

class UdacityUserCredentials {
    static let sharedInstance = UdacityUserCredentials()
    
    var UserId: String?
    var SessionId: String?
    var UserFirstName: String?
    var UserLastName: String?
    var FacebookConnectID: String?
    
    func logout(completion: (success: Bool, errMessage: String?, handleStatus: AppDelegate.ErrorsForUserFeedback?) ->Void) {
        let provider = UdacityProvider()
        provider.deleteLoginSession(completion)
        let fb = FBSDKLoginManager()
        fb.logOut()
    }
    
    func login(email: String, password: String, completion: (success: Bool, errMessage: String?, handleStatus: AppDelegate.ErrorsForUserFeedback?) ->Void) {
        let provider = UdacityProvider()
        provider.loginDirect(email, password: password) { (success, errMsg, handleType) in
            if success && provider.UserIDKey != nil {
                self.UserId = provider.UserIDKey
                self.SessionId = provider.SessionID
                provider.fetchPublicUserInfo(provider.UserIDKey!) { (success, errMsg, handlerType) in
                    self.UserFirstName = provider.UserFirstName
                    self.UserLastName = provider.UserLastName
                    self.FacebookConnectID = provider.UserFacebookId
                }

            }
            completion(success: success, errMessage: errMsg, handleStatus: handleType)
        }
    }
    func facebookLogin(mobileToken: String, completion: (success: Bool, errMessage: String?, handleStatus: AppDelegate.ErrorsForUserFeedback?) ->Void) {
        let provider = UdacityProvider()
        provider.facebookLogin(mobileToken) { (success, errMsg, handleType) in
            if success && provider.UserIDKey != nil {
                self.UserId = provider.UserIDKey
                self.SessionId = provider.SessionID
                provider.fetchPublicUserInfo(provider.UserIDKey!) { (success, errMsg, handlerType) in
                    self.UserFirstName = provider.UserFirstName
                    self.UserLastName = provider.UserLastName
                    self.FacebookConnectID = provider.UserFacebookId
                }
                
            }
            completion(success: success, errMessage: errMsg, handleStatus: handleType)
        }
    }
}