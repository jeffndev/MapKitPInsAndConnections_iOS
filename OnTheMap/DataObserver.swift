//
//  DataObserver.swift
//  OnTheMap
//
//  Created by Jeff Newell on 11/13/15.
//  Copyright © 2015 Jeff Newell. All rights reserved.
//

import Foundation

protocol DataObserver {
    func refresh()
    func add(newItem: AnyObject, indexPath: NSIndexPath)
}
