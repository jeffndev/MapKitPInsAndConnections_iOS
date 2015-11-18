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
        provider.fetchStudentLocations(){ (success, errorMessage, handlerType) in
            if success {
                self.mLocations.removeAll()
                self.mLocations.appendContentsOf(provider.locations)
                for o in self.observers { o.refresh() }
            }
            completion(success: success)
        }
    }
    func checkForExistingLocationForStudent(atLocation: String? = nil ,completion: (success: Bool, firstObjectId: String?, errorMessage: String?, hasExisting: Bool?) -> Void) {
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        guard let uid = app.UdacityUserId else {
            completion(success: false, firstObjectId: nil, errorMessage: "Could not find users UdacityUserId", hasExisting: nil)
            return
        }
        //probably want to push this logic/syntax for building the where string into the Provider..
        var extraParams: [String: String]
        if let mapString = atLocation {
            extraParams = [ParseProvider.ParameterKeys.WhereKey: "{\"uniqueKey\": \"\(uid)\", \"mapString\": \"\(mapString)\"}"]
        } else {
            extraParams = [ParseProvider.ParameterKeys.WhereKey: "{\"uniqueKey\": \"\(uid)\"}"]
        }
        let provider = ParseProvider()
        provider.fetchStudentLocations(1, optionalParams: extraParams) { (success, errorMessage, handleStatus) in
            if success {
                completion(success: success, firstObjectId: provider.currentLocationObjectId, errorMessage: nil, hasExisting: !provider.locations.isEmpty)
            } else {
                completion(success: success, firstObjectId: nil, errorMessage: errorMessage, hasExisting: nil)
            }
        }
    }
    
    func addLocation(newLoc: StudentLocation, completion: (success: Bool, errorMessage: String?) -> Void) {
        var newLocation = newLoc
        let provider = ParseProvider()
        provider.addLocation(newLocation) { (success, errorMessage, handleType) in
            if success {
                newLocation.objectId = provider.currentLocationObjectId
                newLocation.createdAt = provider.currentLocationCreatedAt
                //put it at the begining, newest data...
                self.mLocations.insert(newLocation, atIndex: 0)
                let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                for o in self.observers { o.add(newLocation, indexPath: indexPath) }
                completion(success: true, errorMessage: nil)
            } else {
                completion(success: false, errorMessage: errorMessage)
            }
        }
    }
    func updateLocation(newLoc: StudentLocation, completion: (success: Bool, errorMessage: String?) -> Void) {
        var newLocation = newLoc
        let provider = ParseProvider()
        provider.updateLocation(newLocation) { (success, errorMessage, handleType) in
            if success {
                newLocation.objectId = provider.currentLocationObjectId
                newLocation.createdAt = provider.currentLocationCreatedAt
                //TODO: deal with the updated item in the ui?? have to put in an update observer method..uh, maybe..
            }
            completion(success: success, errorMessage: errorMessage)
        }
    }

    
}