//
//  ComplexObjectTests.swift
//  GuardApp
//
//  Created by Mark on 12/09/2016.
//  Copyright © 2016 Mark. All rights reserved.
//

import XCTest
@testable import GuardApp

class ComplexObjectTests: XCTestCase {
    let originalJson:[JSON] = [["id":73,
        "user":["id" : 22, "firstname" : "markTest", "lastname" : "gilchristTest", "email" : "private@me.com", "validuntil" : "10-101-2002"],
        "photos": [
            ["id":100, "cameraid":10, "taken":"10-101-2002", "extension":"png", "uploaded" : "" ,"name":"test", "type" : "null"],
            ["id":102, "cameraid":10, "taken":"10-101-2002", "extension":"png", "uploaded" : "" ,"name":"test", "type" : "null"],
            ["id":103, "cameraid":10, "taken":"10-101-2002", "extension":"png", "uploaded" : "" ,"name":"test", "type" : "null"]],
        "numbers": [1,2,3,4,5,6,7,8,9,10]
        ]]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testInitFromSampleJSON(){
        if let completObj = ComplexObject(json:originalJson[0]) {
            XCTAssert(completObj.id            == 73)
            XCTAssert(completObj.photos.count  == 3)
            XCTAssert(completObj.user?.userID  == 22)
            XCTAssert(completObj.numbers.count == 10)
             print(completObj)
        }
    }
    
    func testSaveAndInitFromDB(){
        if let completObj = ComplexObject(json:originalJson[0]) {
//            ComplexObject.createTable()
//            completObj.save()
        }
    
    }
    
}
