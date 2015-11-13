//
//  StudentLocations.swift
//  OnTheMap
//
//  Created by Jeff Newell on 11/13/15.
//  Copyright © 2015 Jeff Newell. All rights reserved.
//

import Foundation

class StudentLocations {
    static let sharedInstance = StudentLocations()
    
    private var observers = [DataObserver]()
    
    private	var mLocations = [StudentLocation]()
    
    func registerObserver(observer: DataObserver) { observers.append(observer) }
    func locations() ->[StudentLocation] { return mLocations }
    func isPopulated() -> Bool { return mLocations.count > 0 }
    func fetchLocations() {
        //an async task
        let provider = ParseProvider()
        provider.fetchStudentLocations(){ (success, errorMessage) in
            if success {
                self.mLocations.removeAll()
                self.mLocations.appendContentsOf(provider.locations)
                for o in self.observers { o.refresh() }
            } else {
                print(errorMessage)
            }
        }
    }
    func checkForExistingLocation(loc: StudentLocation) {
        //TODO:
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