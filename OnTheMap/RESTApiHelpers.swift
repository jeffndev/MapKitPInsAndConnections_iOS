//
//  RESTApiHelpers.swift
//  OnTheMap
//
//  Created by Jeff Newell on 11/12/15.
//  Copyright © 2015 Jeff Newell. All rights reserved.
//

import Foundation

struct RESTApiHelpers {
    
    static func urlEncode(text: String?) -> String? {
        if let strToEncode = text {
            return strToEncode.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        } else {
            return text
        }
    }
    static func assembleRestParamaters(parameters: [String: AnyObject]) -> String {
        var encodedParametersChunks = [String]()
        for (key, val) in parameters {
            let value = "\(val)"
            if let encodedVal = urlEncode(value) {
                encodedParametersChunks.append("\(key)=\(encodedVal)")
            }
        }
        return encodedParametersChunks.count == 0 ? "" : "?\(encodedParametersChunks.joinWithSeparator("&"))"
    }
    
}

