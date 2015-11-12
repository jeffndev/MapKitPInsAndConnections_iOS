//
//  ParseProvider.swift
//  OnTheMap
//
//  Created by Jeff Newell on 11/12/15.
//  Copyright © 2015 Jeff Newell. All rights reserved.
//

import Foundation

class ParseProvider {
    static let APPLICATION_ID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static let API_KEY = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    static let BASE_API_URL_STRING = "https://api.parse.com/1/classes/"
    
    private static var locations = [StudentLocation]()
    
    static func getSharedStudentLocations() -> [StudentLocation] { return locations }
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

    static func fetchStudentLocations(doRefresh: Bool = false, limitNumRecords: Int = 100, completion: (success: Bool, errorMessage: String?)-> Void) {
        if locations.count > 0 && doRefresh == false {
            completion(success: true, errorMessage: nil)
            return
        } else {
            //let FETCH_LIMIT = 100
            let GET_STUDENT_LOCATIONS_METHOD = "StudentLocation"
            let restParams = ["limit": limitNumRecords]
            let requestString: String = ParseProvider.BASE_API_URL_STRING + GET_STUDENT_LOCATIONS_METHOD + RESTApiHelpers.assembleRestParamaters(restParams)
            print(requestString)
            guard let requestUrl = NSURL(string: requestString) else {
                //TODO: implement log and user feedback mechanism
                print("could not build url from \(requestString)")
                completion(success: false, errorMessage: "could not build url from \(requestString)")
                return
            }
            let request = NSMutableURLRequest(URL: requestUrl)
            request.HTTPMethod = "GET"
            request.addValue(ParseProvider.APPLICATION_ID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(ParseProvider.API_KEY, forHTTPHeaderField: "X-Parse-REST-API-Key")
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) { (data, response, error) in
                guard (error == nil) else {
                    //TODO: implement log and user feedback mechanism
                    completion(success: false, errorMessage: "There was an error with your request: \(error)")
                    return
                }
                
                guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                    if let response = response as? NSHTTPURLResponse {
                        //TODO: implement log and user feedback mechanism
                        completion(success: false, errorMessage: "Your request returned an invalid response! Status code: \(response.statusCode)!")
                    } else if let response = response {
                        //TODO: implement log and user feedback mechanism
                        completion(success: false, errorMessage: "Your request returned an invalid response! Response: \(response)!")
                    } else {
                        //TODO: implement log and user feedback mechanism
                        completion(success: false, errorMessage: "Your request returned an invalid response!")
                    }
                    return
                }
                
                guard let data = data else {
                    //TODO: implement log and user feedback mechanism
                    completion(success: false, errorMessage: "Request data returned empty")
                    return
                }
                
                var parsedResult: AnyObject!
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                } catch {
                    //TODO: implement log and user feedback mechanism
                    completion(success: false, errorMessage: "could not parse data as JSON")
                    return
                }
                //print(parsedResult)
                //now start parsing it out and get those locations!
                guard let locationObjects = parsedResult["results"] as? [[String: AnyObject]] else {
                    //TODO: implement log and user feedback mechanism
                    completion(success: false, errorMessage: "Could not parse the Results from the JSON returned")
                    return
                }
                
                for loc in locationObjects {
                    if let objLocation = StudentLocation.fromJSON(loc) {
                        locations.append(objLocation)
                    }
                }
                print("Locations count: \(self.locations.count)")
                completion(success: true, errorMessage: nil)
            }
            task.resume()
        }
    }
    
}