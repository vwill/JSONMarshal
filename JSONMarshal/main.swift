//
//  main.swift
//  JSONMarshal
//
//  Created by Vaughn Williams on 2014/09/23.
//  Copyright (c) 2014 Vaughn Williams. All rights reserved.
//

import Foundation

func printRec(record: Location) {
  println("\(record.name); \(record.address); \(record.longitude); \(record.latitude); \(record.isBusiness)")
}

let jsonData = NSData(contentsOfFile: "/Users/VW/Desktop/JSONMarshal/feed.json")

let viewData = json.unMarshal(marshalClass: Location.self, data: jsonData)
for i in viewData {
  printRec(i as Location)
}

