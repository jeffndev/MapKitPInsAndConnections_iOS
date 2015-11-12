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
    //var ACL: [String]!
    
    static func fromJSON(json: [String: AnyObject]) -> StudentLocation? {
        
        return StudentLocation(objectId: json["objectId"] as! String, uniqueKey: json["uniqueKey"] as! String, firstName: json["firstName"] as! String, lastName: json["lastName"] as! String, createdAt: json["createdAt"] as! String, updatedAt: json["updatedAt"] as! String, mapString: json["mapString"] as! String, mediaURL: json["mediaURL"] as! String, latitude: json["latitude"] as! Float, longitude: json["longitude"] as! Float)
    }
    
}