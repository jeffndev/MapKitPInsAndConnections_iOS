//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Jeff Newell on 11/12/15.
//  Copyright © 2015 Jeff Newell. All rights reserved.
//

import Foundation

struct StudentLocation {
    
    var objectId:   String?
    var uniqueKey:  String?
    var firstName:  String?
    var lastName:   String?
    var createdAt:  String?
    var updatedAt:  String?
    var mapString:  String?
    var mediaURL:   String?
    var latitude:   Float?
    var longitude:  Float?
    
    init() {}
    
    init(json: [String: AnyObject]) {
        objectId =  json["objectId"]    as? String
        uniqueKey = json["uniqueKey"]   as? String
        firstName = json["firstName"]   as? String
        lastName =  json["lastName"]    as? String
        createdAt = json["createdAt"]   as? String
        updatedAt = json["updatedAt"]   as? String
        mapString = json["mapString"]   as? String
        mediaURL =  json["mediaURL"]    as? String
        latitude =  json["latitude"]    as? Float
        longitude = json["longitude"]   as? Float
    }
    
}