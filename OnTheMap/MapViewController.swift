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
    
    var locations = [StudentLocation]()
    
    @IBOutlet weak var mainMap: MKMapView!
    
    override func viewDidLoad() {
        //As a way to get started, lets fetch locations data
        fetchLocations()
        addMapPins()
    }
    func addMapPins() {
        var annotations = [MKPointAnnotation]()

        for l in locations {
            print(l.firstName)
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
    /*
    "results":[
    {
    "createdAt": "2015-02-25T01:10:38.103Z",
    "firstName": "Jarrod",
    "lastName": "Parkes",
    "latitude": 34.7303688,
    "longitude": -86.5861037,
    "mapString": "Huntsville, Alabama ",
    "mediaURL": "https://www.linkedin.com/in/jarrodparkes",
    "objectId": "JhOtcRkxsh",
    "uniqueKey": "996618664",
    "updatedAt": "2015-03-09T22:04:50.315Z"
    }
    {
    "createdAt":"2015-02-24T22:27:14.456Z",
    "firstName":"Jessica",
    "lastName":"Uelmen",
    "latitude":28.1461248,
    "longitude":-82.756768,
    "mapString":"Tarpon Springs, FL",
    "mediaURL":"www.linkedin.com/in/jessicauelmen/en",
    "objectId":"kj18GEaWD8",
    "uniqueKey":"872458750",
    "updatedAt":"2015-03-09T22:07:09.593Z"
    },
    */
    
    func fetchLocations() {
        let FETCH_LIMIT = 100
        let GET_STUDENT_LOCATIONS_METHOD = "StudentLocation"
        let restParams = ["limit": FETCH_LIMIT]
        let requestString: String = ParseProvider.BASE_API_URL_STRING + GET_STUDENT_LOCATIONS_METHOD + RESTApiHelpers.assembleRestParamaters(restParams)
        print(requestString)
        guard let requestUrl = NSURL(string: requestString) else {
            //TODO: implement log and user feedback mechanism
            print("could not build url from \(requestString)")
            return
        }
        let request = NSMutableURLRequest(URL: requestUrl)
        request.HTTPMethod = "GET"
        request.addValue(ParseProvider.APPLICATION_ID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseProvider.API_KEY, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            print("within the task..")
            guard (error == nil) else {
                //TODO: implement log and user feedback mechanism
                //print("There was an error with your request: \(error)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    //TODO: implement log and user feedback mechanism
                    //print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    //TODO: implement log and user feedback mechanism
                    //print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    //TODO: implement log and user feedback mechanism
                    //print("Your request returned an invalid response!")
                }
                return
            }
            
            guard let data = data else {
                //TODO: implement log and user feedback mechanism
                return
            }
            
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                //TODO: implement log and user feedback mechanism
                return
            }
            //print(parsedResult)
            //now start parsing it out and get those locations!
            guard let locationObjects = parsedResult["results"] as? [[String: AnyObject]] else {
                //TODO: implement log and user feedback mechanism
                return
            }
            
            for loc in locationObjects {
                if let objLocation = StudentLocation.fromJSON(loc) {
                    self.locations.append(objLocation)
                }
            }
            print("Locations count: \(self.locations.count)")
            dispatch_async(dispatch_get_main_queue()) {
                self.addMapPins()
            }
            
        }
        task.resume()
        
    }
    
}
