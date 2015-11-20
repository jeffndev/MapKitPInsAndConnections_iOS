//
//  ParseProvider.swift
//  OnTheMap
//
//  Created by Jeff Newell on 11/12/15.
//  Copyright © 2015 Jeff Newell. All rights reserved.
//

import Foundation

class ParseProvider {
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        
        static let WhereKey = "where"
        static let LimitKey = "limit"
        static let OrderKey = "order"
    }
    struct WhereQueryKeys {
        static let UserIDKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
    }
    
    let APPLICATION_ID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    let API_KEY = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    let BASE_API_URL_STRING = "https://api.parse.com/1/classes/"
    
    var locations = [StudentLocation]()
    var currentLocationObjectId: String?
    var currentLocationCreatedAt: String?
    var currentLocationUpdatedAt: String?
    
    
    /* JSON Sample...
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

    func fetchStudentLocations(limitNumRecords: Int = 100, optionalParams: [String: AnyObject]? = nil, completion: (success: Bool, errorMessage: String?, handleStatus: AppDelegate.ErrorsForUserFeedback?)-> Void) {
        
        let STUDENT_LOCATIONS_METHOD = "StudentLocation"
        var restParams: [String: AnyObject] = [ParameterKeys.LimitKey: limitNumRecords,
                                               ParameterKeys.OrderKey: "-updatedAt"]
        if let extraParams = optionalParams {
            for (key, val) in extraParams {
                restParams[key] = "\(val)"
            }
        }
        let requestString: String = BASE_API_URL_STRING + STUDENT_LOCATIONS_METHOD + RESTApiHelpers.assembleRestParamaters(restParams)
        
        guard let requestUrl = NSURL(string: requestString) else {
            print("could not build url from \(requestString)")
            completion(success: false, errorMessage: "could not build url from \(requestString)", handleStatus: AppDelegate.ErrorsForUserFeedback.LOCATIONS_DLOAD_FAILURE)
            return
        }
        let request = NSMutableURLRequest(URL: requestUrl)
        request.HTTPMethod = "GET"
        request.addValue(APPLICATION_ID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(API_KEY, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            guard (error == nil) else {
                completion(success: false, errorMessage: "There was an error with your request: \(error)", handleStatus: AppDelegate.ErrorsForUserFeedback.LOCATIONS_DLOAD_FAILURE)
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    completion(success: false, errorMessage: "Your request returned an invalid response! Status code: \(response.statusCode)!", handleStatus: AppDelegate.ErrorsForUserFeedback.LOCATIONS_DLOAD_FAILURE)
                } else if let response = response {
                    completion(success: false, errorMessage: "Your request returned an invalid response! Response: \(response)!", handleStatus: AppDelegate.ErrorsForUserFeedback.LOCATIONS_DLOAD_FAILURE)
                } else {
                    completion(success: false, errorMessage: "Your request returned an invalid response!", handleStatus: AppDelegate.ErrorsForUserFeedback.LOCATIONS_DLOAD_FAILURE)
                }
                return
            }
            
            guard let data = data else {
                completion(success: false, errorMessage: "Request data returned empty", handleStatus: AppDelegate.ErrorsForUserFeedback.LOCATIONS_DLOAD_FAILURE)
                return
            }
            
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                completion(success: false, errorMessage: "could not parse data as JSON", handleStatus: AppDelegate.ErrorsForUserFeedback.LOCATIONS_DLOAD_FAILURE)
                return
            }
            //now start parsing it out and get those locations!
            guard let locationObjects = parsedResult["results"] as? [[String: AnyObject]] else {
                completion(success: false, errorMessage: "Could not parse the Results from the JSON returned", handleStatus: AppDelegate.ErrorsForUserFeedback.LOCATIONS_DLOAD_FAILURE)
                return
            }
            
            for loc in locationObjects {
                self.locations.append(StudentLocation(json: loc))
            }
            if !self.locations.isEmpty {
                //the First Object Id
                self.currentLocationObjectId = self.locations[0].objectId
            }
            completion(success: true, errorMessage: nil, handleStatus: nil)
        }
        task.resume()
    }
    
    
    func buildPOSTLocationBody(location: StudentLocation) -> String {
        guard let uid = location.uniqueKey, let lat = location.latitude, let lon = location.longitude else {
            return ""
        }
        return "{\"uniqueKey\": \"\(uid)\", \"firstName\": \"\(location.firstName ?? "")\", \"lastName\": \"\(location.lastName ?? "")\",\"mapString\": \"\(location.mapString ?? "")\", \"mediaURL\": \"\(location.mediaURL ?? "")\",\"latitude\": \(lat), \"longitude\": \(lon) }"
    }
    
    func addLocation(newLocation: StudentLocation, completion: (success: Bool, errorMessage: String?, handleStatus: AppDelegate.ErrorsForUserFeedback?) -> Void) {
        let STUDENT_LOCATIONS_METHOD = "StudentLocation"
        let requestString: String = BASE_API_URL_STRING + STUDENT_LOCATIONS_METHOD
        
        guard let requestUrl = NSURL(string: requestString) else {
            print("could not build url from \(requestString)")
            completion(success: false, errorMessage: "could not build url from \(requestString)", handleStatus: AppDelegate.ErrorsForUserFeedback.POST_PIN_FAILURE)
            return
        }
        let request = NSMutableURLRequest(URL: requestUrl)
        request.HTTPMethod = "POST"
        request.addValue(APPLICATION_ID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(API_KEY, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = buildPOSTLocationBody(newLocation).dataUsingEncoding(NSUTF8StringEncoding)
       
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            guard (error == nil) else {
                completion(success: false, errorMessage: "There was an error with your request: \(error)", handleStatus: AppDelegate.ErrorsForUserFeedback.POST_PIN_FAILURE)
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    completion(success: false, errorMessage: "Your request returned an invalid response! Status code: \(response.statusCode)!",  handleStatus: AppDelegate.ErrorsForUserFeedback.POST_PIN_FAILURE)
                } else if let response = response {
                    completion(success: false, errorMessage: "Your request returned an invalid response! Response: \(response)!", handleStatus: AppDelegate.ErrorsForUserFeedback.POST_PIN_FAILURE)
                } else {
                    completion(success: false, errorMessage: "Your request returned an invalid response!", handleStatus: AppDelegate.ErrorsForUserFeedback.POST_PIN_FAILURE)
                }
                return
            }
            
            guard let data = data else {
                completion(success: false, errorMessage: "Request data returned empty", handleStatus: AppDelegate.ErrorsForUserFeedback.POST_PIN_FAILURE)
                return
            }
            
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                completion(success: false, errorMessage: "could not parse data as JSON", handleStatus: AppDelegate.ErrorsForUserFeedback.POST_PIN_FAILURE)
                return
            }
            
            //now start parsing it out and get those locations!
            guard let objId = parsedResult["objectId"] as? String, let createdAt = parsedResult["createdAt"] as? String else {
                completion(success: false, errorMessage: "could not parse out new objectId and create date", handleStatus: AppDelegate.ErrorsForUserFeedback.POST_PIN_FAILURE)
                return
            }
            self.currentLocationObjectId = objId
            self.currentLocationCreatedAt = createdAt
            completion(success: true, errorMessage: nil, handleStatus: nil)
        }
        task.resume()
    }
    
    func updateLocation(location: StudentLocation, completion: (success: Bool, errorMessage: String?, handleStatus: AppDelegate.ErrorsForUserFeedback?) -> Void) {
        guard let objId = location.objectId else {
            completion(success: false, errorMessage: "no ObjectId to update", handleStatus: AppDelegate.ErrorsForUserFeedback.POST_PIN_FAILURE)
            return
        }
        let STUDENT_LOCATIONS_METHOD = "StudentLocation/\(objId)"
        let requestString: String = BASE_API_URL_STRING + STUDENT_LOCATIONS_METHOD
        
        guard let requestUrl = NSURL(string: requestString) else {
            print("could not build url from \(requestString)")
            completion(success: false, errorMessage: "could not build url from \(requestString)", handleStatus: AppDelegate.ErrorsForUserFeedback.POST_PIN_FAILURE)
            return
        }
        let request = NSMutableURLRequest(URL: requestUrl)
        request.HTTPMethod = "PUT"
        request.addValue(APPLICATION_ID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(API_KEY, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = buildPOSTLocationBody(location).dataUsingEncoding(NSUTF8StringEncoding)
        print(buildPOSTLocationBody(location))
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            guard (error == nil) else {
                completion(success: false, errorMessage: "There was an error with your request: \(error)", handleStatus: AppDelegate.ErrorsForUserFeedback.POST_PIN_FAILURE)
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    completion(success: false, errorMessage: "Your request returned an invalid response! Status code: \(response.statusCode)!",  handleStatus: AppDelegate.ErrorsForUserFeedback.POST_PIN_FAILURE)
                } else if let response = response {
                    completion(success: false, errorMessage: "Your request returned an invalid response! Response: \(response)!", handleStatus: AppDelegate.ErrorsForUserFeedback.POST_PIN_FAILURE)
                } else {
                    completion(success: false, errorMessage: "Your request returned an invalid response!", handleStatus: AppDelegate.ErrorsForUserFeedback.POST_PIN_FAILURE)
                }
                return
            }
            
            guard let data = data else {
                completion(success: false, errorMessage: "Request data returned empty", handleStatus: AppDelegate.ErrorsForUserFeedback.POST_PIN_FAILURE)
                return
            }
            
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                completion(success: false, errorMessage: "could not parse data as JSON", handleStatus: AppDelegate.ErrorsForUserFeedback.POST_PIN_FAILURE)
                return
            }
            
            //now start parsing it out 
            guard let updatedAt = parsedResult["updatedAt"] as? String else {
                completion(success: false, errorMessage: "could not parse out new objectId and create date", handleStatus: AppDelegate.ErrorsForUserFeedback.POST_PIN_FAILURE)
                return
            }
            self.currentLocationUpdatedAt = updatedAt
            completion(success: true, errorMessage: nil, handleStatus: nil)
        }
        task.resume()
    }
}