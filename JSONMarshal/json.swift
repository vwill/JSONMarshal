//
//  json.swift
//  LocationApp
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
  
  Key differences with this Swift draft:
  1. Currently returns NSMutableArray
  2. No provision for complex structures (yet!)
  3. A NSObject class is used as opposed to Struct re KVC
  4. Tuple used for singular function to deal with multiple Type optional / conversion unpacking; I'm still trying my luck to simplify this with generics. Appreciate any help in this area (certainly not happy with the current plumbing)
  
  :marshalClass: nominated class structure to parse JSON data into
  :data: NSData byte buffer containing unparsed JSON
  
  */
  
  // TODO: - 1. Simplify Tuple / Switch / Type plumbing
  // TODO: - 2. Explore complex class structure reflection parsing
  
  class func unMarshal(#marshalClass: NSObject.Type, data: NSData) -> NSMutableArray {
    
    let result = NSMutableArray()
    
    // Parse the JSON that came in
    var error = NSError?()
    
    let jsonAnyObject: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error)
    
    if let json = jsonAnyObject as? Array<Dictionary<String, AnyObject>> {
      
      for record:Dictionary<String, AnyObject> in json {
        
        let newMarshalClass = marshalClass()
        let newMarshalClassMirrorType = reflect(newMarshalClass)
        
        for (key: String, value: AnyObject) in record {
          let pType = propertyTypeForJSONKey(key, mirrorType: newMarshalClassMirrorType)
          let jValue = jsonValue(value, propertyType: pType)
          
          switch pType {
          case .Double:
            if jValue.double != nil {
              newMarshalClass.setValue(jValue.double, forKey: key)
            }
          case .String:
            if jValue.string != nil {
              newMarshalClass.setValue(jValue.string, forKey: key)
            }
          case .Int:
            if jValue.int != nil {
              newMarshalClass.setValue(jValue.int, forKey: key)
            }
          case .Bool:
            if jValue.bool != nil {
              newMarshalClass.setValue(jValue.bool, forKey: key)
            }
          case .None:
            println("unmatched JSON key: \(key), value: \(value)")
          }
        }
        
        // Add this question to the locations array
        result.addObject(newMarshalClass)
        
      }
    }
    return result
  }
  
  private class func jsonValue(value: AnyObject, propertyType: PropertyType) -> (double: Double?, int: Int?, string: String?, bool: Bool?) {
    var resultDouble: Double?
    var resultInt: Int?
    var resultString: String?
    var resultBool: Bool?
    switch propertyType {
    case .Double:
      if let result = jsonToDouble(value) {
        resultDouble = result
      }
    case .String:
      if let result = jsonToString(value) {
        resultString = result
      }
    case .Int:
      if let result = jsonToInt(value) {
        resultInt = result
      }
    case .Bool:
      if let result = jsonToBool(value) {
        resultBool = result
      }
    default:
      println("undefined PropertyType: \(propertyType.hashValue)")
    }
    return (double: resultDouble, int: resultInt, string: resultString, bool: resultBool)
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
  
  private class func propertyTypeForJSONKey(key: String, mirrorType: MirrorType) -> PropertyType {
    var result: PropertyType = PropertyType.None
    for var index = 0; index < mirrorType.count; ++index {
      if mirrorType[index].0.uppercaseString == key.uppercaseString {
        let ref = mirrorType[index].1.valueType
        switch ref {
        case is Double.Type:
          result = PropertyType.Double
        case is String.Type:
          result = PropertyType.String
        case is Int.Type:
          result = PropertyType.Int
        case is Bool.Type:
          result = PropertyType.Bool
        default:
          result = PropertyType.None
        }
      }
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
