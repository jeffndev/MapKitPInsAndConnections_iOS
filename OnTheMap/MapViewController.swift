//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Jeff Newell on 11/10/15.
//  Copyright © 2015 Jeff Newell. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    
    
    @IBOutlet weak var mainMap: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLocations(false)
    }
    
    func loadLocations(doRefresh: Bool) {
        ParseProvider.fetchStudentLocations(doRefresh) { (success, errMsg) in
            if success == true {
                dispatch_async(dispatch_get_main_queue(), { self.addMapPins(doRefresh) } )
            } else {
                //TODO: error logging and feedback structure...
                print(errMsg!)
            }
        }
    }
    
    func addMapPins(doRefresh: Bool) {
        let locations = ParseProvider.getSharedStudentLocations()
        
        var annotations = [MKPointAnnotation]()
        //first remove all annotations, if this is a data refresh
        if doRefresh == true {
            self.mainMap.removeAnnotations(self.mainMap.annotations)
        }
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
    }
    
    @IBAction func addNewPinAction(sender: UIBarButtonItem) {
    }
}
