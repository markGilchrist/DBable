//
//  DBConstants.swift
//  GuardApp
//
//  Created by Mark on 02/07/2016.
//  Copyright © 2016 Mark. All rights reserved.
//

import Foundation

public struct DB {
    /** - value -> "CREATE TABLE IF NOT EXISTS " */
    public static let createTable           = "CREATE TABLE IF NOT EXISTS"
    /** - value -> "INSERT INTO " */
    public static let insert                = "INSERT INTO"
    /** - value -> "INSERT OR IGNORE INTO" */
    public static let insertOnConflict      = "INSERT OR IGNORE INTO"
    /** - value -> "UPDATE TABLE" */
    public static let update                = "UPDATE"
    /** - value -> "DELETE FROM" */
    public static let delete                = "DELETE FROM"
    /** - value -> "SELECT * FROM" */
    public static let selectAll             = "SELECT * FROM"
    /** - value -> "PRIMARY KEY"*/
    public static let primaryKey            = "PRIMARY KEY"
    /** - value -> "ID INTEGER PRIMARY KEY"*/
    public static let defaultId             = "ID INTEGER PRIMARY KEY"
    /** - value -> "DROP TABLE"*/
    public static let dropTable             = "DROP TABLE"
    /** - value -> "SELECT last_insert_rowid()" */
    public static let selectLastInsertID    = "SELECT last_insert_rowid()"
}