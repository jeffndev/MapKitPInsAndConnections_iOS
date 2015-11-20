//
//  StudentLocations.swift
//  OnTheMap
//
//  Created by Jeff Newell on 11/13/15.
//  Copyright © 2015 Jeff Newell. All rights reserved.
//

import UIKit

class StudentLocations {
    static let sharedInstance = StudentLocations()
    
    private var observers = [DataObserver]()
    
    private	var mLocations = [StudentLocation]()
    
    func registerObserver(observer: DataObserver) { observers.append(observer) }
    func locations() ->[StudentLocation] { return mLocations }
    func isPopulated() -> Bool { return !mLocations.isEmpty }
    
    func fetchLocations(completion: (success:Bool) -> Void) {
        //an async task
        let provider = ParseProvider()
        provider.fetchStudentLocations(){ (newLocations, success, errorMessage, handlerType) in
            if success {
                self.mLocations.removeAll()
                self.mLocations.appendContentsOf(newLocations)
                for o in self.observers { o.refresh() }
            }
            completion(success: success)
        }
    }
    func checkForExistingLocationForStudent(atLocation: String? = nil ,completion: (success: Bool, firstObjectId: String?, errorMessage: String?, hasExisting: Bool?) -> Void) {
        guard let uid = UdacityUserCredentials.sharedInstance.UserId else {
            completion(success: false, firstObjectId: nil, errorMessage: "Could not find users UdacityUserId", hasExisting: nil)
            return
        }
        
        var extraParams: [String: String]
        if let mapString = atLocation {
            extraParams = [ParseProvider.ParameterKeys.WhereKey: "{\"uniqueKey\": \"\(uid)\", \"mapString\": \"\(mapString)\"}"]
        } else {
            extraParams = [ParseProvider.ParameterKeys.WhereKey: "{\"uniqueKey\": \"\(uid)\"}"]
        }
        let provider = ParseProvider()
        provider.fetchStudentLocations(1, optionalParams: extraParams) { (foundLocations, success, errorMessage, handleStatus) in
            if success {
                var firstFoundObjectId: String? = nil
                if !foundLocations.isEmpty {
                    firstFoundObjectId = foundLocations[0].objectId
                }
                completion(success: success, firstObjectId: firstFoundObjectId, errorMessage: nil, hasExisting: !foundLocations.isEmpty)
            } else {
                completion(success: success, firstObjectId: nil, errorMessage: errorMessage, hasExisting: nil)
            }
        }
    }
    
    func addLocation(newLoc: StudentLocation, completion: (success: Bool, errorMessage: String?) -> Void) {
        let provider = ParseProvider()
        provider.addLocation(newLoc) { (returnedLocation, success, errorMessage, handleType) in
            if success && returnedLocation != nil{
                //put it at the begining, newest data...
                self.mLocations.insert(returnedLocation!, atIndex: 0)
                let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                for o in self.observers { o.add(returnedLocation!, indexPath: indexPath) }
                completion(success: true, errorMessage: nil)
            } else {
                completion(success: false, errorMessage: errorMessage)
            }
        }
    }
    func updateLocation(newLoc: StudentLocation, completion: (success: Bool, errorMessage: String?) -> Void) {
        let provider = ParseProvider()
        provider.updateLocation(newLoc) { (updatedLocation, success, errorMessage, handleType) in
            completion(success: success, errorMessage: errorMessage)
        }
    }

    
}