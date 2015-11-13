//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Jeff Newell on 11/10/15.
//  Copyright © 2015 Jeff Newell. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, DataObserver {
    
    
    
    @IBOutlet weak var mainMap: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StudentLocations.sharedInstance.registerObserver(self)
        if StudentLocations.sharedInstance.isPopulated() {
            loadPins()
        } else {
            StudentLocations.sharedInstance.fetchLocations()
        }
    }
    
    func loadPins() {
        let locations = StudentLocations.sharedInstance.locations()
        
        var annotations = [MKPointAnnotation]()
        //first remove all existing annotations
        self.mainMap.removeAnnotations(self.mainMap.annotations)

        for l in locations {
            let lat = CLLocationDegrees(l.latitude)
            let long = CLLocationDegrees(l.longitude)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(l.firstName) \(l.lastName)"
            annotation.subtitle = l.mediaURL
            
            annotations.append(annotation)
        }
        self.mainMap.addAnnotations(annotations)
    }
    
    @IBAction func refreshDataAction(sender: UIBarButtonItem) {
        print("refresh...from MapView...")
        StudentLocations.sharedInstance.fetchLocations()
    }
    
    @IBAction func addNewPinAction(sender: UIBarButtonItem) {
        //TODO: just present the new view controller modally on this..
    }
    
    //DATA OBSERVER
    func refresh() {
        dispatch_async(dispatch_get_main_queue(), { self.loadPins() })
    }
    func add(newItem: AnyObject, indexPath: NSIndexPath) {
        if let newLocation = newItem as? StudentLocation {
            let newPin = MKPointAnnotation()
            let lat = CLLocationDegrees(newLocation.latitude)
            let long = CLLocationDegrees(newLocation.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            newPin.coordinate = coordinate
            newPin.title = "\(newLocation.firstName) \(newLocation.lastName)"
            newPin.subtitle = newLocation.mediaURL
            
            mainMap.addAnnotation(newPin)
        }
    }
}
