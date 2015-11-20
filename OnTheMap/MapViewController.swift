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
    
    //MARK: Lifecycle overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        StudentLocations.sharedInstance.registerObserver(self)
        if StudentLocations.sharedInstance.isPopulated() {
            loadPins()
        } else {
            StudentLocations.sharedInstance.fetchLocations(){ success in
                if !success {
                    dispatch_async(dispatch_get_main_queue()){
                        self.downloadFailureAlert()
                    }
                }
            }

        }
    }
   
    //MARK: helper methods
    func loadPins() {
        let locations = StudentLocations.sharedInstance.locations()
        
        var annotations = [MKPointAnnotation]()
        //first remove all existing annotations
        self.mainMap.removeAnnotations(self.mainMap.annotations)

        for l in locations {
            guard let lat = l.latitude, let long = l.longitude  else {
                continue
            }
            
            let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long))
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(l.firstName ?? "") \(l.lastName ?? "")"
            annotation.subtitle = l.mediaURL
            
            annotations.append(annotation)
        }
        self.mainMap.addAnnotations(annotations)
    }
    func downloadFailureAlert() {
        let alert = UIAlertController(title: "Data Alert", message: "Student Data Failed to Download", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: Actions
    @IBAction func refreshDataAction(sender: UIBarButtonItem) {
        StudentLocations.sharedInstance.fetchLocations(){ success in
            if !success {
                dispatch_async(dispatch_get_main_queue()){
                    self.downloadFailureAlert()
                }
            }
        }

    }
    
    @IBAction func logoutAction(sender: UIBarButtonItem) {
        UdacityUserCredentials.sharedInstance.logout() { (_,_,_) in }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addNewPinAction(sender: UIBarButtonItem) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("PinPostingViewController") as! PinPostingViewController
        presentViewController(vc, animated: true, completion: nil)
    }
    
    //MARK: DATA OBSERVER
    func refresh() {
        dispatch_async(dispatch_get_main_queue(), { self.loadPins() })
    }
    func add(newItem: Any, indexPath: NSIndexPath) {
        if let newLocation = newItem as? StudentLocation {
            guard let lat = newLocation.latitude, let long = newLocation.longitude else {
                return
            }
            let newPin = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long))
            newPin.coordinate = coordinate
            
            newPin.title = "\(newLocation.firstName ?? "") \(newLocation.lastName ?? "")"
            newPin.subtitle = newLocation.mediaURL
            mainMap.addAnnotation(newPin)
            //center the map on this new location
            mainMap.centerCoordinate = coordinate
        }
    }
    
    //MARK: MKMapViewDelegate
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                if let url = RESTApiHelpers.forgivingUrlFromString(toOpen) {
                    app.openURL(url)
                }

            }
        }

    }
}
