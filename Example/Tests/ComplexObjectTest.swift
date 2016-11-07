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
        User.dropTable()
        Photo.dropTable()
        ComplexOb
    
    let json:JSON = ["id": 1, "name": "test_name", "user": ["id" : 20, "firstname": "testFirst","lastname":"testLast","email":"me@testing.com", "validuntil": Date(), "password":"pword"], "photos": [["id": 3, "cameraid" : 9]] ]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
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
    
    
}
