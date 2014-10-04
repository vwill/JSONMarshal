//
//  Marshal.Reflection.swift
//  JSONMarshal
//
//  Created by Vaughn Williams on 2014/10/01.
//  Copyright (c) 2014 Vaughn Williams. All rights reserved.
//

import Foundation

extension Marshal {
  
  class Reflection {
    
    internal enum Disposition: Int {
      case Struct, Class, Enum, Tuple, Aggregate, IndexContainer, KeyContainer, MembershipContainer, Container, Optional, ObjCObject, Invalid
      
      /** Returns a String respresenting the provided object disposition type
      */
      func stringValue() -> String {
        switch self {
        case .Struct:
          return "Struct"
        case .Class:
          return "Class"
        case .Enum:
          return "Enum"
        case .Tuple:
          return "Tuple"
        case .Aggregate:
          return "Aggregate"
        case .IndexContainer:
          return "IndexContainer"
        case .KeyContainer:
          return "KeyContainer"
        case .MembershipContainer:
          return "MembershipContainer"
        case .Container:
          return "Container"
        case .Optional:
          return "Optional"
        case .ObjCObject:
          return "ObjCObject"
        case .Invalid:
          return "Invalid"
        }
      }
    }
    
    private class PropertyResult {
      var name: String
      var disposition: Marshal.Reflection.Disposition
      var className: String
      var type: Any
      var typeString: String
      
    
      init(name: String, mirror: MirrorType) {
        self.name = name
        self.disposition = Disposition(rawValue: mirror.disposition.hashValue) ?? Disposition.Invalid
        self.className = Marshal.Reflection.typeName(mirror.value).1
        self.type = mirror.valueType
        self.typeString = Marshal.Reflection.typeString(mirror.valueType)
      }
      
      func modify(#name: String, mirror: MirrorType) {
        self.name = name
        self.disposition = Disposition(rawValue: mirror.disposition.hashValue) ?? Disposition.Invalid
        self.className = Marshal.Reflection.typeName(mirror.value).1
        self.type = mirror.valueType
        self.typeString = Marshal.Reflection.typeString(mirror.valueType)
      }
    }
    
    internal class func typeName(object: Any) -> (String, String, String) {
      let name = _stdlib_getTypeName(object)
      let demangleName = _stdlib_demangleName(name)
      return (name, demangleName, demangleName.componentsSeparatedByString(".").last!)
    }
    
    internal class func properties(reflectClass: MirrorType, inout marshalClass: Marshal.Class) {
      var properties = Array<Marshal.Property>()
      
      for var index = 0; index < reflectClass.count; ++index {
        var skipProperty = false
        let (propertyName, childMirror) = reflectClass[index]
        var result = PropertyResult(name: propertyName, mirror: childMirror)
        
        if propertyName.uppercaseString != "SUPER" {
          
          if result.disposition == Disposition.Class {
            let (propertyName2, childMirror2) = reflect(childMirror.value)[0]
            result.modify(name: result.name, mirror: childMirror2)
            //TODO: At this point we need to call the new class function with these details
          } else if result.disposition == Disposition.IndexContainer && childMirror.count != 0 {
            let (propertyName2, childMirror2) = reflect(childMirror.value)[0]
            
            if (Disposition(rawValue: childMirror2.disposition.hashValue) ?? result.disposition) == Disposition.Class {
              result.modify(name: result.name, mirror: childMirror2)
              result.disposition = Disposition(rawValue: childMirror.disposition.hashValue) ?? result.disposition
              result.typeString = "Array<\(typeName(childMirror2.value).1)>"
              //TODO: At this point we need to call the new class function with these details
            }
          }
          properties.append(Marshal.Property(name: result.name, disposition: result.disposition, className: result.className, type: result.type, typeString: result.typeString))
        }
      }
      // Append discovered properties to class
      for property in properties {
        marshalClass.append(property)
      }
    }
    
    /** Returns a String respresenting the provided object type
    :type: Any.Type Any object type
    */
    internal class func typeString(type: Any.Type) -> String {
      switch type {
        
      /* Objective-C Types*/
      case is CGRect.Type:
        return "CGRect"
      case is CGFloat.Type:
        return "CGFloat"
      case is CGPoint.Type:
        return "CGPoint"
      case is CGSize.Type:
        return "CGSize"
      case is CGVector.Type:
        return "CGVector"
      case is NSArray.Type: // Appears to be directly cast to Array<AnyObject>
        return "NSArray"
      case is NSDate.Type:
        return "NSDate"
      case is NSData.Type:
        return "NSData"
      case is NSDictionary.Type: // Issue: NSDictionary instance doesn't seem to match
        return "NSDictionary"
      case is NSError.Type:
        return "NSError"
      case is NSInteger.Type:
        return "NSInteger"
      case is NSNull.Type:
        return "NSNull"
      case is NSNumber.Type:
        return "NSNumber"
      case is NSMutableArray.Type:
        return "NSMutableArray"
      case is NSMutableAttributedString.Type:
        return "NSMutableAttributedString"
      case is NSMutableData.Type:
        return "NSMutableData"
      case is NSMutableDictionary.Type:
        return "NSMutableDictionary"
      case is NSMutableSet.Type:
        return "NSMutableSet"
      case is NSMutableString.Type:
        return "NSMutableString"
      case is NSMutableURLRequest.Type:
        return "NSMutableURLRequest"
      case is NSObject.Type:
        return "NSObject"
      case is NSRange.Type:
        return "NSRange"
      case is NSRect.Type:
        return "NSRect"
      case is NSSet.Type:
        return "NSSet"
      case is NSSize.Type:
        return "NSSize"
      case is NSString.Type:
        return "NSString"
      case is NSURL.Type:
        return "NSURL"
      case is NSURLRequest.Type:
        return "NSURLRequest"
      case is NSValue.Type:
        return "NSValue"
        
      /* Standard Types */
      case is Character.Type:
        return "Character"
      case is String.Type:
        return "String"
      case is Bool.Type:
        return "Bool"
      case is Int.Type:
        return "Int"
      case is Int8.Type:
        return "Int8"
      case is Int16.Type:
        return "Int16"
      case is Int32.Type:
        return "Int32"
      case is Int64.Type:
        return "Int64"
      case is UInt.Type:
        return "UInt"
      case is UInt8.Type:
        return "UInt8"
      case is UInt16.Type:
        return "UInt16"
      case is UInt32.Type:
        return "UInt32"
      case is UInt64.Type:
        return "UInt64"
      case is Double.Type:
        return "Double"
      case is Float.Type:
        return "Float"
      case is Float32.Type:
        return "Float32"
      case is Float64.Type:
        return "Float64"
        
        /* Array Standard Types  */
      case is Array<AnyObject>.Type:
        return "Array<AnyObject>"
      case is Array<Character>.Type:
        return "Array<Character>"
      case is Array<String>.Type:
        return "Array<String>"
      case is Array<Bool>.Type:
        return "Array<Bool>"
      case is Array<Int>.Type:
        return "Array<Int>"
      case is Array<Int8>.Type:
        return "Array<Int8>"
      case is Array<Int16>.Type:
        return "Array<Int16>"
      case is Array<Int32>.Type:
        return "Array<Int32>"
      case is Array<Int64>.Type:
        return "Array<Int64>"
      case is Array<UInt>.Type:
        return "Array<UInt>"
      case is Array<UInt8>.Type:
        return "Array<UInt8>"
      case is Array<UInt16>.Type:
        return "Array<UInt16>"
      case is Array<UInt32>.Type:
        return "Array<UInt32>"
      case is Array<UInt64>.Type:
        return "Array<UInt64>"
      case is Array<Double>.Type:
        return "Array<Double>"
      case is Array<Float>.Type:
        return "Array<Float>"
      case is Array<Float32>.Type:
        return "Array<Float32>"
      case is Array<Float64>.Type:
        return "Array<Float64>"
        
        /* Dictionary String String Type */
      case is Dictionary<String, String>.Type:
        return "Dictionary<String, String>"
        
        /* Dictionary String _ Types */
      case is Dictionary<String, Character>.Type:
        return "Dictionary<String, Character>"
      case is Dictionary<String, Bool>.Type:
        return "Dictionary<String, Bool>"
      case is Dictionary<String, Int>.Type:
        return "Dictionary<String, Int>"
      case is Dictionary<String, Int8>.Type:
        return "Dictionary<String, Int8>"
      case is Dictionary<String, Int16>.Type:
        return "Dictionary<String, Int16>"
      case is Dictionary<String, Int32>.Type:
        return "Dictionary<String, Int32>"
      case is Dictionary<String, Int64>.Type:
        return "Dictionary<String, Int64>"
      case is Dictionary<String, UInt>.Type:
        return "Dictionary<String, UInt>"
      case is Dictionary<String, UInt8>.Type:
        return "Dictionary<String, UInt8>"
      case is Dictionary<String, UInt16>.Type:
        return "Dictionary<String, UInt16>"
      case is Dictionary<String, UInt32>.Type:
        return "Dictionary<String, UInt32>"
      case is Dictionary<String, UInt64>.Type:
        return "Dictionary<String, UInt64>"
      case is Dictionary<String, Double>.Type:
        return "Dictionary<String, Double>"
      case is Dictionary<String, Float>.Type:
        return "Dictionary<String, Float>"
      case is Dictionary<String, Float32>.Type:
        return "Dictionary<String, Float32>"
      case is Dictionary<String, Float64>.Type:
        return "Dictionary<String, Float64>"
        
        /* Dictionary _ String Types */
      case is Dictionary<Character, String>.Type:
        return "Dictionary<Character, String>"
      case is Dictionary<Bool, String>.Type:
        return "Dictionary<Bool, String>"
      case is Dictionary<Int, String>.Type:
        return "Dictionary<Int, String>"
      case is Dictionary<Int8, String>.Type:
        return "Dictionary<Int8, String>"
      case is Dictionary<Int16, String>.Type:
        return "Dictionary<Int16, String>"
      case is Dictionary<Int32, String>.Type:
        return "Dictionary<Int32, String>"
      case is Dictionary<Int64, String>.Type:
        return "Dictionary<Int64, String>"
      case is Dictionary<UInt, String>.Type:
        return "Dictionary<UInt, String>"
      case is Dictionary<UInt8, String>.Type:
        return "Dictionary<UInt8, String>"
      case is Dictionary<UInt16, String>.Type:
        return "Dictionary<UInt16, String>"
      case is Dictionary<UInt32, String>.Type:
        return "Dictionary<UInt32, String>"
      case is Dictionary<UInt64, String>.Type:
        return "Dictionary<UInt64, String>"
      case is Dictionary<Double, String>.Type:
        return "Dictionary<Double, String>"
      case is Dictionary<Float, String>.Type:
        return "Dictionary<Float, String>"
      case is Dictionary<Float32, String>.Type:
        return "Dictionary<Float32, String>"
      case is Dictionary<Float64, String>.Type:
        return "Dictionary<Float64, String>"
        
        /* Dictionary Bool Bool Type */
      case is Dictionary<Bool, Bool>.Type:
        return "Dictionary<Bool, Bool>"
        
        /* Dictionary Bool _ Types */
      case is Dictionary<Bool, Character>.Type:
        return "Dictionary<Bool, Character>"
      case is Dictionary<Bool, Bool>.Type:
        return "Dictionary<Bool, Bool>"
      case is Dictionary<Bool, Int>.Type:
        return "Dictionary<Bool, Int>"
      case is Dictionary<Bool, Int8>.Type:
        return "Dictionary<Bool, Int8>"
      case is Dictionary<Bool, Int16>.Type:
        return "Dictionary<Bool, Int16>"
      case is Dictionary<Bool, Int32>.Type:
        return "Dictionary<Bool, Int32>"
      case is Dictionary<Bool, Int64>.Type:
        return "Dictionary<Bool, Int64>"
      case is Dictionary<Bool, UInt>.Type:
        return "Dictionary<Bool, UInt>"
      case is Dictionary<Bool, UInt8>.Type:
        return "Dictionary<Bool, UInt8>"
      case is Dictionary<Bool, UInt16>.Type:
        return "Dictionary<Bool, UInt16>"
      case is Dictionary<Bool, UInt32>.Type:
        return "Dictionary<Bool, UInt32>"
      case is Dictionary<Bool, UInt64>.Type:
        return "Dictionary<Bool, UInt64>"
      case is Dictionary<Bool, Double>.Type:
        return "Dictionary<Bool, Double>"
      case is Dictionary<Bool, Float>.Type:
        return "Dictionary<Bool, Float>"
      case is Dictionary<Bool, Float32>.Type:
        return "Dictionary<Bool, Float32>"
      case is Dictionary<Bool, Float64>.Type:
        return "Dictionary<Bool, Float64>"
        
        /* Dictionary _ Bool Types */
      case is Dictionary<Character, Bool>.Type:
        return "Dictionary<Character, Bool>"
      case is Dictionary<Bool, Bool>.Type:
        return "Dictionary<Bool, Bool>"
      case is Dictionary<Int, Bool>.Type:
        return "Dictionary<Int, Bool>"
      case is Dictionary<Int8, Bool>.Type:
        return "Dictionary<Int8, Bool>"
      case is Dictionary<Int16, Bool>.Type:
        return "Dictionary<Int16, Bool>"
      case is Dictionary<Int32, Bool>.Type:
        return "Dictionary<Int32, Bool>"
      case is Dictionary<Int64, Bool>.Type:
        return "Dictionary<Int64, Bool>"
      case is Dictionary<UInt, Bool>.Type:
        return "Dictionary<UInt, Bool>"
      case is Dictionary<UInt8, Bool>.Type:
        return "Dictionary<UInt8, Bool>"
      case is Dictionary<UInt16, Bool>.Type:
        return "Dictionary<UInt16, Bool>"
      case is Dictionary<UInt32, Bool>.Type:
        return "Dictionary<UInt32, Bool>"
      case is Dictionary<UInt64, Bool>.Type:
        return "Dictionary<UInt64, Bool>"
      case is Dictionary<Double, Bool>.Type:
        return "Dictionary<Double, Bool>"
      case is Dictionary<Float, Bool>.Type:
        return "Dictionary<Float, Bool>"
      case is Dictionary<Float32, Bool>.Type:
        return "Dictionary<Float32, Bool>"
      case is Dictionary<Float64, Bool>.Type:
        return "Dictionary<Float64, Bool>"
        
        /* Dictionary Int Int Type */
      case is Dictionary<Int, Int>.Type:
        return "Dictionary<Int, Int>"
        
        /* Dictionary Int _ Types */
      case is Dictionary<Int, Character>.Type:
        return "Dictionary<Int, Character>"
      case is Dictionary<Int, Bool>.Type:
        return "Dictionary<Int, Bool>"
      case is Dictionary<Int, Int>.Type:
        return "Dictionary<Int, Int>"
      case is Dictionary<Int, Int8>.Type:
        return "Dictionary<Int, Int8>"
      case is Dictionary<Int, Int16>.Type:
        return "Dictionary<Int, Int16>"
      case is Dictionary<Int, Int32>.Type:
        return "Dictionary<Int, Int32>"
      case is Dictionary<Int, Int64>.Type:
        return "Dictionary<Int, Int64>"
      case is Dictionary<Int, UInt>.Type:
        return "Dictionary<Int, UInt>"
      case is Dictionary<Int, UInt8>.Type:
        return "Dictionary<Int, UInt8>"
      case is Dictionary<Int, UInt16>.Type:
        return "Dictionary<Int, UInt16>"
      case is Dictionary<Int, UInt32>.Type:
        return "Dictionary<Int, UInt32>"
      case is Dictionary<Int, UInt64>.Type:
        return "Dictionary<Int, UInt64>"
      case is Dictionary<Int, Double>.Type:
        return "Dictionary<Int, Double>"
      case is Dictionary<Int, Float>.Type:
        return "Dictionary<Int, Float>"
      case is Dictionary<Int, Float32>.Type:
        return "Dictionary<Int, Float32>"
      case is Dictionary<Int, Float64>.Type:
        return "Dictionary<Int, Float64>"
        
        /* Dictionary _ Int Types */
      case is Dictionary<Character, Int>.Type:
        return "Dictionary<Character, Int>"
      case is Dictionary<Bool, Int>.Type:
        return "Dictionary<Bool, Int>"
      case is Dictionary<Int, Int>.Type:
        return "Dictionary<Int, Int>"
      case is Dictionary<Int8, Int>.Type:
        return "Dictionary<Int8, Int>"
      case is Dictionary<Int16, Int>.Type:
        return "Dictionary<Int16, Int>"
      case is Dictionary<Int32, Int>.Type:
        return "Dictionary<Int32, Int>"
      case is Dictionary<Int64, Int>.Type:
        return "Dictionary<Int64, Int>"
      case is Dictionary<UInt, Int>.Type:
        return "Dictionary<UInt, Int>"
      case is Dictionary<UInt8, Int>.Type:
        return "Dictionary<UInt8, Int>"
      case is Dictionary<UInt16, Int>.Type:
        return "Dictionary<UInt16, Int>"
      case is Dictionary<UInt32, Int>.Type:
        return "Dictionary<UInt32, Int>"
      case is Dictionary<UInt64, Int>.Type:
        return "Dictionary<UInt64, Int>"
      case is Dictionary<Double, Int>.Type:
        return "Dictionary<Double, Int>"
      case is Dictionary<Float, Int>.Type:
        return "Dictionary<Float, Int>"
      case is Dictionary<Float32, Int>.Type:
        return "Dictionary<Float32, Int>"
      case is Dictionary<Float64, Int>.Type:
        return "Dictionary<Float64, Int>"
        
        /* Dictionary Int8 Int8 Type */
      case is Dictionary<Int8, Int8>.Type:
        return "Dictionary<Int8, Int8>"
        
        /* Dictionary Int8 _ Types */
      case is Dictionary<Int8, Character>.Type:
        return "Dictionary<Int8, Character>"
      case is Dictionary<Int8, Bool>.Type:
        return "Dictionary<Int8, Bool>"
      case is Dictionary<Int8, Int>.Type:
        return "Dictionary<Int8, Int>"
      case is Dictionary<Int8, Int8>.Type:
        return "Dictionary<Int8, Int8>"
      case is Dictionary<Int8, Int16>.Type:
        return "Dictionary<Int8, Int16>"
      case is Dictionary<Int8, Int32>.Type:
        return "Dictionary<Int8, Int32>"
      case is Dictionary<Int8, Int64>.Type:
        return "Dictionary<Int8, Int64>"
      case is Dictionary<Int8, UInt>.Type:
        return "Dictionary<Int8, UInt>"
      case is Dictionary<Int8, UInt8>.Type:
        return "Dictionary<Int8, UInt8>"
      case is Dictionary<Int8, UInt16>.Type:
        return "Dictionary<Int8, UInt16>"
      case is Dictionary<Int8, UInt32>.Type:
        return "Dictionary<Int8, UInt32>"
      case is Dictionary<Int8, UInt64>.Type:
        return "Dictionary<Int8, UInt64>"
      case is Dictionary<Int8, Double>.Type:
        return "Dictionary<Int8, Double>"
      case is Dictionary<Int8, Float>.Type:
        return "Dictionary<Int8, Float>"
      case is Dictionary<Int8, Float32>.Type:
        return "Dictionary<Int8, Float32>"
      case is Dictionary<Int8, Float64>.Type:
        return "Dictionary<Int8, Float64>"
        
        /* Dictionary _ Int8 Types */
      case is Dictionary<Character, Int8>.Type:
        return "Dictionary<Character, Int8>"
      case is Dictionary<Bool, Int8>.Type:
        return "Dictionary<Bool, Int8>"
      case is Dictionary<Int, Int8>.Type:
        return "Dictionary<Int, Int8>"
      case is Dictionary<Int8, Int8>.Type:
        return "Dictionary<Int8, Int8>"
      case is Dictionary<Int16, Int8>.Type:
        return "Dictionary<Int16, Int8>"
      case is Dictionary<Int32, Int8>.Type:
        return "Dictionary<Int32, Int8>"
      case is Dictionary<Int64, Int8>.Type:
        return "Dictionary<Int64, Int8>"
      case is Dictionary<UInt, Int8>.Type:
        return "Dictionary<UInt, Int8>"
      case is Dictionary<UInt8, Int8>.Type:
        return "Dictionary<UInt8, Int8>"
      case is Dictionary<UInt16, Int8>.Type:
        return "Dictionary<UInt16, Int8>"
      case is Dictionary<UInt32, Int8>.Type:
        return "Dictionary<UInt32, Int8>"
      case is Dictionary<UInt64, Int8>.Type:
        return "Dictionary<UInt64, Int8>"
      case is Dictionary<Double, Int8>.Type:
        return "Dictionary<Double, Int8>"
      case is Dictionary<Float, Int8>.Type:
        return "Dictionary<Float, Int8>"
      case is Dictionary<Float32, Int8>.Type:
        return "Dictionary<Float32, Int8>"
      case is Dictionary<Float64, Int8>.Type:
        return "Dictionary<Float64, Int8>"
        
        /* Dictionary Int16 Int16 Type */
      case is Dictionary<Int16, Int16>.Type:
        return "Dictionary<Int16, Int16>"
        
        /* Dictionary Int16 _ Types */
      case is Dictionary<Int16, Character>.Type:
        return "Dictionary<Int16, Character>"
      case is Dictionary<Int16, Bool>.Type:
        return "Dictionary<Int16, Bool>"
      case is Dictionary<Int16, Int>.Type:
        return "Dictionary<Int16, Int>"
      case is Dictionary<Int16, Int8>.Type:
        return "Dictionary<Int16, Int8>"
      case is Dictionary<Int16, Int16>.Type:
        return "Dictionary<Int16, Int16>"
      case is Dictionary<Int16, Int32>.Type:
        return "Dictionary<Int16, Int32>"
      case is Dictionary<Int16, Int64>.Type:
        return "Dictionary<Int16, Int64>"
      case is Dictionary<Int16, UInt>.Type:
        return "Dictionary<Int16, UInt>"
      case is Dictionary<Int16, UInt8>.Type:
        return "Dictionary<Int16, UInt8>"
      case is Dictionary<Int16, UInt16>.Type:
        return "Dictionary<Int16, UInt16>"
      case is Dictionary<Int16, UInt32>.Type:
        return "Dictionary<Int16, UInt32>"
      case is Dictionary<Int16, UInt64>.Type:
        return "Dictionary<Int16, UInt64>"
      case is Dictionary<Int16, Double>.Type:
        return "Dictionary<Int16, Double>"
      case is Dictionary<Int16, Float>.Type:
        return "Dictionary<Int16, Float>"
      case is Dictionary<Int16, Float32>.Type:
        return "Dictionary<Int16, Float32>"
      case is Dictionary<Int16, Float64>.Type:
        return "Dictionary<Int16, Float64>"
        
        /* Dictionary _ Int16 Types */
      case is Dictionary<Character, Int16>.Type:
        return "Dictionary<Character, Int16>"
      case is Dictionary<Bool, Int16>.Type:
        return "Dictionary<Bool, Int16>"
      case is Dictionary<Int, Int16>.Type:
        return "Dictionary<Int, Int16>"
      case is Dictionary<Int8, Int16>.Type:
        return "Dictionary<Int8, Int16>"
      case is Dictionary<Int16, Int16>.Type:
        return "Dictionary<Int16, Int16>"
      case is Dictionary<Int32, Int16>.Type:
        return "Dictionary<Int32, Int16>"
      case is Dictionary<Int64, Int16>.Type:
        return "Dictionary<Int64, Int16>"
      case is Dictionary<UInt, Int16>.Type:
        return "Dictionary<UInt, Int16>"
      case is Dictionary<UInt8, Int16>.Type:
        return "Dictionary<UInt8, Int16>"
      case is Dictionary<UInt16, Int16>.Type:
        return "Dictionary<UInt16, Int16>"
      case is Dictionary<UInt32, Int16>.Type:
        return "Dictionary<UInt32, Int16>"
      case is Dictionary<UInt64, Int16>.Type:
        return "Dictionary<UInt64, Int16>"
      case is Dictionary<Double, Int16>.Type:
        return "Dictionary<Double, Int16>"
      case is Dictionary<Float, Int16>.Type:
        return "Dictionary<Float, Int16>"
      case is Dictionary<Float32, Int16>.Type:
        return "Dictionary<Float32, Int16>"
      case is Dictionary<Float64, Int16>.Type:
        return "Dictionary<Float64, Int16>"
        
        /* Dictionary Int32 Int32 Type */
      case is Dictionary<Int32, Int32>.Type:
        return "Dictionary<Int32, Int32>"
        
        /* Dictionary Int32 _ Types */
      case is Dictionary<Int32, Character>.Type:
        return "Dictionary<Int32, Character>"
      case is Dictionary<Int32, Bool>.Type:
        return "Dictionary<Int32, Bool>"
      case is Dictionary<Int32, Int>.Type:
        return "Dictionary<Int32, Int>"
      case is Dictionary<Int32, Int8>.Type:
        return "Dictionary<Int32, Int8>"
      case is Dictionary<Int32, Int16>.Type:
        return "Dictionary<Int32, Int16>"
      case is Dictionary<Int32, Int32>.Type:
        return "Dictionary<Int32, Int32>"
      case is Dictionary<Int32, Int64>.Type:
        return "Dictionary<Int32, Int64>"
      case is Dictionary<Int32, UInt>.Type:
        return "Dictionary<Int32, UInt>"
      case is Dictionary<Int32, UInt8>.Type:
        return "Dictionary<Int32, UInt8>"
      case is Dictionary<Int32, UInt16>.Type:
        return "Dictionary<Int32, UInt16>"
      case is Dictionary<Int32, UInt32>.Type:
        return "Dictionary<Int32, UInt32>"
      case is Dictionary<Int32, UInt64>.Type:
        return "Dictionary<Int32, UInt64>"
      case is Dictionary<Int32, Double>.Type:
        return "Dictionary<Int32, Double>"
      case is Dictionary<Int32, Float>.Type:
        return "Dictionary<Int32, Float>"
      case is Dictionary<Int32, Float32>.Type:
        return "Dictionary<Int32, Float32>"
      case is Dictionary<Int32, Float64>.Type:
        return "Dictionary<Int32, Float64>"
        
        /* Dictionary _ Int32 Types */
      case is Dictionary<Character, Int32>.Type:
        return "Dictionary<Character, Int32>"
      case is Dictionary<Bool, Int32>.Type:
        return "Dictionary<Bool, Int32>"
      case is Dictionary<Int, Int32>.Type:
        return "Dictionary<Int, Int32>"
      case is Dictionary<Int8, Int32>.Type:
        return "Dictionary<Int8, Int32>"
      case is Dictionary<Int16, Int32>.Type:
        return "Dictionary<Int16, Int32>"
      case is Dictionary<Int32, Int32>.Type:
        return "Dictionary<Int32, Int32>"
      case is Dictionary<Int64, Int32>.Type:
        return "Dictionary<Int64, Int32>"
      case is Dictionary<UInt, Int32>.Type:
        return "Dictionary<UInt, Int32>"
      case is Dictionary<UInt8, Int32>.Type:
        return "Dictionary<UInt8, Int32>"
      case is Dictionary<UInt16, Int32>.Type:
        return "Dictionary<UInt16, Int32>"
      case is Dictionary<UInt32, Int32>.Type:
        return "Dictionary<UInt32, Int32>"
      case is Dictionary<UInt64, Int32>.Type:
        return "Dictionary<UInt64, Int32>"
      case is Dictionary<Double, Int32>.Type:
        return "Dictionary<Double, Int32>"
      case is Dictionary<Float, Int32>.Type:
        return "Dictionary<Float, Int32>"
      case is Dictionary<Float32, Int32>.Type:
        return "Dictionary<Float32, Int32>"
      case is Dictionary<Float64, Int32>.Type:
        return "Dictionary<Float64, Int32>"
        
        /* Dictionary Int64 Int64 Type */
      case is Dictionary<Int64, Int64>.Type:
        return "Dictionary<Int64, Int64>"
        
        /* Dictionary Int64 _ Types */
      case is Dictionary<Int64, Character>.Type:
        return "Dictionary<Int64, Character>"
      case is Dictionary<Int64, Bool>.Type:
        return "Dictionary<Int64, Bool>"
      case is Dictionary<Int64, Int>.Type:
        return "Dictionary<Int64, Int>"
      case is Dictionary<Int64, Int8>.Type:
        return "Dictionary<Int64, Int8>"
      case is Dictionary<Int64, Int16>.Type:
        return "Dictionary<Int64, Int16>"
      case is Dictionary<Int64, Int32>.Type:
        return "Dictionary<Int64, Int32>"
      case is Dictionary<Int64, Int64>.Type:
        return "Dictionary<Int64, Int64>"
      case is Dictionary<Int64, UInt>.Type:
        return "Dictionary<Int64, UInt>"
      case is Dictionary<Int64, UInt8>.Type:
        return "Dictionary<Int64, UInt8>"
      case is Dictionary<Int64, UInt16>.Type:
        return "Dictionary<Int64, UInt16>"
      case is Dictionary<Int64, UInt32>.Type:
        return "Dictionary<Int64, UInt32>"
      case is Dictionary<Int64, UInt64>.Type:
        return "Dictionary<Int64, UInt64>"
      case is Dictionary<Int64, Double>.Type:
        return "Dictionary<Int64, Double>"
      case is Dictionary<Int64, Float>.Type:
        return "Dictionary<Int64, Float>"
      case is Dictionary<Int64, Float32>.Type:
        return "Dictionary<Int64, Float32>"
      case is Dictionary<Int64, Float64>.Type:
        return "Dictionary<Int64, Float64>"
        
        /* Dictionary _ Int64 Types */
      case is Dictionary<Character, Int64>.Type:
        return "Dictionary<Character, Int64>"
      case is Dictionary<Bool, Int64>.Type:
        return "Dictionary<Bool, Int64>"
      case is Dictionary<Int, Int64>.Type:
        return "Dictionary<Int, Int64>"
      case is Dictionary<Int8, Int64>.Type:
        return "Dictionary<Int8, Int64>"
      case is Dictionary<Int16, Int64>.Type:
        return "Dictionary<Int16, Int64>"
      case is Dictionary<Int32, Int64>.Type:
        return "Dictionary<Int32, Int64>"
      case is Dictionary<Int64, Int64>.Type:
        return "Dictionary<Int64, Int64>"
      case is Dictionary<UInt, Int64>.Type:
        return "Dictionary<UInt, Int64>"
      case is Dictionary<UInt8, Int64>.Type:
        return "Dictionary<UInt8, Int64>"
      case is Dictionary<UInt16, Int64>.Type:
        return "Dictionary<UInt16, Int64>"
      case is Dictionary<UInt32, Int64>.Type:
        return "Dictionary<UInt32, Int64>"
      case is Dictionary<UInt64, Int64>.Type:
        return "Dictionary<UInt64, Int64>"
      case is Dictionary<Double, Int64>.Type:
        return "Dictionary<Double, Int64>"
      case is Dictionary<Float, Int64>.Type:
        return "Dictionary<Float, Int64>"
      case is Dictionary<Float32, Int64>.Type:
        return "Dictionary<Float32, Int64>"
      case is Dictionary<Float64, Int64>.Type:
        return "Dictionary<Float64, Int64>"
        
        /* Dictionary UInt UInt Type */
      case is Dictionary<UInt, UInt>.Type:
        return "Dictionary<UInt, UInt>"
        
        /* Dictionary UInt _ Types */
      case is Dictionary<UInt, Character>.Type:
        return "Dictionary<UInt, Character>"
      case is Dictionary<UInt, Bool>.Type:
        return "Dictionary<UInt, Bool>"
      case is Dictionary<UInt, Int>.Type:
        return "Dictionary<UInt, Int>"
      case is Dictionary<UInt, Int8>.Type:
        return "Dictionary<UInt, Int8>"
      case is Dictionary<UInt, Int16>.Type:
        return "Dictionary<UInt, Int16>"
      case is Dictionary<UInt, Int32>.Type:
        return "Dictionary<UInt, Int32>"
      case is Dictionary<UInt, Int64>.Type:
        return "Dictionary<UInt, Int64>"
      case is Dictionary<UInt, UInt>.Type:
        return "Dictionary<UInt, UInt>"
      case is Dictionary<UInt, UInt8>.Type:
        return "Dictionary<UInt, UInt8>"
      case is Dictionary<UInt, UInt16>.Type:
        return "Dictionary<UInt, UInt16>"
      case is Dictionary<UInt, UInt32>.Type:
        return "Dictionary<UInt, UInt32>"
      case is Dictionary<UInt, UInt64>.Type:
        return "Dictionary<UInt, UInt64>"
      case is Dictionary<UInt, Double>.Type:
        return "Dictionary<UInt, Double>"
      case is Dictionary<UInt, Float>.Type:
        return "Dictionary<UInt, Float>"
      case is Dictionary<UInt, Float32>.Type:
        return "Dictionary<UInt, Float32>"
      case is Dictionary<UInt, Float64>.Type:
        return "Dictionary<UInt, Float64>"
        
        /* Dictionary _ UInt Types */
      case is Dictionary<Character, UInt>.Type:
        return "Dictionary<Character, UInt>"
      case is Dictionary<Bool, UInt>.Type:
        return "Dictionary<Bool, UInt>"
      case is Dictionary<Int, UInt>.Type:
        return "Dictionary<Int, UInt>"
      case is Dictionary<Int8, UInt>.Type:
        return "Dictionary<Int8, UInt>"
      case is Dictionary<Int16, UInt>.Type:
        return "Dictionary<Int16, UInt>"
      case is Dictionary<Int32, UInt>.Type:
        return "Dictionary<Int32, UInt>"
      case is Dictionary<Int64, UInt>.Type:
        return "Dictionary<Int64, UInt>"
      case is Dictionary<UInt, UInt>.Type:
        return "Dictionary<UInt, UInt>"
      case is Dictionary<UInt8, UInt>.Type:
        return "Dictionary<UInt8, UInt>"
      case is Dictionary<UInt16, UInt>.Type:
        return "Dictionary<UInt16, UInt>"
      case is Dictionary<UInt32, UInt>.Type:
        return "Dictionary<UInt32, UInt>"
      case is Dictionary<UInt64, UInt>.Type:
        return "Dictionary<UInt64, UInt>"
      case is Dictionary<Double, UInt>.Type:
        return "Dictionary<Double, UInt>"
      case is Dictionary<Float, UInt>.Type:
        return "Dictionary<Float, UInt>"
      case is Dictionary<Float32, UInt>.Type:
        return "Dictionary<Float32, UInt>"
      case is Dictionary<Float64, UInt>.Type:
        return "Dictionary<Float64, UInt>"
        
        /* Dictionary UInt8 UInt8 Type */
      case is Dictionary<UInt8, UInt8>.Type:
        return "Dictionary<UInt8, UInt8>"
        
        /* Dictionary UInt8 _ Types */
      case is Dictionary<UInt8, Character>.Type:
        return "Dictionary<UInt8, Character>"
      case is Dictionary<UInt8, Bool>.Type:
        return "Dictionary<UInt8, Bool>"
      case is Dictionary<UInt8, Int>.Type:
        return "Dictionary<UInt8, Int>"
      case is Dictionary<UInt8, Int8>.Type:
        return "Dictionary<UInt8, Int8>"
      case is Dictionary<UInt8, Int16>.Type:
        return "Dictionary<UInt8, Int16>"
      case is Dictionary<UInt8, Int32>.Type:
        return "Dictionary<UInt8, Int32>"
      case is Dictionary<UInt8, Int64>.Type:
        return "Dictionary<UInt8, Int64>"
      case is Dictionary<UInt8, UInt>.Type:
        return "Dictionary<UInt8, UInt>"
      case is Dictionary<UInt8, UInt8>.Type:
        return "Dictionary<UInt8, UInt8>"
      case is Dictionary<UInt8, UInt16>.Type:
        return "Dictionary<UInt8, UInt16>"
      case is Dictionary<UInt8, UInt32>.Type:
        return "Dictionary<UInt8, UInt32>"
      case is Dictionary<UInt8, UInt64>.Type:
        return "Dictionary<UInt8, UInt64>"
      case is Dictionary<UInt8, Double>.Type:
        return "Dictionary<UInt8, Double>"
      case is Dictionary<UInt8, Float>.Type:
        return "Dictionary<UInt8, Float>"
      case is Dictionary<UInt8, Float32>.Type:
        return "Dictionary<UInt8, Float32>"
      case is Dictionary<UInt8, Float64>.Type:
        return "Dictionary<UInt8, Float64>"
        
        /* Dictionary _ UInt8 Types */
      case is Dictionary<Character, UInt8>.Type:
        return "Dictionary<Character, UInt8>"
      case is Dictionary<Bool, UInt8>.Type:
        return "Dictionary<Bool, UInt8>"
      case is Dictionary<Int, UInt8>.Type:
        return "Dictionary<Int, UInt8>"
      case is Dictionary<Int8, UInt8>.Type:
        return "Dictionary<Int8, UInt8>"
      case is Dictionary<Int16, UInt8>.Type:
        return "Dictionary<Int16, UInt8>"
      case is Dictionary<Int32, UInt8>.Type:
        return "Dictionary<Int32, UInt8>"
      case is Dictionary<Int64, UInt8>.Type:
        return "Dictionary<Int64, UInt8>"
      case is Dictionary<UInt, UInt8>.Type:
        return "Dictionary<UInt, UInt8>"
      case is Dictionary<UInt8, UInt8>.Type:
        return "Dictionary<UInt8, UInt8>"
      case is Dictionary<UInt16, UInt8>.Type:
        return "Dictionary<UInt16, UInt8>"
      case is Dictionary<UInt32, UInt8>.Type:
        return "Dictionary<UInt32, UInt8>"
      case is Dictionary<UInt64, UInt8>.Type:
        return "Dictionary<UInt64, UInt8>"
      case is Dictionary<Double, UInt8>.Type:
        return "Dictionary<Double, UInt8>"
      case is Dictionary<Float, UInt8>.Type:
        return "Dictionary<Float, UInt8>"
      case is Dictionary<Float32, UInt8>.Type:
        return "Dictionary<Float32, UInt8>"
      case is Dictionary<Float64, UInt8>.Type:
        return "Dictionary<Float64, UInt8>"
        
        /* Dictionary UInt16 UInt16 Type */
      case is Dictionary<UInt16, UInt16>.Type:
        return "Dictionary<UInt16, UInt16>"
        
        /* Dictionary UInt16 _ Types */
      case is Dictionary<UInt16, Character>.Type:
        return "Dictionary<UInt16, Character>"
      case is Dictionary<UInt16, Bool>.Type:
        return "Dictionary<UInt16, Bool>"
      case is Dictionary<UInt16, Int>.Type:
        return "Dictionary<UInt16, Int>"
      case is Dictionary<UInt16, Int8>.Type:
        return "Dictionary<UInt16, Int8>"
      case is Dictionary<UInt16, Int16>.Type:
        return "Dictionary<UInt16, Int16>"
      case is Dictionary<UInt16, Int32>.Type:
        return "Dictionary<UInt16, Int32>"
      case is Dictionary<UInt16, Int64>.Type:
        return "Dictionary<UInt16, Int64>"
      case is Dictionary<UInt16, UInt>.Type:
        return "Dictionary<UInt16, UInt>"
      case is Dictionary<UInt16, UInt8>.Type:
        return "Dictionary<UInt16, UInt8>"
      case is Dictionary<UInt16, UInt16>.Type:
        return "Dictionary<UInt16, UInt16>"
      case is Dictionary<UInt16, UInt32>.Type:
        return "Dictionary<UInt16, UInt32>"
      case is Dictionary<UInt16, UInt64>.Type:
        return "Dictionary<UInt16, UInt64>"
      case is Dictionary<UInt16, Double>.Type:
        return "Dictionary<UInt16, Double>"
      case is Dictionary<UInt16, Float>.Type:
        return "Dictionary<UInt16, Float>"
      case is Dictionary<UInt16, Float32>.Type:
        return "Dictionary<UInt16, Float32>"
      case is Dictionary<UInt16, Float64>.Type:
        return "Dictionary<UInt16, Float64>"
        
        /* Dictionary _ UInt16 Types */
      case is Dictionary<Character, UInt16>.Type:
        return "Dictionary<Character, UInt16>"
      case is Dictionary<Bool, UInt16>.Type:
        return "Dictionary<Bool, UInt16>"
      case is Dictionary<Int, UInt16>.Type:
        return "Dictionary<Int, UInt16>"
      case is Dictionary<Int8, UInt16>.Type:
        return "Dictionary<Int8, UInt16>"
      case is Dictionary<Int16, UInt16>.Type:
        return "Dictionary<Int16, UInt16>"
      case is Dictionary<Int32, UInt16>.Type:
        return "Dictionary<Int32, UInt16>"
      case is Dictionary<Int64, UInt16>.Type:
        return "Dictionary<Int64, UInt16>"
      case is Dictionary<UInt, UInt16>.Type:
        return "Dictionary<UInt, UInt16>"
      case is Dictionary<UInt8, UInt16>.Type:
        return "Dictionary<UInt8, UInt16>"
      case is Dictionary<UInt16, UInt16>.Type:
        return "Dictionary<UInt16, UInt16>"
      case is Dictionary<UInt32, UInt16>.Type:
        return "Dictionary<UInt32, UInt16>"
      case is Dictionary<UInt64, UInt16>.Type:
        return "Dictionary<UInt64, UInt16>"
      case is Dictionary<Double, UInt16>.Type:
        return "Dictionary<Double, UInt16>"
      case is Dictionary<Float, UInt16>.Type:
        return "Dictionary<Float, UInt16>"
      case is Dictionary<Float32, UInt16>.Type:
        return "Dictionary<Float32, UInt16>"
      case is Dictionary<Float64, UInt16>.Type:
        return "Dictionary<Float64, UInt16>"
        
        /* Dictionary UInt32 UInt32 Type */
      case is Dictionary<UInt32, UInt32>.Type:
        return "Dictionary<UInt32, UInt32>"
        
        /* Dictionary UInt32 _ Types */
      case is Dictionary<UInt32, Character>.Type:
        return "Dictionary<UInt32, Character>"
      case is Dictionary<UInt32, Bool>.Type:
        return "Dictionary<UInt32, Bool>"
      case is Dictionary<UInt32, Int>.Type:
        return "Dictionary<UInt32, Int>"
      case is Dictionary<UInt32, Int8>.Type:
        return "Dictionary<UInt32, Int8>"
      case is Dictionary<UInt32, Int16>.Type:
        return "Dictionary<UInt32, Int16>"
      case is Dictionary<UInt32, Int32>.Type:
        return "Dictionary<UInt32, Int32>"
      case is Dictionary<UInt32, Int64>.Type:
        return "Dictionary<UInt32, Int64>"
      case is Dictionary<UInt32, UInt>.Type:
        return "Dictionary<UInt32, UInt>"
      case is Dictionary<UInt32, UInt8>.Type:
        return "Dictionary<UInt32, UInt8>"
      case is Dictionary<UInt32, UInt16>.Type:
        return "Dictionary<UInt32, UInt16>"
      case is Dictionary<UInt32, UInt32>.Type:
        return "Dictionary<UInt32, UInt32>"
      case is Dictionary<UInt32, UInt64>.Type:
        return "Dictionary<UInt32, UInt64>"
      case is Dictionary<UInt32, Double>.Type:
        return "Dictionary<UInt32, Double>"
      case is Dictionary<UInt32, Float>.Type:
        return "Dictionary<UInt32, Float>"
      case is Dictionary<UInt32, Float32>.Type:
        return "Dictionary<UInt32, Float32>"
      case is Dictionary<UInt32, Float64>.Type:
        return "Dictionary<UInt32, Float64>"
        
        /* Dictionary _ UInt32 Types */
      case is Dictionary<Character, UInt32>.Type:
        return "Dictionary<Character, UInt32>"
      case is Dictionary<Bool, UInt32>.Type:
        return "Dictionary<Bool, UInt32>"
      case is Dictionary<Int, UInt32>.Type:
        return "Dictionary<Int, UInt32>"
      case is Dictionary<Int8, UInt32>.Type:
        return "Dictionary<Int8, UInt32>"
      case is Dictionary<Int16, UInt32>.Type:
        return "Dictionary<Int16, UInt32>"
      case is Dictionary<Int32, UInt32>.Type:
        return "Dictionary<Int32, UInt32>"
      case is Dictionary<Int64, UInt32>.Type:
        return "Dictionary<Int64, UInt32>"
      case is Dictionary<UInt, UInt32>.Type:
        return "Dictionary<UInt, UInt32>"
      case is Dictionary<UInt8, UInt32>.Type:
        return "Dictionary<UInt8, UInt32>"
      case is Dictionary<UInt16, UInt32>.Type:
        return "Dictionary<UInt16, UInt32>"
      case is Dictionary<UInt32, UInt32>.Type:
        return "Dictionary<UInt32, UInt32>"
      case is Dictionary<UInt64, UInt32>.Type:
        return "Dictionary<UInt64, UInt32>"
      case is Dictionary<Double, UInt32>.Type:
        return "Dictionary<Double, UInt32>"
      case is Dictionary<Float, UInt32>.Type:
        return "Dictionary<Float, UInt32>"
      case is Dictionary<Float32, UInt32>.Type:
        return "Dictionary<Float32, UInt32>"
      case is Dictionary<Float64, UInt32>.Type:
        return "Dictionary<Float64, UInt32>"
        
        /* Dictionary UInt64 UInt64 Type */
      case is Dictionary<UInt64, UInt64>.Type:
        return "Dictionary<UInt64, UInt64>"
        
        /* Dictionary UInt64 _ Types */
      case is Dictionary<UInt64, Character>.Type:
        return "Dictionary<UInt64, Character>"
      case is Dictionary<UInt64, Bool>.Type:
        return "Dictionary<UInt64, Bool>"
      case is Dictionary<UInt64, Int>.Type:
        return "Dictionary<UInt64, Int>"
      case is Dictionary<UInt64, Int8>.Type:
        return "Dictionary<UInt64, Int8>"
      case is Dictionary<UInt64, Int16>.Type:
        return "Dictionary<UInt64, Int16>"
      case is Dictionary<UInt64, Int32>.Type:
        return "Dictionary<UInt64, Int32>"
      case is Dictionary<UInt64, Int64>.Type:
        return "Dictionary<UInt64, Int64>"
      case is Dictionary<UInt64, UInt>.Type:
        return "Dictionary<UInt64, UInt>"
      case is Dictionary<UInt64, UInt8>.Type:
        return "Dictionary<UInt64, UInt8>"
      case is Dictionary<UInt64, UInt16>.Type:
        return "Dictionary<UInt64, UInt16>"
      case is Dictionary<UInt64, UInt32>.Type:
        return "Dictionary<UInt64, UInt32>"
      case is Dictionary<UInt64, UInt64>.Type:
        return "Dictionary<UInt64, UInt64>"
      case is Dictionary<UInt64, Double>.Type:
        return "Dictionary<UInt64, Double>"
      case is Dictionary<UInt64, Float>.Type:
        return "Dictionary<UInt64, Float>"
      case is Dictionary<UInt64, Float32>.Type:
        return "Dictionary<UInt64, Float32>"
      case is Dictionary<UInt64, Float64>.Type:
        return "Dictionary<UInt64, Float64>"
        
        /* Dictionary _ UInt64 Types */
      case is Dictionary<Character, UInt64>.Type:
        return "Dictionary<Character, UInt64>"
      case is Dictionary<Bool, UInt64>.Type:
        return "Dictionary<Bool, UInt64>"
      case is Dictionary<Int, UInt64>.Type:
        return "Dictionary<Int, UInt64>"
      case is Dictionary<Int8, UInt64>.Type:
        return "Dictionary<Int8, UInt64>"
      case is Dictionary<Int16, UInt64>.Type:
        return "Dictionary<Int16, UInt64>"
      case is Dictionary<Int32, UInt64>.Type:
        return "Dictionary<Int32, UInt64>"
      case is Dictionary<Int64, UInt64>.Type:
        return "Dictionary<Int64, UInt64>"
      case is Dictionary<UInt, UInt64>.Type:
        return "Dictionary<UInt, UInt64>"
      case is Dictionary<UInt8, UInt64>.Type:
        return "Dictionary<UInt8, UInt64>"
      case is Dictionary<UInt16, UInt64>.Type:
        return "Dictionary<UInt16, UInt64>"
      case is Dictionary<UInt32, UInt64>.Type:
        return "Dictionary<UInt32, UInt64>"
      case is Dictionary<UInt64, UInt64>.Type:
        return "Dictionary<UInt64, UInt64>"
      case is Dictionary<Double, UInt64>.Type:
        return "Dictionary<Double, UInt64>"
      case is Dictionary<Float, UInt64>.Type:
        return "Dictionary<Float, UInt64>"
      case is Dictionary<Float32, UInt64>.Type:
        return "Dictionary<Float32, UInt64>"
      case is Dictionary<Float64, UInt64>.Type:
        return "Dictionary<Float64, UInt64>"
        
        /* Dictionary Double Double Type */
      case is Dictionary<Double, Double>.Type:
        return "Dictionary<Double, Double>"
        
        /* Dictionary Double _ Types */
      case is Dictionary<Double, Character>.Type:
        return "Dictionary<Double, Character>"
      case is Dictionary<Double, Bool>.Type:
        return "Dictionary<Double, Bool>"
      case is Dictionary<Double, Int>.Type:
        return "Dictionary<Double, Int>"
      case is Dictionary<Double, Int8>.Type:
        return "Dictionary<Double, Int8>"
      case is Dictionary<Double, Int16>.Type:
        return "Dictionary<Double, Int16>"
      case is Dictionary<Double, Int32>.Type:
        return "Dictionary<Double, Int32>"
      case is Dictionary<Double, Int64>.Type:
        return "Dictionary<Double, Int64>"
      case is Dictionary<Double, UInt>.Type:
        return "Dictionary<Double, UInt>"
      case is Dictionary<Double, UInt8>.Type:
        return "Dictionary<Double, UInt8>"
      case is Dictionary<Double, UInt16>.Type:
        return "Dictionary<Double, UInt16>"
      case is Dictionary<Double, UInt32>.Type:
        return "Dictionary<Double, UInt32>"
      case is Dictionary<Double, UInt64>.Type:
        return "Dictionary<Double, UInt64>"
      case is Dictionary<Double, Double>.Type:
        return "Dictionary<Double, Double>"
      case is Dictionary<Double, Float>.Type:
        return "Dictionary<Double, Float>"
      case is Dictionary<Double, Float32>.Type:
        return "Dictionary<Double, Float32>"
      case is Dictionary<Double, Float64>.Type:
        return "Dictionary<Double, Float64>"
        
        /* Dictionary _ Double Types */
      case is Dictionary<Character, Double>.Type:
        return "Dictionary<Character, Double>"
      case is Dictionary<Bool, Double>.Type:
        return "Dictionary<Bool, Double>"
      case is Dictionary<Int, Double>.Type:
        return "Dictionary<Int, Double>"
      case is Dictionary<Int8, Double>.Type:
        return "Dictionary<Int8, Double>"
      case is Dictionary<Int16, Double>.Type:
        return "Dictionary<Int16, Double>"
      case is Dictionary<Int32, Double>.Type:
        return "Dictionary<Int32, Double>"
      case is Dictionary<Int64, Double>.Type:
        return "Dictionary<Int64, Double>"
      case is Dictionary<UInt, Double>.Type:
        return "Dictionary<UInt, Double>"
      case is Dictionary<UInt8, Double>.Type:
        return "Dictionary<UInt8, Double>"
      case is Dictionary<UInt16, Double>.Type:
        return "Dictionary<UInt16, Double>"
      case is Dictionary<UInt32, Double>.Type:
        return "Dictionary<UInt32, Double>"
      case is Dictionary<UInt64, Double>.Type:
        return "Dictionary<UInt64, Double>"
      case is Dictionary<Double, Double>.Type:
        return "Dictionary<Double, Double>"
      case is Dictionary<Float, Double>.Type:
        return "Dictionary<Float, Double>"
      case is Dictionary<Float32, Double>.Type:
        return "Dictionary<Float32, Double>"
      case is Dictionary<Float64, Double>.Type:
        return "Dictionary<Float64, Double>"
        
        /* Dictionary Float Float Type */
      case is Dictionary<Float, Float>.Type:
        return "Dictionary<Float, Float>"
        
        /* Dictionary Float _ Types */
      case is Dictionary<Float, Character>.Type:
        return "Dictionary<Float, Character>"
      case is Dictionary<Float, Bool>.Type:
        return "Dictionary<Float, Bool>"
      case is Dictionary<Float, Int>.Type:
        return "Dictionary<Float, Int>"
      case is Dictionary<Float, Int8>.Type:
        return "Dictionary<Float, Int8>"
      case is Dictionary<Float, Int16>.Type:
        return "Dictionary<Float, Int16>"
      case is Dictionary<Float, Int32>.Type:
        return "Dictionary<Float, Int32>"
      case is Dictionary<Float, Int64>.Type:
        return "Dictionary<Float, Int64>"
      case is Dictionary<Float, UInt>.Type:
        return "Dictionary<Float, UInt>"
      case is Dictionary<Float, UInt8>.Type:
        return "Dictionary<Float, UInt8>"
      case is Dictionary<Float, UInt16>.Type:
        return "Dictionary<Float, UInt16>"
      case is Dictionary<Float, UInt32>.Type:
        return "Dictionary<Float, UInt32>"
      case is Dictionary<Float, UInt64>.Type:
        return "Dictionary<Float, UInt64>"
      case is Dictionary<Float, Double>.Type:
        return "Dictionary<Float, Double>"
      case is Dictionary<Float, Float>.Type:
        return "Dictionary<Float, Float>"
      case is Dictionary<Float, Float32>.Type:
        return "Dictionary<Float, Float32>"
      case is Dictionary<Float, Float64>.Type:
        return "Dictionary<Float, Float64>"
        
        /* Dictionary _ Float Types */
      case is Dictionary<Character, Float>.Type:
        return "Dictionary<Character, Float>"
      case is Dictionary<Bool, Float>.Type:
        return "Dictionary<Bool, Float>"
      case is Dictionary<Int, Float>.Type:
        return "Dictionary<Int, Float>"
      case is Dictionary<Int8, Float>.Type:
        return "Dictionary<Int8, Float>"
      case is Dictionary<Int16, Float>.Type:
        return "Dictionary<Int16, Float>"
      case is Dictionary<Int32, Float>.Type:
        return "Dictionary<Int32, Float>"
      case is Dictionary<Int64, Float>.Type:
        return "Dictionary<Int64, Float>"
      case is Dictionary<UInt, Float>.Type:
        return "Dictionary<UInt, Float>"
      case is Dictionary<UInt8, Float>.Type:
        return "Dictionary<UInt8, Float>"
      case is Dictionary<UInt16, Float>.Type:
        return "Dictionary<UInt16, Float>"
      case is Dictionary<UInt32, Float>.Type:
        return "Dictionary<UInt32, Float>"
      case is Dictionary<UInt64, Float>.Type:
        return "Dictionary<UInt64, Float>"
      case is Dictionary<Double, Float>.Type:
        return "Dictionary<Double, Float>"
      case is Dictionary<Float, Float>.Type:
        return "Dictionary<Float, Float>"
      case is Dictionary<Float32, Float>.Type:
        return "Dictionary<Float32, Float>"
      case is Dictionary<Float64, Float>.Type:
        return "Dictionary<Float64, Float>"
        
        /* Dictionary Float32 Float32 Type */
      case is Dictionary<Float32, Float32>.Type:
        return "Dictionary<Float32, Float32>"
        
        /* Dictionary Float32 _ Types */
      case is Dictionary<Float32, Character>.Type:
        return "Dictionary<Float32, Character>"
      case is Dictionary<Float32, Bool>.Type:
        return "Dictionary<Float32, Bool>"
      case is Dictionary<Float32, Int>.Type:
        return "Dictionary<Float32, Int>"
      case is Dictionary<Float32, Int8>.Type:
        return "Dictionary<Float32, Int8>"
      case is Dictionary<Float32, Int16>.Type:
        return "Dictionary<Float32, Int16>"
      case is Dictionary<Float32, Int32>.Type:
        return "Dictionary<Float32, Int32>"
      case is Dictionary<Float32, Int64>.Type:
        return "Dictionary<Float32, Int64>"
      case is Dictionary<Float32, UInt>.Type:
        return "Dictionary<Float32, UInt>"
      case is Dictionary<Float32, UInt8>.Type:
        return "Dictionary<Float32, UInt8>"
      case is Dictionary<Float32, UInt16>.Type:
        return "Dictionary<Float32, UInt16>"
      case is Dictionary<Float32, UInt32>.Type:
        return "Dictionary<Float32, UInt32>"
      case is Dictionary<Float32, UInt64>.Type:
        return "Dictionary<Float32, UInt64>"
      case is Dictionary<Float32, Double>.Type:
        return "Dictionary<Float32, Double>"
      case is Dictionary<Float32, Float>.Type:
        return "Dictionary<Float32, Float>"
      case is Dictionary<Float32, Float32>.Type:
        return "Dictionary<Float32, Float32>"
      case is Dictionary<Float32, Float64>.Type:
        return "Dictionary<Float32, Float64>"
        
        /* Dictionary _ Float32 Types */
      case is Dictionary<Character, Float32>.Type:
        return "Dictionary<Character, Float32>"
      case is Dictionary<Bool, Float32>.Type:
        return "Dictionary<Bool, Float32>"
      case is Dictionary<Int, Float32>.Type:
        return "Dictionary<Int, Float32>"
      case is Dictionary<Int8, Float32>.Type:
        return "Dictionary<Int8, Float32>"
      case is Dictionary<Int16, Float32>.Type:
        return "Dictionary<Int16, Float32>"
      case is Dictionary<Int32, Float32>.Type:
        return "Dictionary<Int32, Float32>"
      case is Dictionary<Int64, Float32>.Type:
        return "Dictionary<Int64, Float32>"
      case is Dictionary<UInt, Float32>.Type:
        return "Dictionary<UInt, Float32>"
      case is Dictionary<UInt8, Float32>.Type:
        return "Dictionary<UInt8, Float32>"
      case is Dictionary<UInt16, Float32>.Type:
        return "Dictionary<UInt16, Float32>"
      case is Dictionary<UInt32, Float32>.Type:
        return "Dictionary<UInt32, Float32>"
      case is Dictionary<UInt64, Float32>.Type:
        return "Dictionary<UInt64, Float32>"
      case is Dictionary<Double, Float32>.Type:
        return "Dictionary<Double, Float32>"
      case is Dictionary<Float, Float32>.Type:
        return "Dictionary<Float, Float32>"
      case is Dictionary<Float32, Float32>.Type:
        return "Dictionary<Float32, Float32>"
      case is Dictionary<Float64, Float32>.Type:
        return "Dictionary<Float64, Float32>"
        
        /* Dictionary Float64 Float64 Type */
      case is Dictionary<Float64, Float64>.Type:
        return "Dictionary<Float64, Float64>"
        
        /* Dictionary Float64 _ Types */
      case is Dictionary<Float64, Character>.Type:
        return "Dictionary<Float64, Character>"
      case is Dictionary<Float64, Bool>.Type:
        return "Dictionary<Float64, Bool>"
      case is Dictionary<Float64, Int>.Type:
        return "Dictionary<Float64, Int>"
      case is Dictionary<Float64, Int8>.Type:
        return "Dictionary<Float64, Int8>"
      case is Dictionary<Float64, Int16>.Type:
        return "Dictionary<Float64, Int16>"
      case is Dictionary<Float64, Int32>.Type:
        return "Dictionary<Float64, Int32>"
      case is Dictionary<Float64, Int64>.Type:
        return "Dictionary<Float64, Int64>"
      case is Dictionary<Float64, UInt>.Type:
        return "Dictionary<Float64, UInt>"
      case is Dictionary<Float64, UInt8>.Type:
        return "Dictionary<Float64, UInt8>"
      case is Dictionary<Float64, UInt16>.Type:
        return "Dictionary<Float64, UInt16>"
      case is Dictionary<Float64, UInt32>.Type:
        return "Dictionary<Float64, UInt32>"
      case is Dictionary<Float64, UInt64>.Type:
        return "Dictionary<Float64, UInt64>"
      case is Dictionary<Float64, Double>.Type:
        return "Dictionary<Float64, Double>"
      case is Dictionary<Float64, Float>.Type:
        return "Dictionary<Float64, Float>"
      case is Dictionary<Float64, Float32>.Type:
        return "Dictionary<Float64, Float32>"
      case is Dictionary<Float64, Float64>.Type:
        return "Dictionary<Float64, Float64>"
        
        /* Dictionary _ Float64 Types */
      case is Dictionary<Character, Float64>.Type:
        return "Dictionary<Character, Float64>"
      case is Dictionary<Bool, Float64>.Type:
        return "Dictionary<Bool, Float64>"
      case is Dictionary<Int, Float64>.Type:
        return "Dictionary<Int, Float64>"
      case is Dictionary<Int8, Float64>.Type:
        return "Dictionary<Int8, Float64>"
      case is Dictionary<Int16, Float64>.Type:
        return "Dictionary<Int16, Float64>"
      case is Dictionary<Int32, Float64>.Type:
        return "Dictionary<Int32, Float64>"
      case is Dictionary<Int64, Float64>.Type:
        return "Dictionary<Int64, Float64>"
      case is Dictionary<UInt, Float64>.Type:
        return "Dictionary<UInt, Float64>"
      case is Dictionary<UInt8, Float64>.Type:
        return "Dictionary<UInt8, Float64>"
      case is Dictionary<UInt16, Float64>.Type:
        return "Dictionary<UInt16, Float64>"
      case is Dictionary<UInt32, Float64>.Type:
        return "Dictionary<UInt32, Float64>"
      case is Dictionary<UInt64, Float64>.Type:
        return "Dictionary<UInt64, Float64>"
      case is Dictionary<Double, Float64>.Type:
        return "Dictionary<Double, Float64>"
      case is Dictionary<Float, Float64>.Type:
        return "Dictionary<Float, Float64>"
      case is Dictionary<Float32, Float64>.Type:
        return "Dictionary<Float32, Float64>"
      case is Dictionary<Float64, Float64>.Type:
        return "Dictionary<Float64, Float64>"
        
      default:
        return "Unclassified"
      }
    }
    
  }
}