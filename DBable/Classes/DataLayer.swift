//
//  DataLayer.swift
//  GuardApp
//
//  Created by Mark on 01/07/2016.
//  Copyright © 2016 Mark. All rights reserved.
//

import Foundation
import FMDB


public class DataLayer {
    public static let instance = DataLayer()
    public let myQueue: FMDatabaseQueue
    
    
    private init(){
        let documentsFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let databasePath = documentsFolder.appendingFormat("/db.sqlite")
        self.myQueue = FMDatabaseQueue(path: databasePath)
        print(databasePath)
    }
}
