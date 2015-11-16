//
//  PinPostingViewController.swift
//  OnTheMap
//
//  Created by Jeff Newell on 11/13/15.
//  Copyright © 2015 Jeff Newell. All rights reserved.
//

import Foundation
import MapKit

class PinPostingViewController: UIViewController, MKMapViewDelegate, DataObserver {
    
    @IBOutlet weak var submitPinView: UIView!
    @IBOutlet weak var findPinView: UIView!
    
    @IBOutlet weak var locationEntryTextView: UITextView!
    @IBOutlet weak var mainMap: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewDidLoad called on PinPostingViewController")
        StudentLocations.sharedInstance.registerObserver(self)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        findPinView.hidden = false
        submitPinView.hidden = true
    }
    /*
    var address = "1 Infinite Loop, CA, USA"
    var geocoder = CLGeocoder()
    geocoder.geocodeAddressString(address, {(placemarks: [AnyObject]!, error: NSError!) -> Void in
    if let placemark = placemarks?[0] as? CLPlacemark {
    self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
    }
    })
    */
    @IBAction func findOnTheMap() {
        let geoText = locationEntryTextView.text
        //findPinView.hidden = true
        let g = CLGeocoder()
        g.geocodeAddressString(geoText) { (placemarks, error) in
            if error == nil {
                if placemarks!.count > 0 {
                    let place = placemarks![0] //as! CLPlacemark
                    let loc = place.location
                    let coord2ds = loc?.coordinate
                    //create an annotation and add to map...
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coord2ds!
                    self.mainMap.addAnnotation(annotation)
                    //hide the find button, open the map
                    self.findPinView.hidden = true
                    self.submitPinView.hidden = false
                }
            } else {
                let alert = UIAlertController()
                alert.title = "Not Found:"
                let okAction = UIAlertAction(title: "\(geoText)", style: .Default) { alert in
                    //self.dismissViewControllerAnimated(true, completion: nil)
                }
                alert.addAction(okAction)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    @IBAction func submitPinAction(sender: UIButton) {
        //TODO: deal with a simpler constuctor for StudentLocation, only have coords, name and a mediaURL
        //let newLocationPin =
        //
        //StudentLocations.sharedInstance.addLocation(newLocationPin)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelAction(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //DATA OBSERVER
    func refresh() { }
    func add(newItem: AnyObject, indexPath: NSIndexPath) {
        //TODO: some sort of feedback that the data was saved to the
    }
}