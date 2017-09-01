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
        var json:[JSON] = []
        while results.next(){
            let row = results.resultDictionary as! JSON
            var newRow : [String:Any] = [:]
            _ = row.map({
                newRow[$0.key.lowercased()] = $0.value
            })
            json.append(newRow)
        }
        results.close()
        json = addArrayValuesToJsonArray(jsonArray: json)
        json = addToJsonForAllObjects(json: json)
        return json
    }
    
    public static func addValuesFromOtherTablesToJsonFromDB(json:[JSON]) -> [JSON]{
        
        return json
    }
    
    
    
    
    static func add(Column col:Column){
        DataLayer.instance.myQueue.inDatabase{db in
            db.executeUpdate("ALTER TABLE \(Self.objectName) ADD COLUMN \(col.columnName) \(col.columnType.rawValue)", withArgumentsIn: [])
        }
    }
    
    
    /**
     This default implementation of the save, the function takes the insert string and
     uses the Column Map to populate the values
     - note: this implentation does not check to see if the insert is unique
     */
    public func insert(){
        DataLayer.instance.myQueue.inDatabase { db in
            db.executeUpdate(Self.insertString(), withParameterDictionary: self.columnMap)
        }
    }
    
    /**
     This saves the object to the database This performs Insert or Update on conflict with
     the Primary key
     */
    public func save() {
        if self.columnMap[Self.primaryKeyName] != nil {
            DataLayer.instance.myQueue.inTransaction{ db,rollback in
                db.executeUpdate (Self.insertOnConflictIgnore(), withParameterDictionary: self.columnMap)
                db.executeUpdate(Self.updateString(), withParameterDictionary:self.columnMap)
            }
            self.saveArrayValues()
            onSaveCalled()
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
                db.executeUpdate(Self.updateString(), withParameterDictionary:self.columnMap)
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
            db.executeUpdate(Self.updateColumns([column]), withParameterDictionary:dict)
        }
    }
    
    
    /**
     This deletes all the rows in the database table
     */
    public func delete(){
        guard let value = self.columnMap[Self.primaryKeyName] else { noPrimaryKey(); return}
        DataLayer.instance.myQueue.inDatabase { db in
            db.executeUpdate(Self.deleteByIdString(), withParameterDictionary: [Self.primaryKeyName.lowercased() : value])
        }
    }
    
    
    /*
        This will remove all the record in the database, leaving an empty table
     */
    public static func deleteAllRecords(){
        DataLayer.instance.myQueue.inDatabase { db in
            db.executeUpdate(Self.deleteAllString(), withParameterDictionary: [:])
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
            if !(db.tableExists(Self.objectName)) {
                db.executeUpdate(Self.createTableString(), withArgumentsIn:[])
            }
        }
        if Self.missingColumns.count > 0   {
            Self.missingColumns.forEach {
                add(Column: $0)
            }
        }
        createTableForArrays()
        createReferanceTables()
    }
    
    
    public static func createReferanceTables(){
        
    }
    
    /**
     This is all the columns that are in the database
     */
    static var columnsInDb:[Column]{
        var parcel = [Column]()
        DataLayer.instance.myQueue.inDatabase{db in
            if let results = db.executeQuery("PRAGMA table_info(\(Self.objectName.uppercased()))", withArgumentsIn: []){
                while results.next(){
                    parcel.append(Column.init(name: results.string(forColumn: "name")!, type: ColumnTypes.init(name: results.string(forColumn: "type")!)))
                }
                results.close()
            }
        }
        return parcel
    }
    
    /**
     This is all the columns that are modeled but not in the database
     
     */
    static var missingColumns : [Column]{
        let db = columnsInDb
        return columns.filter({!db.contains($0)})
    }
    
    
    /**
     This static function is how you get a JSON representation of an object from the
     database via its primary Key If the database hold no record under this primary key
     or the initializeation fails then nil is returned
     
     - returns: An JSON Object with the object name as the key and the values as values
     */
    public static func getJson(For str:String , argsDict:[String : Any] = [:]) -> [JSON] {
        var json: [JSON] = []
        DataLayer.instance.myQueue.inDatabase { db in
            if let results = db.executeQuery(str, withParameterDictionary:argsDict){
                while results.next(){
                    let row = results.resultDictionary as! JSON
                    var newRow : [String:Any] = [:]
                    _ = row.map({
                        newRow[$0.key.lowercased()] = $0.value
                    })
                    json.append(newRow)
                }
                results.close()
            }
        }
        json = addArrayValuesToJsonArray(jsonArray: json)
        json = addToJsonForAllObjects(json: json)
        json = addValuesFromOtherTablesToJsonFromDB(json:json)
        return json
    }
    
    /**
     This static function is how you get an object from the database via its primary Key
     If the database hold no record under this primary key or the initializeation fails
     then nil is returned
     - returns: An object of the conforming Type if found
     */
    public static func get(id:Int) -> Self? {
        let json = getJson(For:Self.selectByIdString(), argsDict:[Self.primaryKeyName.lowercased() : id ])
        return json.flatMap({ Self.init(json: $0) }).first
    }
    
    public static func getJson(id:Int) -> JSON? {
        let json = getJson(For:Self.selectByIdString(), argsDict:[Self.primaryKeyName.lowercased() : id ])
        return json.first
    }
    
    public static func getJson(whereIn arr:[Int]) ->[JSON] {
        return getJson(For:Self.selectWhereIn(arr))
    }
    
    public static func getCountAll() -> Int{
        var parcel = 0
        DataLayer.instance.myQueue.inDatabase{db in
            if let results = db.executeQuery(Self.countAllString(), withArgumentsIn: []){
                if results.next() {
                    parcel = Int(results.int(forColumnIndex: 0))
                }
                results.close()
            }
            
        }
        return parcel
    }
    
    /**
     This static function is how you get all objects from the database Any records whos init
     fails will be removed from the array
     
     - returns: Any array of objects of the conforming Type
     */
    public static func getAll() -> [Self]{
        let json = getJson(For: Self.selectAllString())
        return json.flatMap{ Self.init(json: $0) }
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
    public static func getAllWhere(whereClause:String,argsDict:[String : Any]) -> [Self]{
        let json = getJson(For: Self.selectAllWhereString(whereClause),argsDict: argsDict)
        return json.flatMap{ Self.init(json: $0) }
    }
    
    
    /**
     This static function is how you get all objects which conform to the supplied where clause
     from the database. Any records whos init fails will be removed from the array
     - parameter column: The column for whose Equality you are testing
     - parameter equalsValue: The value that it must Equal
     - returns: Any array of objects of the conforming Type
     */
    public static func getAllWhereColumn(column:Column, equalsValue:Any) -> [Self]{
        let json = getJson(For: Self.selectAllWhereColumnEquals(column),argsDict: [column.columnName : equalsValue])
        return json.flatMap{ Self.init(json: $0) }
    }
    
    /**
     This static function is how you get all objects which conform to the supplied where clause
     from the database. Any records whos init fails will be removed from the array
     - parameter column: The column for whose value must be lessThan than the parameter suppplied
     - parameter equalsValue: The value that it must Equal
     - returns: Any array of objects of the conforming Type
     */
    public static func getAllWhereColumn(column:Column, greaterThanValue:Any) -> [Self]{
        let json = getJson(For: Self.selectAllWhereColumnGreaterThan(column),argsDict: [column.columnName : greaterThanValue])
        return json.flatMap{ Self.init(json: $0) }
    }
    
    
    /**
     This static function is how you get all objects which conform to the supplied where clause
     from the database. Any records whos init fails will be removed from the array
     - parameter column: The column for whose value must be greater than the parameter suppplied
     - parameter equalsValue: The value that it must Equal
     - returns: Any array of objects of the conforming Type
     */
    public static func getAllWhereColumn(column:Column, lessThanValue:Any) -> [Self]{
        let json = getJson(For: Self.selectAllWhereColumnLessThan(column), argsDict: [column.columnName : lessThanValue])
        return json.flatMap{ Self.init(json: $0) }
    }
    
    
    /**
     This Drops the table
     */
    public static func dropTable(){
        DataLayer.instance.myQueue.inDatabase{ db in
            _ = db.executeUpdate(Self.dropTableString(), withArgumentsIn: [])
        }
    }
    
}
