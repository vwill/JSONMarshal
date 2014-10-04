//
//  StringExtension.swift
//  testswift
//
//  Created by Vaughn Williams on 2014/06/29.
//  Copyright (c) 2014 Vaughn Williams. All rights reserved.
//

import Foundation

extension String {
  func contains(searchString: String) -> Bool {
    return indexOf(searchString).location != NSNotFound
  }
  
  func endsWith(searchString: String) -> Bool {
    return self.hasSuffix(searchString)
  }
  
  func indexOf(searchString: String) -> (location: Int, length: Int) {
    let result: NSRange = (self as NSString).rangeOfString(searchString)
    return (result.location, result.length)
  }
  
  func indexOf(searchString: String, startIndex: Int) -> (location: Int, length: Int) {
    let startRange = NSMakeRange(startIndex, self.length - startIndex)
    let result : NSRange = (self as NSString).rangeOfString(searchString, options: nil, range: startRange)
    return (result.location, result.length)
  }
  
  func insert(insertIndex: Int, _ string: String) -> String {
    let finalIndex: Int = insertIndex > self.length ? self.length:insertIndex
    return self[0..<finalIndex] + string + self[finalIndex..<length]
  }
  
  func left(width: Int) -> String {
    return self[0..<width]
  }
  
  var length: Int { return countElements(self) }
  
  func padRight(totalWidth: Int, padString: String = " ") -> String {
    return self.stringByPaddingToLength(totalWidth, withString: padString, startingAtIndex: 0)
  }
  
  func padLeft(totalWidth: Int, padString: String = " ") -> String {
    if self.length <= totalWidth { return "".padRight(totalWidth - self.length, padString: padString) + self }
    else { return self }
  }
  
  func right(width: Int) -> String {
    let startIndex = self.length - width
    return self[startIndex..<self.length]
  }
  
  func subString(startIndex: Int, width: Int) -> String
  {
    return self[startIndex..<startIndex + width]
  }
  
  func startsWith(searchString: String) -> Bool {
    return self.hasPrefix(searchString)
  }
  
  var trimStart: String {
  let range = rangeOfCharacterFromSet(NSCharacterSet.whitespaceAndNewlineCharacterSet().invertedSet)
    return self[range!.startIndex..<endIndex]
  }
  
  var trimEnd: String {
  let range = rangeOfCharacterFromSet(NSCharacterSet.whitespaceAndNewlineCharacterSet().invertedSet,
    options: NSStringCompareOptions.BackwardsSearch)
    return self[startIndex..<range!.endIndex]
  }
  var trim: String { return self.trimStart.trimEnd }
  
  var toLower: String { return self.lowercaseString }
  func toLower(locale: NSLocale) -> String {
    return self.lowercaseStringWithLocale(locale)
  }
  
  var toUpper: String { return self.uppercaseString }
  func toUpper(locale: NSLocale) -> String {
    return self.uppercaseStringWithLocale(locale)
  }
  
  func replace(oldString: String, newString: String) -> String {
    return self.stringByReplacingOccurrencesOfString(oldString, withString: newString)
  }
  
  subscript (i: Int) -> String {
    return String(Array(self)[i])
  }
  
  subscript (r: Range<Int>) -> String {
    var start = advance(startIndex, r.startIndex)
    var end = advance(startIndex, r.endIndex)
    return substringWithRange(Range(start: start, end: end))
  }
}
