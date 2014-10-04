//
//  marshal.swift
//  JSONMarshal
//
//  Created by Vaughn Williams on 2014/09/29.
//  Copyright (c) 2014 Vaughn Williams. All rights reserved.
//

import Foundation

public class Marshal {
  /** Repository of Reflected Classes
  */
  internal class Repository {
    var classes = [Class]()
    
    init(classes: Class...) {
      for cls in classes {
        self.classes.append(cls)
      }
    }
    
    func append(classes: Class...) {
      for Class in classes {
        self.classes.append(Class)
      }
    }
  }
  
  /** Storage for a Reflected Class and Relevant Attributes
  */
  internal class Class {
    let name: String
    let type: Any
    var properties = [Property]()
    
    init(name: String, type: Any, properties: Property...) {
      self.name = name
      self.type = type
      for property in properties {
        self.properties.append(property)
      }
    }
    
    func append(properties: Property...) {
      for Property in properties {
        self.properties.append(Property)
      }
    }
  }
  
  /** Storage for Reflected Properties and Relevant Attributes
  */
  internal class Property {
    let name: String
    let disposition: Marshal.Reflection.Disposition
    let className: String
    let type: Any
    let typeString: String
    
    init(name: String, disposition: Marshal.Reflection.Disposition, className: String, type: Any, typeString: String) {
      self.name = name
      self.disposition = disposition
      self.className = className
      self.type = type
      self.typeString = typeString
    }
    
    convenience init() {
      self.init(name: "", disposition: Marshal.Reflection.Disposition.Invalid, className: "", type: String.self, typeString: "")
    }
  }
}
