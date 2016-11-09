//
//  DBableFunctions.swift
//  GuardApp
//
//  Created by Mark on 03/07/2016.
//  Copyright © 2016 Mark. All rights reserved.
//

import Foundation
import FMDB
extension DBable {
    
    /// boiler plate func printing a warning to the console
    private func noPrimaryKey(){
        print("Warning, with out using primary key this will fail")
    }
    
    
    /**
         This function takes an FMDB result set and transforms it into a JSON array. 
        
         - note: **DO NOT** call resultSet.next() if you do that the first row of the 
         resultSet will be ignored
         
         - note: **DO NOT** call .close() on the resultSet. All of
         that is handled in this function
     */
    public static func resultSetToJSON(results:FMResultSet) -> [JSON] {
//        var json:[JSON] = []
//        while results.next() {
//            var packet: JSON = [:]
//            for column in Self.columns {
//                switch column.columnType {
//                case .TEXT:
//                    packet[column.columnName] = results.string(forColumn: column.columnName)
//                    break
//                    
//                case .INTEGER:
//                    packet[column.columnName] = Int(results.int(forColumn: column.columnName))
//                    break
//                    
//                case .BOOL_AS_INTEGER:
//                    packet[column.columnName] = results.int(forColumn: column.columnName) != 0
//                    break
//                    
//                case .DECIMAL, .REAL:
//                    packet[column.columnName] = results.double(forColumn: column.columnName)
//                    break
//                    
//                case .DATE:
//                    packet[column.columnName] = results.date(forColumn: column.columnName)
//                }
//            }
//            
//            
//            json.append(packet)
//        }
//        results.dic
        var json:[JSON] = []
        while results.next(){
            json.append(results.resultDictionary() as! JSON)
        }
        results.close()
        
        json = addArrayValuesToJsonArray(jsonArray: json)
        
        json = addToJsonForAllObjects(json: json)
        
        return json
    }
    
    public static func addValuesFromOtherTablesToJsonFromDB(json:JSON, id:Int) -> JSON{
       
        return json
    }
    
    
    
    
    
    /**
         This default implementation of the save, the function takes the insert string and
         uses the Column Map to populate the values
         - note: this implentation does not check to see if the insert is unique
    */
    public func insert(){
        DataLayer.instance.myQueue.inDatabase { db in
            db!.executeUpdate(Self.insertString(), withParameterDictionary: self.columnMap)
        }
    }

    /**
         This saves the object to the database This performs Insert or Update on conflict with
         the Primary key
    */
    public func save() {
        if self.columnMap[Self.primaryKeyName] != nil {
            DataLayer.instance.myQueue.inTransaction{ db,rollback in
                db!.executeUpdate (Self.insertOnConflictIgnore(), withParameterDictionary: self.columnMap)
                db!.executeUpdate(Self.updateString(), withParameterDictionary:self.columnMap)
            }
            self.saveArrayValues()
        }else{
            noPrimaryKey()
        }
    }
    
    /**
         This updates the object to the database based on Primary key, if no record is held
         in the database with the same Primary Key then nothing will be updated
         
         - note: If you don not have the first member in you columnMap as your primary key
         this function do nothing
    */
    public func update() {
        if self.columnMap[Self.primaryKeyName] != nil {
            DataLayer.instance.myQueue.inTransaction{ db,rollback in
               db!.executeUpdate(Self.updateString(), withParameterDictionary:self.columnMap)
            }
            self.saveArrayValues()
        } else {
            noPrimaryKey()
        }
    }
    
    
    
    /**
         This updates a the colmuns supplied 
         - parameter columns: This is an array of Objects
    */
    public func updateColumn(column:Column) {
        guard let value = self.columnMap[column.columnName] else { noPrimaryKey(); return}
        self.updateColumnWithValue(column: column, value: value)
    }
    
    
    /**
         This updates a the colmuns supplied
         - parameter columns: This is an array of Objects
    */
    public func updateColumnWithValue(column:Column,value:Any) {
        guard let value = self.columnMap[column.columnName] else {noPrimaryKey(); return}
        DataLayer.instance.myQueue.inTransaction{ db,rollback in
            let dict:JSON = [column.columnName:value, Self.primaryKeyName.lowercased() : value]
            db!.executeUpdate(Self.updateColumns([column]), withParameterDictionary:dict)
        }
    }
    
    
    /**
         This deletes all the rows in the database table
    */
    public func delete(){
        guard let value = self.columnMap[Self.primaryKeyName] else { noPrimaryKey(); return}
        DataLayer.instance.myQueue.inDatabase { db in
            db?.executeUpdate(Self.deleteByIdString(), withParameterDictionary: [Self.primaryKeyName.lowercased() : value])
        }
    }
 
    
    /**
         This function builds the create table string function and then accesses the DB and 
         builds the table if it is not already there.
         
         - note: If you modify the table you must call drop table in order to create a new
         table, Failling to do this will result in errors
         
         - note: If you don not have the first member in you columnMap as your primary key
     */
    public static func createTable(){
        DataLayer.instance.myQueue.inDatabase { db in
            if !(db?.tableExists(Self.objectName))! {
                db!.executeUpdate(Self.createTableString(), withArgumentsIn:[])
            }
        }
        createTableForArrays()
        createReferanceTables()
    }
    
    
    public static func createReferanceTables(){
    
    }
    
    /**
         This static function is how you get an object from the database via its primary Key
         If the database hold no record under this primary key or the initializeation fails
         then nil is returned
          - returns: An object of the conforming Type if found
    */
    public static func get(id:Int) -> Self? {
        var obj: Self? = nil
        DataLayer.instance.myQueue.inDatabase { db in
            if let result = db!.executeQuery(Self.selectByIdString(), withParameterDictionary:[Self.primaryKeyName.lowercased() : id ]) {
                let json = Self.resultSetToJSON(results: result)
                if json.count > 0 {
                    obj = Self.init(json:json[0])
                }
                
            }
        }
        return obj
    }
    
    /**
         This static function is how you get a JSON representation of an object from the 
         database via its primary Key If the database hold no record under this primary key 
         or the initializeation fails then nil is returned
         
         - returns: An JSON Object with the object name as the key and the values as values
     */
    public static func getJsonForObject(id:Int) -> [JSON] {
        var objs: [JSON] = []
        DataLayer.instance.myQueue.inDatabase { db in
            if let result = db?.executeQuery(Self.selectByIdString(), withParameterDictionary:[Self.primaryKeyName.lowercased() : id ]){
                objs = Self.resultSetToJSON(results: result)
                objs = Self.addArrayValuesToJsonArray(jsonArray: objs)
                objs = Self.addToJsonForAllObjects(json: objs)
            }
        }
        return objs
    }

   
    /**
         This static function is how you get all objects from the database Any records whos init
         fails will be removed from the array
     
          - returns: Any array of objects of the conforming Type
    */
    public static func getAll() -> [Self]{
        var obj: [Self?] = []
        DataLayer.instance.myQueue.inDatabase { db in
            let result = db?.executeQuery(Self.selectAllString(), withArgumentsIn:[])
            let json = Self.resultSetToJSON(results: result!)
            let _ = json.map({obj.append(Self.init(json:$0))})
        }
        return obj.flatMap{$0}
    }
    
    /**
         This static function is how you get all objects which conform to the supplied where clause
         from the database. Any records whos init fails will be removed from the array
         - note: the string is construced for you and clause will be inserted here 
         
            WHERE \(clause);
         
         - note: As you can see the terminating semi-colon is placed there for you
         - note: While you are free to construct where clause Strings as you wish it is suggested that
         instead of using column name and values as part of thw where clause you consider passing your
         arguments in the arguments array and use place holders
         hence 
         
               let clause = "arriveTime > \(self.arriveTime)"
        
         is better constructed as
         
             let clause = "arriveTime > ?" with args:[self.arriveTime]
         
         - parameter whereClause: This string is appended to the database
         - returns: Any array of objects of the conforming Type
    */
    public static func getAllWhere(whereClause:String,args:[Any]) -> [Self]{
        var obj: [Self?] = []
        DataLayer.instance.myQueue.inDatabase { db in
            if let result = db?.executeQuery(Self.selectAllWhereString(whereClause), withArgumentsIn:args){
                let json = Self.resultSetToJSON(results: result)
                let _ = json.map({obj.append(Self.init(json:$0))})
            }
        }
        return obj.flatMap{$0}
    }
    
    
    /**
         This static function is how you get all objects which conform to the supplied where clause
         from the database. Any records whos init fails will be removed from the array
         - parameter column: The column for whose Equality you are testing
         - parameter equalsValue: The value that it must Equal
         - returns: Any array of objects of the conforming Type
    */
    public static func getAllWhereColumn(column:Column, equalsValue:Any) -> [Self]{
        var obj: [Self?] = []
        DataLayer.instance.myQueue.inDatabase { db in
            if let result = db?.executeQuery(Self.selectAllWhereColumnEquals(column), withParameterDictionary:[column.columnName : equalsValue]) {
                let json = Self.resultSetToJSON(results: result)
                let _ = json.map({obj.append(Self.init(json:$0))})
            }
        }
        return obj.flatMap{$0}
    }
    
    /**
         This static function is how you get all objects which conform to the supplied where clause
         from the database. Any records whos init fails will be removed from the array
         - parameter column: The column for whose value must be lessThan than the parameter suppplied
         - parameter equalsValue: The value that it must Equal
         - returns: Any array of objects of the conforming Type
    */
    public static func getAllWhereColumn(column:Column, greaterThanValue:Any) -> [Self]{
        var obj: [Self?] = []
        DataLayer.instance.myQueue.inDatabase { db in
            if let result = db?.executeQuery(Self.selectAllWhereColumnGreaterThan(column), withParameterDictionary:[column.columnName : greaterThanValue]) {
                let json = Self.resultSetToJSON(results: result)
                let _ = json.map({obj.append(Self.init(json:$0))})
            }
        }
        return obj.flatMap{$0}
    }
    
    
    
    
    
    /**
         This static function is how you get all objects which conform to the supplied where clause
         from the database. Any records whos init fails will be removed from the array
         - parameter column: The column for whose value must be greater than the parameter suppplied
         - parameter equalsValue: The value that it must Equal
         - returns: Any array of objects of the conforming Type
    */
    public static func getAllWhereColumn(column:Column, lessThanValue:Any) -> [Self]{
        var obj: [Self?] = []
        DataLayer.instance.myQueue.inDatabase { db in
            if let result = db?.executeQuery(Self.selectAllWhereColumnLessThan(column), withParameterDictionary:[column.columnName : lessThanValue]) {
                let json = Self.resultSetToJSON(results: result)
                let _ = json.map({obj.append(Self.init(json:$0))})
            }
        }
        return obj.flatMap{$0}
    }
    
    
    /**
         This Drops the table
    */
    public static func dropTable(){
        DataLayer.instance.myQueue.inDatabase{ db in
           _ = db?.executeUpdate(Self.dropTableString(), withArgumentsIn: [])
        }
    }
    
}
