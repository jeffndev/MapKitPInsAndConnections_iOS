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
    func checkForExistingLocationForStudent( completion: (success: Bool, errorMessage: String?, hasExisting: Bool?) -> Void) {
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        guard let uid = app.UdacityUserId else {
            completion(success: false, errorMessage: "Could not find users UdacityUserId", hasExisting: nil)
            return
        }
        //probably want to push this logic/syntax for building the where string into the Provider..
        let extraParam = [ParseProvider.ParameterKeys.WhereKey: "{\"uniqueKey\": \"\(uid)\"}"]
        let provider = ParseProvider()
        provider.fetchStudentLocations(1, optionalParams: extraParam) { (success, errorMessage, handleStatus) in
            if success {
                completion(success: success, errorMessage: nil, hasExisting: !provider.locations.isEmpty)
            } else {
                completion(success: success, errorMessage: errorMessage, hasExisting: nil)
            }
        }
    }
    
    func addLocation(newLocation: StudentLocation) {
        
        
        //TODO:
//        ParseProvider.addLocation(newLocation) { (success, errorMessage) in
//            if success {
//                let indexPath = NSIndexPath(row: StudentLocations.sharedInstance().locations().count() ,path: 0)
//                for o in observers { o.add(newLocation, indexPath) }
//            }
//        }
    }
    
}