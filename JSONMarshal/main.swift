//
//  main.swift
//  JSONMarshal
//
//  Created by Vaughn Williams on 2014/09/23.
//  Copyright (c) 2014 Vaughn Williams. All rights reserved.
//

import Foundation

//func printRec(record: Location) {
//  println("\(record.name); \(record.address); \(record.longitude); \(record.latitude); \(record.isBusiness)")
//}
////
//if let jsonData = NSData(contentsOfFile: "/Users/VW/Desktop/JSONMarshal/feed.json") {
//  let viewData = Json.unMarshal(marshalClass: Location.self, data: jsonData)
//  //
//  //for i in viewData {
//  //  printRec(i as Location)
//  //}
//}

//func objcName(object: Any) -> String {
//  println("------- \(object) -----")
//  
//  if let value: AnyClass = object as? AnyClass {
//      println("===== \(value)")
//  }
//  
//    if let indexEnd = value.rangeOfString(":") {
//      println("index: \(indexEnd.endIndex)")
//    }
  
//  return ""
//}

//func getRepository(targetClass: Any.Type) -> Marshal.Repository {
//  var result = Marshal.Repository()
//  var mClass = Marshal.Class(name: typeName(targetClass).1, type: targetClass)
//  
//  let reflect_targetClass = reflect(targetClass)
//  for var index = 0; index < reflect_targetClass.count; ++index {
//    let (propertyName, childMirror) = reflect_targetClass[index]
//    mClass.append(Marshal.Property(name: propertyName, type: childMirror.valueType))
//  }
//  return result
//}

func getClasses(targetClass: Any.Type, inout targetRepository: Marshal.Repository) -> Marshal.Class {
  var mClass = Marshal.Class(name: Marshal.Reflection.typeName(targetClass).1, type: targetClass)
  let reflectClass = reflect(targetClass)
  
  Marshal.Reflection.properties(reflectClass, marshalClass: &mClass)
  
//  for property in  {
//      mClass.append(property)
//  }
  return mClass
}

typealias ATel = Address.Telephone
typealias ATCat = Address.Telephone.Category
typealias ATLoc = Address.Telephone.Locality

//let addr = Address(name: "jack", address: "42 Chance Avenue", latitude: 23.5634, longitude: 24.4646, isBusiness: true, telephones: [ATel(number: "5551808", category: ATCat.Landline, locality: ATLoc.Home)])

let addr = Address()
var mClass = Marshal.Class(name: Marshal.Reflection.typeName(addr).1, type: addr)

Marshal.Reflection.properties(reflect(addr), marshalClass: &mClass)


println("Reflected class: \(mClass.name)")
println(String(count: 100, repeatedValue: Character("-")))
println(" #  " + "name".padRight(12) + "disposition".padRight(16) + "classname".padRight(31) + "type")
println(String(count: 100, repeatedValue: Character("-")))
for (index, property) in enumerate(mClass.properties) {
  println("\(index.description.padLeft(2)). \(property.name.padRight(12))\(property.disposition.stringValue().padRight(16))\(property.className.padRight(31))\(property.typeString)")
}
println(String(count: 100, repeatedValue: Character("-")))


//let abc = JSONMarshal.Address()
//let def = JSONMarshal.Address.Telephone()

//
//// http://stackoverflow.com/a/24196632
//let aClass = NSClassFromString("JSONMarshal_Address_Telephone") as NSObject.Type
//let anObject = aClass() as JSONMarshal.Address.Telephone
//println(anObject.category.hashValue)
//
//
//let rep = MarshalRepository(index: Marshal(propertyKey: "Locations.Name", jsonKey: "/Location/Name"),
//                                   Marshal(propertyKey: "Locations.Address", jsonKey: "/Location/Address"))


//ExploreItem(addr)
//println()
//println(reflect_addr.0.value)

//Json.reflectPropertyAttributes(reflect(addr))
//Json.reflectPropertyAttributes(reflect(addr.telephones[0]))

//println("\(addr.telephones[0].number)")



