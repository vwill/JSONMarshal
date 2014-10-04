//
//  Location.swift
//  LocationApp
//
//  Created by Vaughn Williams on 2014/09/07.
//  Copyright (c) 2014 Vaughn Williams. All rights reserved.
//

import Foundation

@objc(Location) class Location: NSObject {
  var name: String
  var address: String
  var latitude: Double
  var longitude: Double
  var isBusiness: Bool
  
  init (name: String, address: String, latitude: Double, longitude: Double, isBusiness: Bool) {
    self.latitude = latitude
    self.longitude = longitude
    self.name = name
    self.address = address
    self.isBusiness = isBusiness
  }
  
  // Added for reflect
override convenience init () {
    self.init(name: "", address: "", latitude: 0.0, longitude: 0.0, isBusiness: false)
  }
}

class LocationRepository {
  var locations: [Location] = []
  
  func add(location: Location) {
    locations.append(location)
  }
}