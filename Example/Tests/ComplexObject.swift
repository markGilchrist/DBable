//
//  ObjectChild.swift
//  GuardApp
//
//  Created by Mark on 09/08/2016.
//  Copyright © 2016 Mark. All rights reserved.
//

import Foundation
import DBable

struct  ComplexObject : DBable {
    let id:Int
    let name : String
    let user: User?
    let photos: [Photo]
    let numbers: [Int]
    
    
    init?(json: JSON) {
        guard let id:Int = json["id"] as? Int else{ return nil }
        self.id          = id
        self.name        = json["name"] as? String ?? "fail"
        print(json["numbers"])
        self.numbers     = json["numbers"] as? [Int] ?? []
        let userJson : JSON? = json["user"] as? JSON
        self.user        = User(json: userJson ?? [:])
        self.photos      = Photo.getArray(input: json["photos"])
    }
    
    static var preferedPrimaryKeyName: String? { return "id" }
    static var forriegnKeyName: String? = nil
    static var columns: [Column] = [Column(name: "id", type: .INTEGER), Column(name: "name",type: .TEXT)]
    static var arrayType:[String: ColumnTypes] = ["numbers" : .INTEGER]
    
    var columnMap: [String : Any] {return ["id" : self.id,"name":self.name]}
    var arrayMap: [String : [Any]] {return ["numbers" : self.numbers]}
    
    public static func createReferanceTables(){
        // create numbers table
        
    }
    
}
