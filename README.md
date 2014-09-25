JSONMarshal
===========

Go's unMarshal JSON function in Swift

func unMarshal(#marshalClass: NSObject.Type, data: NSData) -> NSMutableArray

parameters: marshalClass:   nominated class structure to parse JSON data into 
            data:           NSData byte buffer containing unparsed JSON

Unmarshal parses the JSON-encoded data and stores the result in an array of a nominated class
  
Excerpt from Go:
================
  Unmarshal uses the inverse of the encodings that Marshal uses, allocating maps, slices, and pointers as necessary, with the following additional rules:
  1. To unmarshal JSON into a pointer, Unmarshal first handles the case of the JSON being the JSON literal null. In that case, Unmarshal sets the pointer to nil. Otherwise, Unmarshal unmarshals the JSON into the value pointed at by the pointer. If the pointer is nil, Unmarshal allocates a new value for it to point to.
  2. To unmarshal JSON into a struct, Unmarshal matches incoming object keys to the keys used by Marshal (either the struct field name or its tag), preferring an exact match but also accepting a case-insensitive match.
  
Key differences with this one:
==============================
  1. Currently returns NSMutableArray as opposed to inout (unmarshalling JSON into a pointer) 
  2. No provision for complex structures (yet!)
  3. A NSObject class is used as opposed to Struct re KVC

TO DOs:
=======
1. Possible use of generics to simplify type conversion; or something else
2. Investigate adaptation for more complex JSON data feeds.
