//
//  File.swift
//  GuardApp
//
//  Created by Mark on 28/07/2016.
//  Copyright © 2016 Mark. All rights reserved.
//

import Foundation



extension DBable {
    
    public var arrayMap:[String:[Any]] {return [:]}
    public static var arrayType:[String: ColumnTypes] { return [:] }
    
    public static var objectNames:[String] { return Self.arrayType.keys.sorted(by: <) }
    
    final static private var arrayTableName: (_ i:Int) -> String {
        return { position in
           let str = "\(Self.primaryKeyName)_\(Self.objectNames[position])"
            return str.uppercased()
        }
    }
    
    /** This returns a String with "_ID" appended to the parent object name */
    final static internal var foreignKeyName: () -> String {
        return {
            return "\(Self.primaryKeyName)_ID"
        }
    }
    
    /** This returns a create table string for an element in the array of arrays*/
    final static var createArrayTableString: (_ i:Int) -> String {
        return { pos in
            let str = "\(DB.defaultId), \(Self.foreignKeyName().uppercased()) INTEGER, \(Self.objectNames[pos].uppercased()) \(Self.arrayType[Self.objectNames[pos]]!.rawValue.uppercased())"
            return "\(DB.createTable) \(Self.arrayTableName(pos)) (\(str));"
        }
    }

    /**
         This returns a insert string for an element in the array of arrays
         - note: this will us the dictionary syntax
     */
    final static var insertArrayString: (_ i:Int) -> String {
        return{ pos in
            return "\(DB.insert) \(Self.arrayTableName(pos).uppercased()) (\(Self.foreignKeyName().uppercased()), \(Self.objectNames[pos].uppercased())) VALUES (:\(Self.foreignKeyName().lowercased()), :\(Self.objectNames[pos].lowercased()));"
        }
    }
    
    /**
         This returns a delete string for an element in the array of arrays
         - note: to update the array to the database, all elements with a forien key will be wiped and the new values will be inserted, as there is no primary key for these elements we have to use a delete reinsert model
     */
    final static var deleteAllArrayString: (_ i:Int) -> String {
        return { pos in
            return "\(DB.delete) \(Self.arrayTableName(pos).uppercased()) WHERE \(Self.foreignKeyName().uppercased()) = :\(Self.foreignKeyName().lowercased());"
        }
    }
    
    final static var selectAllArrayString: (_ i:Int) -> String {
        return{ pos in
            return "\(DB.selectAll) \(Self.arrayTableName(pos).uppercased()) WHERE \(Self.foreignKeyName().uppercased()) = :\(Self.foreignKeyName().lowercased());"
        }
    }
    
    /**
     
     */
    final static var dropArrayTableString: (_ i:Int) -> String{
        return { pos in
            return "\(DB.dropTable) \(Self.arrayTableName(pos).uppercased());"
        }
    }

}

extension DBable {
    
    /**
        This creates all the tables needed to store the data in the arrays
     */
    static func createTableForArrays(){
       
        for i in 0 ..< self.objectNames.count {
            DataLayer.instance.myQueue.inDatabase{  db in
                db?.executeUpdate(self.createArrayTableString (i), withArgumentsIn: [])
            }
             print("arr called")
        }
    }
    
    /*
        This deletes All the values associcated with the foreign key then reinserts the values into the db. This approach has been taken as each value of the array has no pirmarykey of its on to use an update function
        - note with large numbers of objects with large numbers in their arrays you may need to call VACUUM on the db
    or set the db to AUTOVACUUM
     
     */
    func saveArrayValues(){
        print(Self.objectNames.count)
        for i in 0 ..< Self.objectNames.count {
            DataLayer.instance.myQueue.inDatabase{  db in
                db?.executeUpdate(Self.deleteAllArrayString(i), withParameterDictionary: ["\(Self.foreignKeyName().lowercased())":self.primaryKeyValue])
            }
            insertArrayValues(values: self.arrayMap[Self.objectNames[i]],i: i)
            print(" __ inserting array values  \(Self.objectNames[i]) --  \(self.arrayMap )  ")
        }
    }

    private func insertArrayValues(values:[Any]?,i:Int){
        guard let values = values  else { print("WARNING object name not in Dictionary"); return}
        print(values)
        DataLayer.instance.myQueue.inDatabase { db in
            for j in 0 ..< values.count{
                let params:[String:Any] = ["\(Self.foreignKeyName().lowercased())" : self.primaryKeyValue, "\(Self.objectNames[i].lowercased())" : values[j]]
                db?.executeUpdate(Self.insertArrayString(i), withParameterDictionary: params )
            }
        }
    }
    
    public static final func addArrayValuesToJsonArray(jsonArray:[JSON]) -> [JSON] {
        var parcel:[JSON] = []
        for row in jsonArray {
            if let id = row[Self.primaryKeyName] as? Int {
                parcel.append(Self.addArrayValuesToJson(json: row,primaryKeyValue:id))
            }else{
                parcel.append(row)
                print("error no id")
            }
        }
        return parcel
    }
    
    public static final func addArrayValuesToJson(json:JSON, primaryKeyValue:Int) -> JSON {
        var parcel:JSON = json
        for i in 0 ..< Self.objectNames.count {
            if let type = Self.arrayType[Self.objectNames[i]] {
                switch type {
                    case .INTEGER :         parcel[Self.objectNames[i]] = Self.getIntArray(i: i,primaryKeyValue:primaryKeyValue)
                    case .BOOL_AS_INTEGER:  parcel[Self.objectNames[i]] = Self.getBoolArray(i: i,primaryKeyValue:primaryKeyValue)
                    case .DATE:             parcel[Self.objectNames[i]] = Self.getDateArray(i: i,primaryKeyValue:primaryKeyValue)
                    case .TEXT:             parcel[Self.objectNames[i]] = Self.getStringArray(i: i,primaryKeyValue:primaryKeyValue)
                    case .REAL:             parcel[Self.objectNames[i]] = Self.getDoubleArray(i: i,primaryKeyValue:primaryKeyValue)
                    case .DECIMAL:          parcel[Self.objectNames[i]] = Self.getDoubleArray(i: i,primaryKeyValue:primaryKeyValue)
                }
            }
        }
        return parcel
    }
    
    /**
     This will return an array of T objects from the stored database 
     - returns: Array of object from the database of type T, if none or found or the convertions to type fails then is returned []
     */
    internal static func getArrayFromDb<T>(i:Int,primaryKeyValue:Int) -> [T] {
         return Self.getAnyArrayFromDb(index: i,primaryKeyValue: primaryKeyValue).flatMap({$0 as? T})
    }
    
    
    /** - returns: an Int array from the db */
    internal static func getIntArray(i:Int,primaryKeyValue:Int) -> [Int] {
        return Self.getAnyArrayFromDb(index: i,primaryKeyValue: primaryKeyValue).flatMap({$0 as? Int})
    }
    
    /** - returns: a Bool array from the db */
    internal static func getBoolArray(i:Int,primaryKeyValue:Int) -> [Bool] {
        return Self.getAnyArrayFromDb(index: i,primaryKeyValue: primaryKeyValue).flatMap({$0 as? Bool})
    }
    
    /** - returns: a String array from the db */
    internal static func getStringArray(i:Int,primaryKeyValue:Int) -> [String] {
        return Self.getAnyArrayFromDb(index: i,primaryKeyValue: primaryKeyValue).flatMap({$0 as? String})
    }
    
    /** - returns: a NSDate array from the db */
    internal static func getDateArray(i:Int,primaryKeyValue:Int) -> [NSDate] {
        return Self.getAnyArrayFromDb(index: i,primaryKeyValue: primaryKeyValue).flatMap({$0 as? NSDate})
    }
    
    /** - returns: a Double array from the db */
    internal static func getDoubleArray(i:Int,primaryKeyValue:Int) -> [Double] {
        return Self.getAnyArrayFromDb(index: i,primaryKeyValue: primaryKeyValue).flatMap({$0 as? Double})
    }
    
    private static func getAnyArrayFromDb(index:Int, primaryKeyValue:Int) -> [Any] {
        var arr:[Any] = []
        DataLayer.instance.myQueue.inDatabase{ db  in
            let params = ["\(Self.foreignKeyName().lowercased())" : primaryKeyValue]
            print("here -> \(Self.selectAllArrayString(index))  -> \(params))")
            if let results = db?.executeQuery(Self.selectAllArrayString(index), withParameterDictionary: params ) {
                while results.next(){
                    let name = Self.objectNames[index].uppercased()
                    if let type = Self.arrayType[Self.objectNames[index]] {
                        switch type {
                            case .INTEGER :         arr.append(Int(results.int(forColumn: name)))
                            case .BOOL_AS_INTEGER:  arr.append(Bool(results.bool(forColumn: name)))
                            case .DATE:             arr.append(results.data(forColumn: name))
                            case .TEXT:             arr.append(String(results.string(forColumn: name)) ?? "")
                            case .REAL:             arr.append(Double(results.double(forColumn: name)))
                            case .DECIMAL:          arr.append(Double(results.double(forColumn: name)))
                        }
                    }
                }
                results.close()
            }
        }
        return arr
    }
    
    
    static func dropTable(i:Int){
        DataLayer.instance.myQueue.inDatabase(){db in
            db?.executeUpdate(Self.dropArrayTableString(i), withArgumentsIn: [])
        }
    }
}















