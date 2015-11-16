//
//  PinPostingViewController.swift
//  OnTheMap
//
//  Created by Jeff Newell on 11/13/15.
//  Copyright © 2015 Jeff Newell. All rights reserved.
//

import Foundation
import MapKit

class PinPostingViewController: UIViewController, MKMapViewDelegate, UITextViewDelegate, DataObserver {
    
    @IBOutlet weak var submitPinView: UIView!
    @IBOutlet weak var findPinView: UIView!
    
    @IBOutlet weak var mediaURLTextView: UITextView!
    @IBOutlet weak var locationEntryTextView: UITextView!
    @IBOutlet weak var mainMap: MKMapView!
    
    let MAP_LOCAL_ZOOM_WIDTH = 2000.0
    
    let placeholderTextMap = [1: "Enter your location here", 2: "Enter your Url here"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StudentLocations.sharedInstance.registerObserver(self)
        
        //Prepare the textviews with Placeholder texts
        locationEntryTextView.delegate = self
        mediaURLTextView.delegate = self
        locationEntryTextView.tag = 1
        locationEntryTextView.text = placeholderTextMap[locationEntryTextView.tag]!
        locationEntryTextView.textColor = UIColor.lightGrayColor()
        mediaURLTextView.tag = 2
        mediaURLTextView.text = placeholderTextMap[mediaURLTextView.tag]!
        mediaURLTextView.textColor = UIColor.lightGrayColor()
        //
        
        
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
        let g = CLGeocoder()
        g.geocodeAddressString(geoText) { (placemarks, error) in
            if error == nil {
                if placemarks!.count > 0 {
                    let place = placemarks![0]
                    let loc = place.location
                    if let coord2ds = loc?.coordinate {
                        //create an annotation and add to map...
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = coord2ds
                        self.mainMap.addAnnotation(annotation)
                        self.mainMap.centerCoordinate = coord2ds
                        self.mainMap.region = MKCoordinateRegionMakeWithDistance(coord2ds,
                            self.MAP_LOCAL_ZOOM_WIDTH, self.MAP_LOCAL_ZOOM_WIDTH)
                        //hide the find button, open the map
                        self.findPinView.hidden = true
                        self.submitPinView.hidden = false
                    }
                }
            } else {
                let alert = UIAlertController()
                alert.title = "Location Not Found:"
                let okAction = UIAlertAction(title: "\(geoText)", style: .Default, handler: nil)
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
    
    //Mark: DATA OBSERVER
    func refresh() { }
    func add(newItem: AnyObject, indexPath: NSIndexPath) {
        //TODO: some sort of feedback that the data was saved to the
    }
    
    //Mark: UITextViewDelegates
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.whiteColor()
        }
    }
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderTextMap[textView.tag]
            textView.textColor = UIColor.lightGrayColor()
        }
    }
}