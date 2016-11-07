//
//  UserStringsTests.swift
//  GuardApp
//
//  Created by Mark on 07/07/2016.
//  Copyright © 2016 Mark. All rights reserved.
//

import XCTest
@testable import GuardApp 

class UserStringsTests: XCTestCase {
    let userTable       = "CREATE TABLE IF NOT EXISTS USERS (ID INTEGER PRIMARY KEY, FIRSTNAME TEXT, LASTNAME TEXT, EMAIL TEXT, VALIDUNTIL DATE);"
    let userInsert      = "INSERT INTO USERS (ID,FIRSTNAME,LASTNAME,EMAIL,VALIDUNTIL)VALUES(:id,:firstname,:lastname,:email,:validuntil);"
    let userInsertOn    = "INSERT OR IGNORE INTO USERS (ID,FIRSTNAME,LASTNAME,EMAIL,VALIDUNTIL)VALUES(:id,:firstname,:lastname,:email,:validuntil);"
    let userUpdate      = "UPDATE USERS SET FIRSTNAME = :firstname,LASTNAME = :lastname,EMAIL = :email,VALIDUNTIL = :validuntil WHERE ID = :id;"
    let userUpdateByCol = "UPDATE USERS SET FIRSTNAME = :firstname,LASTNAME = :lastname,EMAIL = :email,VALIDUNTIL = :validuntil WHERE TEST = :id;"
    let userUpdateWhere = "UPDATE USERS SET FIRSTNAME = :firstname,LASTNAME = :lastname,EMAIL = :email,VALIDUNTIL = :validuntil WHERE TEST = 10;"
    let userSelectAll   = "SELECT * FROM USERS;"
    let userSelectPri   = "SELECT * FROM USERS WHERE ID = :id;"
    let userSelectGrt   = "SELECT * FROM USERS WHERE ID > :id;"
    let userSelectLtn   = "SELECT * FROM USERS WHERE ID < :id;"
    let userSelectWhe   = "SELECT * FROM USERS WHERE TEST = 10;"
    let userDelete      = "DELETE FROM USERS;"
    let userDeletePri   = "DELETE FROM USERS WHERE ID = :id;"
    let userDeleteWhe   = "DELETE FROM USERS WHERE TEST = 10;"
    let userDropTable   = "DROP TABLE USERS;"
    
    
    
    func testCreateTableString() {
        let tableString = User.createTableString()
        XCTAssert(tableString == self.userTable, "string is actually [\(tableString)]")
    }
    
    func testInsertString() {
        let insertString = User.insertString()
        XCTAssert(insertString ==  self.userInsert,"string is actually [\(insertString)]")
    }
    
    func testInsertOrIgnoreString() {
        let insertStringOrIG = User.insertOnConflictIgnore()
        XCTAssert(insertStringOrIG ==  self.userInsertOn,"string is actually [\(insertStringOrIG)]")
    }
    
    func testUpdateString(){
        let updateString = User.updateString()
        XCTAssert(updateString == self.userUpdate,"string is actually [\(updateString)]")
    }
    
    
    func testUpdateWithWhere(){
        let updateByCol = User.updateByWhereString("TEST = 10")
        XCTAssert(updateByCol == self.userUpdateWhere,"string is actually [\(updateByCol)]")
    }
    
    func testSelectAll(){
        let selectAll = User.selectAllString()
        XCTAssert(selectAll == self.userSelectAll,"string is actually [\(selectAll)]")
    }
    
    func testSelectAllWhere(){
        let selectAll = User.selectAllWhereString("TEST = 10")
        XCTAssert(selectAll == self.userSelectWhe,"string is actually [\(selectAll)]")
    }
    
    func testSelectAllPrimary(){
        let selectAll = User.selectAllWhereColumnEquals(User.columns[0])
        XCTAssert(selectAll == self.userSelectPri,"string is actually [\(selectAll)]")
    }
    
    func testSelectAllGreaterThan(){
        let selectAll = User.selectAllWhereColumnGreaterThan(User.columns[0])
        XCTAssert(selectAll == self.userSelectGrt,"string is actually [\(selectAll)]")
    }
    
    func testSelectLessThan(){
        let selectAll = User.selectAllWhereColumnLessThan(User.columns[0])
        XCTAssert(selectAll == self.userSelectLtn,"string is actually [\(selectAll)]")
    }
    
    func testDeleteAll(){
        let delete = User.deleteAllString()
        XCTAssert(delete == self.userDelete,"string is actually [\(delete)]")
    }
    
    func testDeletePri(){
        let delete = User.deleteByIdString()
        XCTAssert(delete == self.userDeletePri,"string is actually [\(delete)]")
    }
    
    func testDeleteWhere(){
        let delete = User.deleteAllWhereString("TEST = 10")
        XCTAssert(delete == self.userDeleteWhe,"string is actually [\(delete)]")
    }
    
    func testDropTable(){
        let del = User.dropTableString()
        XCTAssert(del == self.userDropTable,"string is actually [\(del)]")
    }
}
