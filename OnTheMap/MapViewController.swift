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
        ParseProvider.fetchStudentLocations() { (success, errMsg) in
            if success == true {
                dispatch_async(dispatch_get_main_queue(), { self.addMapPins() } )
            } else {
                //TODO: error logging and feedback structure...
                print(errMsg!)
            }
        }
    }
    
    func addMapPins() {
        let locations = ParseProvider.getSharedStudentLocations()
        
        var annotations = [MKPointAnnotation]()

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
}
