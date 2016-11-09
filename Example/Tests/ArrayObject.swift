//
//  TestChildObject.swift
//  GuardApp
//
//  Created by Mark on 28/07/2016.
//  Copyright © 2016 Mark. All rights reserved.
//

import Foundation
import DBable


/** 
    This is a test One to many Object
 */
struct ArrayObject {
    let id:Int
    let prices:[Int]
    
}

extension ArrayObject : DBable {
    /** This is What maps the values to the columns  */
    public var columnMap: [String : Any] {return [:]}
    static var forriegnKeyName: String? = nil
    static var objectName: String = "arrayobject"
    static var columns: [Column] = []
    static var preferedPrimaryKeyName: String? = "id"
    
    var arrayMap:[String : [Any]] {
        return ["prices" : self.prices]
    }

    static var primaryKeyName :String {
        return "complextObject"
    }
    
    static var objectType:[String:ColumnTypes] {
        return ["prices": .INTEGER]
    }
    
    init?(json: JSON) {
        guard let id    = json["id"] as? Int else { return nil }
        self.id         = id
        self.prices     = json["prices"] as? [Int] ?? []
    }
    


}
