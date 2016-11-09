//
//  ComplexObjectTest.swift
//  DBable
//
//  Created by Mark on 07/11/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
import DBable


class ComplexObjectTest: XCTestCase {
    override func setUp() {
        super.setUp()
        User.createTable()
        Photo.createTable()
        ComplexObject.createTable()
    }
    
    override func tearDown() {
        super.tearDown()
//        User.dropTable()
//        Photo.dropTable()
//        ComplexObject.dropTable()
    }
    
    
    let json:JSON = ["id": 1, "name": "test_name", "user": ["id" : 20, "firstname": "testFirst","lastname":"testLast","email":"me@testing.com", "validuntil": Date(), "password":"pword"], "photos": [["id": 3, "cameraid" : 9]], "numbers" : [0,1,2,3,4,5,6,7,8,9] ]
    
    
    func testObjectName() {
        XCTAssert(ComplexObject.objectName == "complexobject", "name is actually \(ComplexObject.objectName)")
    }
    
    func testMakeObjectFromJson(){
        if let obj = ComplexObject(json: json){
            print(obj)
        }else{
            XCTFail()
        }
        
    }
    
    func testCompelxObj(){
        XCTAssert(ComplexObject.objectNames.count == 1, "\(ComplexObject.objectNames.count)" )        
    }
    
    func testSave(){
        if let obj = ComplexObject(json: json){
           obj.save()
        }
    }
    
    func testGetFromDB(){
        if let secondObj = ComplexObject.get(id: 1) {
            print("second obj -> \(secondObj)")
        }else{
            XCTFail()
        }
    }
    
}
