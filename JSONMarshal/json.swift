//
//  json.swift
//  JSONMarshal
//
//  Created by Vaughn Williams on 2014/09/23.
//  Copyright (c) 2014 Vaughn Williams. All rights reserved.
//

import Foundation
import Swift

class json {

  /** Unmarshal parses the JSON-encoded data and stores the result in an array of a nominated class
  
  Excerpt from Go:
  Unmarshal uses the inverse of the encodings that Marshal uses, allocating maps, slices, and pointers as necessary, with the following additional rules:
  1. To unmarshal JSON into a pointer, Unmarshal first handles the case of the JSON being the JSON literal null. In that case, Unmarshal sets the pointer to nil. Otherwise, Unmarshal unmarshals the JSON into the value pointed at by the pointer. If the pointer is nil, Unmarshal allocates a new value for it to point to.
  2. To unmarshal JSON into a struct, Unmarshal matches incoming object keys to the keys used by Marshal (either the struct field name or its tag), preferring an exact match but also accepting a case-insensitive match.
  
  :marshalClass: nominated class structure to parse JSON data into
  :data: NSData byte buffer containing unparsed JSON
  */
  
  class func unMarshal(#marshalClass: NSObject.Type, data: NSData) -> NSMutableArray {
    
    let result = NSMutableArray()
    var error = NSError?()
    
    let jsonAnyObject: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error)
    
    let newMarshalClassMirror = reflect(marshalClass())
    let propertyAttributes = reflectPropertyAttributes(newMarshalClassMirror)
    
    if let json = jsonAnyObject as? Array<Dictionary<String, AnyObject>> {
      
      for row:Dictionary<String, AnyObject> in json {
        let newMarshalClass = marshalClass()
        
        for (key: String, value: AnyObject) in row {
          if let propertyType: Any.Type = propertyAttributes[key.uppercaseString] {
            switch propertyType {
            case is Double.Type:
              if let doubleValue = jsonToDouble(value) {
                newMarshalClass.setValue(doubleValue, forKey: key)
              }
            case is Int.Type:
              if let intValue = jsonToInt(value) {
                newMarshalClass.setValue(intValue, forKey: key)
              }
            case is String.Type:
              if let stringValue = jsonToString(value) {
                newMarshalClass.setValue(stringValue, forKey: key)
              }
            case is Bool.Type:
              if let boolValue = jsonToBool(value) {
                newMarshalClass.setValue(boolValue, forKey: key)
              }
            default:
              println("\(key): \(value) -- undefined")
            }
          }
        }
        
        result.addObject(newMarshalClass)
      }
    }
    return result
  }

  private class func jsonToDouble(value: AnyObject) -> Double? {
    if let result = value.doubleValue {
      return result
    } else {
      return nil
    }
  }
  
  private class func jsonToInt(value: AnyObject) -> Int? {
    if let result = value.integerValue {
      return result
    } else {
      return nil
    }
  }
  
  private class func jsonToString(value: AnyObject) -> String? {
    if let result = value as? String {
      return result
    } else {
      return nil
    }
  }
  
  private class func jsonToBool(value: AnyObject) -> Bool? {
    if let result = value.integerValue?.boolValue() {
      return result
    } else {
      return nil
    }
  }
  
  private class func reflectPropertyAttributes(mirrorType: MirrorType) -> [String: Any.Type] {
    var result = [String: Any.Type]()
    for var index = 0; index < mirrorType.count; ++index {
      result[mirrorType[index].0.uppercaseString] = mirrorType[index].1.valueType
    }
    return result
  }
}

extension Int {
  func boolValue () -> Bool? {
    switch self {
    case 0:
      return false
    case 1:
      return true
    default:
      return nil
    }
  }
}
