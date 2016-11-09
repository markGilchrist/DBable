//
//  User.swift
//  GuardApp
//
//  Created by Mark on 30/06/2016.
//  Copyright © 2016 Mark. All rights reserved.
//

import Foundation
import DBable


/** Models the user*/
public struct User :JSONDecodable{
    
    /// This is set by the sever and is unique, if the id is not set yet then it is = 0
    public let userID: Int
    
    /// This is the User's firstname
    public let fName: String
    
    /// This is the User's lastname
    public let lName: String
    
    /// This is the email of the User
    public let email: String
    
    /// This is the hash of the password of the user
    internal let password:String?
    
    /// This is the date at which the user session be comes invalidated
    public let vaildUntill:Date?
    
    public init?(json: JSON) {
        guard let userId        = json[K.Id]    as? Int    else { print("couldn't pass -> id ");return nil}
        guard let lastName      = json[K.lname] as? String else { print("couldn't pass -> last_name"); return nil}
        guard let firstname     = json[K.fname] as? String else { print("couldn't pass -> first_name"); return nil}
        guard let email         = json[K.email] as? String else { print("couldn't pass -> email"); return nil}
        let vaildUntill         = json[K.vaildUntil] as? Date?
       // print("date is -> \(json)")
        
        self.userID         = userId
        self.fName          = firstname
        self.lName          = lastName
        self.email          = email
        self.password       = json[K.password] as? String ?? nil
        self.vaildUntill    = vaildUntill ?? nil
    }
    
    public init(fName:String,lName:String,email:String,password:String){
        self.userID     = 0
        self.fName      = fName
        self.lName      = lName
        self.email      = email
        self.password   = password
        self.vaildUntill = nil
    }
    
}

private struct K {
    static let Id           = "id"
    static let fname        = "firstname"
    static let lname        = "lastname"
    static let email        = "email"
    static let vaildUntil   = "validuntil"
    static let password     = "password"
}


extension User: DBable {

    public static var objectName: String  = "USERS"
    public static var preferedPrimaryKeyName: String? = K.Id
    public static var forriegnKeyName:String?  = ComplexObject.primaryKeyName 
    public static var columns: [Column] =
        [
            Column(name: User.primaryKeyName, type: .INTEGER),
            Column(name: K.fname, type: .TEXT),
            Column(name: K.lname, type: .TEXT),
            Column(name: K.email, type: .TEXT),
            Column(name: K.vaildUntil, type: .DATE)
        ]
    
    public static var defaults: [String : String] { return [:]}
    public var columnMap:[String:Any] {
        return [
            K.Id         : self.userID ,
            K.fname      : self.fName,
            K.lname      : self.lName,
            K.email      : self.email,
            K.vaildUntil : self.vaildUntill
        ]
    }
    
    
    
    
    public var columnMapWithPword:[String:Any]{
        var cols = self.columnMap
        cols[K.password] = self.password
        return cols
    }
    
    public static func getAllValid() -> [User]{
        return User.getAllWhereColumn(column: columns[4], greaterThanValue: NSDate())
    }
    
    public func updateValidUntil(date:Date){
        self.updateColumnWithValue(column: User.columns[4] ,value:date)
    }
}
