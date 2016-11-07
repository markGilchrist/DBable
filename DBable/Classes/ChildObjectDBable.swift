//
//  DBableOneToMany.swift
//  GuardApp
//
//  Created by Mark on 04/07/2016.
//  Copyright © 2016 Mark. All rights reserved.
//

import Foundation

protocol ChildObjectDBable : DBable{
    static var parentPrimaryKeyColumns:[Column] { get }
    
    /** This is call to retrieve all the Objects in the Database related to a foreign key */
    static func getAllFor<T: ChildObjectDBable>(foreignColumn:Column,value:AnyObject)->[T]
    
    static func getDictonaryObject(foreignColumn:Column,value:AnyObject) -> JSON
}

extension ChildObjectDBable {
   
    
/**
     This function returns a closure that will automatically create you an insert string with place holders
*/
    final static var insertStringWithParentKeys: ()->String {
        return {
            var strings:[String]    = []
            var endString:[String]  = []
            for column in Self.columns{
                strings.append("\(column.columnName.uppercased()) \(defaults[column.columnName] ?? "")")
            }
            for parent in Self.parentPrimaryKeyColumns {
                strings.append("\(parent.columnName.uppercased())")
            }
            for _ in 0 ..< strings.count {
                endString.append("?")
            }
            return "\(DB.insert) \(Self.objectName) (\(strings.joined(separator: ","))) VALUES (\(endString.joined(separator: ",")));"
        }
    }
    


    
/**
     This function returns a closure that will automatically create you create table string
*/
    final static var createTableString: ()->String {
        return {
            var str = ""
            for (i,column) in Self.columns.enumerated(){
                let innerStr = "\(column.columnName.uppercased()) \(column.columnType.rawValue)"
                if i == 0 {
                    if column.columnName == Self.primaryKeyName {
                        str += "\(innerStr) \(DB.primaryKey), "
                    } else if !Self.isPrimaryKeyUsed {
                        str += "\(DB.defaultId), \(innerStr)"
                    }else {
                        // assertionFailure("")
                    }
                } else {
                    str += innerStr
                    if let def = defaults[column.columnName] { str += def }
                    if i + 1 != Self.columns.count {
                        str += ", "
                    }
                }
            }
            for column in Self.parentPrimaryKeyColumns {
                str += "\(column.columnName) \(column.columnType.rawValue)"
            }
            return "\(DB.createTable) \(Self.objectName) (\(str));"
        }
    }
    
/**
     
     This default implementation of the save, the function takes the insert string and
     uses the Column Map to populate the values
     
     - note: this implentation does not check to see if the insert is unique
     
*/
    func insert(parentKey:String, value:AnyObject){
        DataLayer.instance.myQueue.inDatabase { db in
            if Self.parentPrimaryKeyColumns.count == 0 {
                let args = self.columnMap.map({ $0.1})
                db?.executeUpdate(Self.insertString(), withArgumentsIn:args )
            }else{
//                let args = self.columnMap.map({$0.1})
//                print(args)
            }
        }
        
    }
    
    static func getAllFor<T: ChildObjectDBable>(foreignColumn:Column,value:AnyObject)->[T]{
        var obj:[T?] = []
        DataLayer.instance.myQueue.inDatabase{ db in
            if let results = db?.executeQuery(Self.selectAllWhereColumnEquals(foreignColumn), withArgumentsIn: [value]) {
                let json = Self.resultSetToJSON(results: results)
                let _ = json.map({obj.append(T(json:$0))})
            }
        }
        return obj.flatMap{$0}
    }


}
