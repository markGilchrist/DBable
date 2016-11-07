//
//  ArrayStoreAbleTest.swift
//  GuardApp
//
//  Created by Mark on 05/08/2016.
//  Copyright © 2016 Mark. All rights reserved.
//

import XCTest
@testable import DBable

class ArrayStoreAbleTest: XCTestCase {
    
    let obj = ComplexObj(id: 100, prices: [10,20,30,40,50,60])
    let create = "CREATE TABLE IF NOT EXISTS COMPLEXTOBJECT_PRICES (ID INTEGER PRIMARY KEY, COMPLEXTOBJECT_ID INTEGER, PRICES INTEGER);"
    let insert = "INSERT INTO COMPLEXTOBJECT_PRICES (COMPLEXTOBJECT_ID, PRICES) VALUES (:complextobject_id, :prices);"
    let delete = "DELETE FROM COMPLEXTOBJECT_PRICES WHERE COMPLEXTOBJECT_ID = :complextobject_id;"
    let select = "SELECT * FROM COMPLEXTOBJECT_PRICES WHERE COMPLEXTOBJECT_ID = :complextobject_id;"
    let drop = "DROP TABLE COMPLEXTOBJECT_PRICES;"
    
//    override func setUp() {
//        super.setUp()
//        ComplexObj.createTableForArrays()
//    }
//    
//    override func tearDown() {
//        super.tearDown()
//    }
//
//
//    func testCreateString() {
//        XCTAssert(ComplexObj.createArrayTableString(i: 0) == create,"string was actually \(ComplexObj.createArrayTableString(i: 0))")
//    }
//    
//    func testInsertString() {
//        XCTAssert(ComplexObj.insertArrayString(i:0) == insert, "string was actually [\(ComplexObj.insertArrayString(i:0))]")
//    }
//    
//    func testDeleteAllString() {
//        XCTAssert(ComplexObj.deleteAllArrayString(i:0) == delete, "string was actually [\(ComplexObj.deleteAllArrayString(i:0))]")
//    }
//    func testSelectAllString(){
//        XCTAssert(ComplexObj.selectAllArrayString(i:0) == select,"string was actually [\(ComplexObj.selectAllArrayString(i:0))]")
//    }
//    
//    func testDropTableString(){
//        XCTAssert(ComplexObj.dropArrayTableString(i:0) == drop,"string was actually [\(ComplexObj.dropArrayTableString(i:0))]")
//    }
//
//    func testCreateTables(){
//        ComplexObj.createTableForArrays()
//        DataLayer.instance.myQueue.inDatabase(){ db in
//            XCTAssert(db.tableExists("COMPLEXTOBJECT_PRICES"))
//        }
//    }
//    
//    func testInsert(){
//        
//        obj.saveArrayValues()
//    }
//    
//    func testGetObj(){
////         let objects:[Int] = ComplexObj.getArrayFromDb(0,forriegnKey: 100)
////         if objects.count > 0 {
////            print(objects)
////        } else {
////            XCTFail()
////        }
//    }
//    
//
//}
}
