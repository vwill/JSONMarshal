//
//  json.swift
//  JSONMarshal
//
//  Created by Vaughn Williams on 2014/09/23.
//  Copyright (c) 2014 Vaughn Williams. All rights reserved.
//

import Foundation
import Swift

class Json {

  /** Unmarshal parses the JSON-encoded data and stores the result in an array of a nominated class
  
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
//          if let jValue: String = value as? String {
//            println("Inside \(key): \(jValue)")
//          } else {
//            println("Inside \(key): nil")
//          }

          if let propertyType: Any.Type = propertyAttributes[key.uppercaseString] {
            switch propertyType {
            case is Double.Type:
              if let doubleValue = toDouble(value) {
                newMarshalClass.setValue(doubleValue, forKey: key)
              }
            case is Int.Type:
              if let intValue = toInt(value) {
                newMarshalClass.setValue(intValue, forKey: key)
              }
            case is String.Type:
              if let stringValue = toString(value) {
                newMarshalClass.setValue(stringValue, forKey: key)
              }
            case is Bool.Type:
              if let boolValue = toBool(value) {
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

  class func reflectClassAttributes(mirrorType: MirrorType) -> [String: AnyObject] {
    var result = [String: AnyObject]()
    for var index = 0; index < mirrorType.count; ++index {
      let (propertyName, childMirror) = mirrorType[index]
      var colType = [String: Any.Type]()
      colType[propertyName.uppercaseString] = childMirror.valueType
      if let cType: Any.Type = colType[propertyName.uppercaseString] {
        switch cType {
        case is Array<Int>.Type:
          println("\(propertyName) -> Array type")
        default:
          println("\(propertyName) -> non collection type")
        }
      }
    }
    return result
  }
  
  class func reflectPropertyAttributes(mirrorType: MirrorType) -> [String: Any.Type] {
    var result = [String: Any.Type]()
    for var index = 0; index < mirrorType.count; ++index {
      let (propertyName, childMirror) = mirrorType[index]
      result[propertyName.uppercaseString] = childMirror.valueType
//      println("Property: \(propertyName.uppercaseString)")
    }
    return result
  }
  
  
  /**
  Arrays : Class or Struct
  */
  

}

class JsonValue: Any {
  
}

extension JsonValue {
  
  var doubleValue: Double? {
    if let result = (self as AnyObject).doubleValue {
      return result
    } else {
      return nil
    }
  }
  
  var integerValue: Int? {
    if let result = (self as AnyObject).integerValue {
      return result
    } else {
      return nil
    }
  }
  
  var stringValue: String? {
    if let result = (self as AnyObject).stringValue  {
      return result
    } else {
      return nil
    }
  }
  
  var boolValue: Bool? {
    if let result = (self as AnyObject).integerValue?.boolValue() {
      return result
    } else {
      return nil
    }
  }
}



extension Json {
  private class func toDouble(value: AnyObject) -> Double? {
    if let result = value.doubleValue {
      return result
    } else {
      return nil
    }
  }
  
  private class func toInt(value: AnyObject) -> Int? {
    if let result = value.integerValue {
      return result
    } else {
      return nil
    }
  }
  
  private class func toString(value: AnyObject) -> String? {
    if let result = value as? String {
      return result
    } else {
      return nil
    }
  }
  
  private class func toBool(value: AnyObject) -> Bool? {
    if let result = value.integerValue?.boolValue() {
      return result
    } else {
      return nil
    }
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
