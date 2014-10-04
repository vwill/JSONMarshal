//
//  Address.swift
//  JSONMarshal
//
//  Created by Vaughn Williams on 2014/09/25.
//  Copyright (c) 2014 Vaughn Williams. All rights reserved.
//


// Complex class for JSON unMarshal adaptation test


import Foundation

@objc(JSONMarshal_Address) class Address: NSObject {
  var name: String
  var address: CGRect
  var overWater: NSError
  var latitude: Int
  var longitude: Double
  var isBusiness: Bool
  var keyWords: [String]
  var dic: [Int8: Bool]
  var dlt: NSArray
  var location: Location
  var telephones: [Telephone]
  
  init (name: String, address: CGRect, overWater: NSError, latitude: Int, longitude: Double, isBusiness: Bool, keyWords: [String], dic: [Int8: Bool], dlt: NSArray, location: Location, telephones: [Telephone]) {
    self.name = name
    self.address = address
    self.overWater = overWater
    self.latitude = latitude
    self.longitude = longitude
    self.isBusiness = isBusiness
    self.keyWords = keyWords
    self.dic = dic
    self.dlt = dlt
    self.location = location
    self.telephones = telephones
  }
  
  // Added for reflect.
  override convenience init () {
    self.init(name: "", address: CGRect(), overWater: NSError(), latitude: 0, longitude: 0.0, isBusiness: false, keyWords: ["abc", "def"], dic: [7: true], dlt: NSArray(), location: Location(), telephones: [Telephone()])
    
  }
  
  @objc(JSONMarshal_Address_Telephone) class Telephone: NSObject {
    var number: String
    var category: Category
    var locality: Locality
    
    enum Category {
      case Cellular, Landline, VoiceOverIP
    }
    
    enum Locality {
      case Home, Work, Mobile
    }
    
    init (number: String, category: Category = .Landline , locality: Locality = .Home) {
      self.number = number
      self.category = category
      self.locality = locality
    }
    
    // Added for reflect.
    override convenience init () {
      self.init(number: "0", category: .Landline, locality: .Home)
    }
    
    func debugDescription() {
      println(self.number)
    }
  }
}
 