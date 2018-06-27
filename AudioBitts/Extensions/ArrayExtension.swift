//
//  ArrayExtension.swift
//  AudioBitts
//
//  Created by Ashok on 06/04/16.
//  Copyright © 2016 mobileways. All rights reserved.
//

import Foundation

//extension Array {
//    func removeDuplicateUsers() -> [ABUser] {
//        var result = [ABUser]()
//    
//        for value in self {
//            let value = value as! ABUser
//
//            if result.contains(value) == false {
//                result.append(value)
//            }
//        }
//        
//        return result
//    }
//}

func uniq<S: Sequence, E: Hashable>(_ source: S) -> [E] where E == S.Iterator.Element {
    var seen = [E: Bool]()
    return source.filter { seen.updateValue(true, forKey: $0) == nil }
}

func ==(lhs: ABUser, rhs: ABUser) -> Bool {
    return lhs.bitUserName == rhs.bitUserName // && lhs.someOtherEquatableProperty == rhs.someOtherEquatableProperty
}

//struct SomeCustomType {
//    
//    let id: Int
//    
//    // ...
//    
//}

//extension SomeCustomType: Hashable {
//    var hashValue: Int {
//        return id
//    }
//}


//var someCustomTypes = [SomeCustomType(id: 1), SomeCustomType(id: 2), SomeCustomType(id: 3), SomeCustomType(id: 1)]
//
//print(someCustomTypes.count) // 4
//
//someCustomTypes = uniq(someCustomTypes)
//
//print(someCustomTypes.count) // 3
