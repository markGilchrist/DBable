//
//  DBableObjectStore.swift
//  DBable ORM
//
//  Created by Mark Gilchrist on 09/08/2016.
//  Copyright © 2016 Mark. All rights reserved.
//

import Foundation

    /**
        Conform to this protocol if you have a objec which has an array of child object which also conform to DBable
        This protocol is designed to ask for only the information it needs to do its job.
*/

extension DBable {
    
    
    public var objectMap: [String : [ Any]] { return [:] }
    
    public static var childPrimaryKeyNames:[String]  { return [] }
    
    /** This creates the name for the referance table */
    private static var objectTableName : (Int) -> String {
        return { index in
            return "\(Self.primaryKeyName.uppercased())_\(Self.childPrimaryKeyNames[index].uppercased())"
        }
    }
    
    /** This creates the referance tables for an objects in the model*/
    static var createReferanceTable: (Int) -> String {
        return { index in
            return "\(DB.createTable) \(Self.objectTableName(index)) (\(DB.defaultId), \(Self.primaryKeyName.uppercased()) INTEGER, \(Self.childPrimaryKeyNames[index].uppercased()));"
        }
    }
    
    /** This Create an insert statement for the  referance table */
    static var createInsertReferanceString: (Int) -> String {
        return { index in
            return "\(DB.insert) \(Self.objectTableName(index)) (\(Self.primaryKeyName.uppercased()),\(Self.childPrimaryKeyNames[index].uppercased())) VALUES (:\(Self.primaryKeyName.lowercased()),\(Self.childPrimaryKeyNames[index].lowercased()));"
        }
    }
    
    /** This creates the string to select all the primary keys of the child objects */
    static var createSelectReferanceString: (Int) -> String {
        return { index in
            return "\(DB.selectAll) \(Self.objectTableName(index)) WHERE \(Self.primaryKeyName.uppercased()) = :\(Self.primaryKeyName.lowercased());"
        }
    }
    
    /** This creates a delete string for the refence table for a particutlar child object  */
    static var createDeleteReferanceString: (Int) -> String {
        return { index in
            return "\(DB.delete) \(Self.objectTableName(index)) WHERE \(Self.primaryKeyName.uppercased()) = :\(Self.primaryKeyName.lowercased());"
        }
    }
}


//extension DBable {
//
//    private static final func createObjectTables(){
//        for i in 0 ..< Self.childPrimaryKeyNames.count {
//            createSingleTable(i: i)
//        }
//    }
//    
//    private final static func createSingleTable(i:Int){
//        DataLayer.instance.myQueue.inDatabase(){db in
//            db?.executeUpdate(Self.createReferanceTable(i), withArgumentsIn: [])
//        }
//    }
//    
//    final func saveChildObjects(){
//        for i in 0 ..< Self.childPrimaryKeyNames.count {
//            insertObjectValue(i: i)
//        }
//    }
//    
//    final private func insertObjectValue(i:Int){
//        DataLayer.instance.myQueue.inDatabase(){db in
//            // drop all referances or check if they are there
//            for i in 0 ..< Self.childPrimaryKeyNames.count {
//                let params = ["\(Self.primaryKeyName.lowercased())":"\(self.primaryKeyValue)"]
//                db?.executeUpdate(Self.createDeleteReferanceString(i), withParameterDictionary: params );
//                if let objectArray = self.objectMap[Self.childPrimaryKeyNames[i]] {
//                    for object in objectArray {
//                        
//                        var pars = params
//                        pars["\(Self.childPrimaryKeyNames[i].lowercased())"] = "\(object.columnMap[Self.primaryKeyName])"
//                        db?.executeUpdate(Self.createInsertReferanceString(i), withParameterDictionary:pars)
//                        object.save()
//                        
//                    }
//                }
//            }
//        }
//    }
//    
//}

extension DBable{
    
    final static private func getJsonObjectArray(i:Int, primaryKey:Int) -> [JSON] {
        var obj:[JSON] = []
        DataLayer.instance.myQueue.inDatabase(){db in
            let params = ["\(Self.primaryKeyName.lowercased())":primaryKey]
            if let results = db?.executeQuery(Self.createSelectReferanceString(i), withParameterDictionary: params){
                obj = Self.resultSetToJSON(results: results)
                results.close()
            }
        }
        return obj
    }
    
    public final static func addToJsonForAllObjects(json:[JSON]) -> [JSON] {
        var parcel:[JSON] = []
        for row in json {
            if let id = row[Self.primaryKeyName] as? Int {
                parcel.append(Self.addToJsonForObjects(primaryKey:id))
            }
        }
        return parcel
    }

    final public static func addToJsonForObjects(json:JSON = [:],primaryKey:Int) -> JSON {
        var packet = json
        for i in 0 ..< Self.childPrimaryKeyNames.count {
           packet["\(Self.childPrimaryKeyNames[i].lowercased())"] = getJsonObjectArray(i: i,primaryKey: primaryKey)
        }
        return packet
    }

}






