//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Jeff Newell on 11/12/15.
//  Copyright © 2015 Jeff Newell. All rights reserved.
//

import Foundation

struct StudentLocation {
    
    let objectId: String!
    let uniqueKey: String!
    let firstName: String!
    let lastName: String!
    let createdAt: String!
    
    var updatedAt: String!
    var mapString: String!
    var mediaURL: String!
    var latitude: Float!
    var longitude: Float!
    
    init(objectId: String, uniqueKey: String, firstName: String, lastName:  String, createdAt: String, updatedAt: String, mapString: String, mediaURL:  String, latitude: Float, longitude: Float) {
        self.objectId = objectId
        self.uniqueKey = uniqueKey
        self.firstName = firstName
        self.lastName = lastName
        self.createdAt = createdAt
        
        self.updatedAt = updatedAt
        self.mapString = mapString
        self.mediaURL = mediaURL
        self.latitude = latitude
        self.longitude = longitude
    }
    init(firstName: String, lastName: String, latitude: Float, longitude: Float) {
        self.firstName = firstName
        self.lastName = lastName
        self.latitude = latitude
        self.longitude = longitude
        self.objectId = nil
        self.uniqueKey = nil
        self.createdAt = nil
    }
    
//    static func fromJSON(json: [String: AnyObject]) -> StudentLocation? {
//        
//        return StudentLocation(objectId: json["objectId"] as! String, uniqueKey: json["uniqueKey"] as! String, firstName: json["firstName"] as! String, lastName: json["lastName"] as! String, createdAt: json["createdAt"] as! String, updatedAt: json["updatedAt"] as! String, mapString: json["mapString"] as! String, mediaURL: json["mediaURL"] as! String, latitude: json["latitude"] as! Float, longitude: json["longitude"] as! Float)
//    }
    init(json: [String: AnyObject]) {
        objectId =  json["objectId"] as! String
        uniqueKey = json["uniqueKey"] as! String
        firstName = json["firstName"] as! String
        lastName =  json["lastName"] as! String
        createdAt = json["createdAt"] as! String
        updatedAt = json["updatedAt"] as! String
        mapString = json["mapString"] as! String
        mediaURL =  json["mediaURL"] as! String
        latitude =  json["latitude"] as! Float
        longitude = json["longitude"] as! Float
    }
    
}