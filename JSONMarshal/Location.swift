//
//  Location.swift
//  LocationApp
//
//  Created by Vaughn Williams on 2014/09/07.
//  Copyright (c) 2014 Vaughn Williams. All rights reserved.
//

import Foundation

@objc(Location) class Location: NSObject {
  var latitude: Double
  var longitude: Double
  var name: String
  var address: String
  var isBusiness: Bool
  
  init (latitude: Double, longitude: Double, name: String, address: String, isBusiness: Bool) {
    self.latitude = latitude
    self.longitude = longitude
    self.name = name
    self.address = address
    self.isBusiness = isBusiness
  }
  
  /** Added for reflect -- possibly not needed??
  */
  override convenience init () {
    self.init(latitude: 0.0, longitude: 0.0, name: "", address: "", isBusiness: false)
  }
}
 