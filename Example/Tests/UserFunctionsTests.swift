//
//  UserFunctionsTests.swift
//  GuardApp
//
//  Created by Mark on 07/07/2016.
//  Copyright © 2016 Mark. All rights reserved.
//

import XCTest
@testable import DBable

class UserFunctionsTests: XCTestCase {
    let packet = [ "id" : 20, "firstname": "testFirst","lastname":"testLast","email":"me@testing.com", "validuntil": Date(), "password":"pword"] as [String : Any]
    let change = [ "id" : 20, "firstname": "test","lastname":"test","email":"me@etesting.com", "validuntil": Date(), "password":"pass"] as [String : Any]
    var user:User? = nil

    override func setUp() {
        super.setUp()
        user = User(json: packet)
    }
    
    func testUserNotNil() {
        XCTAssertNotNil(user)
        XCTAssert(user?.userID == 20)
        XCTAssert(user?.fName  == "testFirst")
        XCTAssert(user?.lName  == "testLast")
        XCTAssert(user?.email  == "me@testing.com")
        XCTAssert(user?.password == "pword")
    }

    func testCreateTable(){
        User.dropTable()
        User.createTable()
        DataLayer.instance.myQueue.inDatabase{db in
            let exists = db?.tableExists(User.objectName)
            XCTAssert(exists!,"table was not created")
        }
    }
    
    func testInsertUser(){
        user?.save()
        let test:User? = User.get(id: 20)
        XCTAssertNotNil(test)
        XCTAssert(test?.userID == 20)
        XCTAssert(test?.fName  == "testFirst")
        XCTAssert(test?.lName  == "testLast")
        XCTAssert(test?.email  == "me@testing.com")
        XCTAssert(test?.password == nil)
    }
    
    func testUpdate(){
        let newUser = User(json: change)
        newUser?.update()
        let test:User? = User.get(id: 20)
        XCTAssertNotNil(test)
        XCTAssert(test?.userID == 20)
        XCTAssert(test?.fName  == "test")
        XCTAssert(test?.lName  == "test")
        XCTAssert(test?.email  == "me@etesting.com")
        XCTAssert(test?.password == nil)
        user?.update()
    }
    
    func testDelete(){
        user?.delete()
        let test:User? = User.get(id: 20)
        XCTAssertNil(test)
        user?.insert()
    }
    
    func testGetAllWhere(){
        let users:[User] = User.getAllWhere(whereClause: "lastname = ?", args: ["testLast"])
        XCTAssert(users.count == 1)
    }
    
    func testGetALLPirmary(){
        let users:[User] = User.getAllWhereColumn(column: User.columns[1], equalsValue:"testFirst")
        XCTAssert(users.count == 1,"count is in fact \(users.count)")
    }

}
