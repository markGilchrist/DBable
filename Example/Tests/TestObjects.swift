//
//  TestObjects.swift
//  DBable
//
//  Created by Mark on 22/11/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import DBable


/**
 This is a test One to many Object
 */
struct ArrayObject {
    let id:Int
    let prices:[Int]
    
}

extension ArrayObject : DBable {
    /** This is What maps the values to the columns  */
    public var columnMap: [String : Any] {return [:]}
    static var forriegnKeyName: String? = nil
    static var objectName: String = "arrayobject"
    static var columns: [Column] = []
    static var preferedPrimaryKeyName: String? = "id"
    
    var arrayMap:[String : [Any]] {
        return ["prices" : self.prices]
    }
    
    static var primaryKeyName :String {
        return "complextObject"
    }
    
    static var objectType:[String:ColumnTypes] {
        return ["prices": .INTEGER]
    }
    
    init?(json: JSON) {
        guard let id    = json["id"] as? Int else { return nil }
        self.id         = id
        self.prices     = json["prices"] as? [Int] ?? []
    }
    
    
    
}


public struct  ComplexObject : DBable {
    let id:Int
    let name : String
    let user: User?
    let photos: [Photo]
    let numbers: [Int]
    
    
    public init?(json: JSON) {
        guard let id:Int = json["id"] as? Int else{ return nil }
        self.id          = id
        self.name        = json["name"] as? String ?? "fail"
        self.numbers     = json["numbers"] as? [Int] ?? []
        let userJson : JSON? = json["user"] as? JSON
        self.user        = User(json: userJson ?? [:])
        self.photos      = Photo.getArray(input: json["photos"])
    }
    
    public static var preferedPrimaryKeyName: String? { return "id" }
    public static var forriegnKeyName: String? = nil
    public static var columns: [Column] = [Column(name: "id", type: .INTEGER), Column(name: "name",type: .TEXT)]
    public static var arrayType:[String: ColumnTypes] = ["numbers" : .INTEGER]
    
    public var columnMap: [String : Any] {return ["id" : self.id,"name":self.name]}
    public var arrayMap: [String : [Any]] {return ["numbers" : self.numbers]}
    
    public static func createReferanceTables(){
        // create numbers table
        
    }
    
}



enum FileType:String {
    case png
    case jpeg
    
    init(str:String?){
        guard let str = str else{ self = .png; return}
        switch str {
        case "png":
            self = .png
        case  "jpeg":
            self = .jpeg
        default: self = .jpeg
        }
    }
    
    
    func str() -> String{
        switch self {
        case .png: return "png"
        case .jpeg: return "jpeg"
        }
    }
    
    
}

/**
 
 This object models All the data for a photo Object
 */
public struct Photo {
    /// This is the Id of the photo that is assigend to it by the server, this is unique
    let photoID:Int
    
    /// This is the Id of the camera that took the photo, this should be non nil
    let cameraId:Int?
    
    /// This is the date time that the photo was taken, you must use the
    let dateTaken:Date?
    
    /// This is the datetime that it was uploaded
    let uploaded:Date?
    
    /// This is the file extension of the photo
    let fileType:FileType
    
    /// This is the name of the photo
    let name:String?
    
    /// This is a flag to prevent mulitple download requests, may soon be depricated
    var isDownloading = false
    
    public init?(json: JSON) {
        do{
            self.photoID            = try Photo.getValue(json: json, key: K.pKey)
            self.cameraId           = try Photo.getValue(json: json, key: K.ppKey)
        }catch let error{
            print(error)
            return nil
        }
        self.dateTaken          = getDate(obj: json[K.taken])
        self.uploaded           = getDate(obj: json[K.uploaded])
        self.fileType           = FileType(str: json[K.ext] as? String)
        self.name               = json[K.name] as? String
    }
    
    /**
     - computed property, creates directory if it doesn't exist
     */
    var imageDir:String  {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let dirPath = "\(path)/photos/"
        checkDirExists(dirPath: dirPath)
        return dirPath
    }
    
    
    /**
     - parameter dirPath: This is the directory path at which you believe there is a file
     - returns: true if there is a file at this path
     */
    private func checkDirExists(dirPath:String){
        var isDir: ObjCBool = true
        if !FileManager.default.fileExists(atPath: dirPath, isDirectory: &isDir) {
            do {
                try FileManager.default.createDirectory(atPath: dirPath, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        }
    }
    
    /**
     to be used to see if there is an image file for a filepath
     - parameter light: true if you are refering to the lightimage or thumbnail
     - returns: true if the is an image at that file path if not false
     */
    internal func hasImageSaved(light:Bool) -> Bool {
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: light ? self.lightImageFilePath : self.imageFilePath, isDirectory: &isDir) { return true }
        return false
    }
    
    /**
     The computed filepath
     - returns: the file path for and image
     */
    var imageFilePath:String {
        return "\(self.imageDir)\(photoID).\(self.fileType.str())"
    }
    
    
    /**
     The computed filepath
     - returns: the file path for and image
     */
    var lightImageFilePath:String {
        return "\(self.imageDir)light_\(photoID).\(self.fileType.str())"
    }
    
    /**
     
     This saves the UIImage to the file system
     - parameter image: The Image you want to save
     - parameter light: true if you are refering to the thumbnail image
     */
    internal func saveImageFile(image:UIImage, light:Bool){
        print("after save")
        var data:Data? = nil
        if self.fileType == .png {
            data = UIImagePNGRepresentation(image)
        }else{
            data = UIImageJPEGRepresentation(image, 100)
        }
        if let data = data {
            do{
                try data.write(to:URL(string: light ? self.lightImageFilePath : self.imageFilePath)!)
            }catch let error{
                print(error)
            }
        }
    }
    
    /**
     - returns: The UIImage of the file stored at the path or nil
     */
    func getimage() ->UIImage? {
        return  UIImage(contentsOfFile:self.imageFilePath)
    }
    
    /**
     - returns: The UIImage of the file stored at the path or nil
     */
    func getLightImage() -> CIImage? {
        return  CIImage.init(contentsOf:URL(fileURLWithPath: self.lightImageFilePath))
    }
    
}


private struct K {
    static let pKey     = "id"
    static let ppKey    = "cameraid"
    static let taken    = "taken"
    static let ext      = "extension"
    static let uploaded = "uploaded"
    static let name     = "name"
    static let type     = "type"
}

extension Photo: DBable{
    
    public static var forriegnKeyName: String? = "complex_object"
    
    //  static var parentPrimaryKeyColumns:[Column] {return [Column(columnName:K.ppKey,columnType: .INTEGER)]}
    public static var preferedPrimaryKeyName: String?  { return K.pKey }
    public static var objectName: String       { return "photo"}
    public static var columns: [Column]        {
        return [
            Column(name:K.pKey,type: .INTEGER),
            Column(name:K.ppKey,type:.INTEGER),
            Column(name:K.taken,type:  .DATE),
            Column(name:K.uploaded,type: .DATE),
            Column(name:K.ext,type: .TEXT),
            Column(name:K.name,type: .TEXT),
            Column(name:K.type,type: .TEXT)
        ]
    }
    static var defaults:[String:String] {return [:]}
    public var columnMap: [String : Any] {
        return [
            K.pKey      : self.photoID,
            K.ppKey     : self.cameraId ?? "null",
            K.taken     : self.dateTaken ?? "null",
            K.uploaded  : self.uploaded ?? "null",
            K.ext       : self.fileType.rawValue,
            K.name      : self.name ?? "null",
            K.type      : self.fileType.rawValue
        ]
    }
    
    var jsonMap:JSON {
        var map = self.jsonMap
        map[ K.type] = self.fileType.str()
        return map
    }
    
    
}


/** Models the user*/
public struct User :JSONDecodable{
    
    /// This is set by the sever and is unique, if the id is not set yet then it is = 0
    public let userID: Int
    
    /// This is the User's firstname
    public let fName: String
    
    /// This is the User's lastname
    public let lName: String
    
    /// This is the email of the User
    public let email: String
    
    /// This is the hash of the password of the user
    internal let password:String?
    
    /// This is the date at which the user session be comes invalidated
    public let vaildUntill:Date?
    
    public init?(json: JSON) {
        guard let userId        = json[K.Id]    as? Int    else { print("couldn't pass -> id ");return nil}
        guard let lastName      = json[K.lname] as? String else { print("couldn't pass -> last_name"); return nil}
        guard let firstname     = json[K.fname] as? String else { print("couldn't pass -> first_name"); return nil}
        guard let email         = json[K.email] as? String else { print("couldn't pass -> email"); return nil}
        let vaildUntill         = json[K.vaildUntil] as? Date?
        // print("date is -> \(json)")
        
        self.userID         = userId
        self.fName          = firstname
        self.lName          = lastName
        self.email          = email
        self.password       = json[K.password] as? String ?? nil
        self.vaildUntill    = vaildUntill ?? nil
    }
    
    public init(fName:String,lName:String,email:String,password:String){
        self.userID     = 0
        self.fName      = fName
        self.lName      = lName
        self.email      = email
        self.password   = password
        self.vaildUntill = nil
    }
    
    internal struct K {
        static let Id           = "id"
        static let fname        = "firstname"
        static let lname        = "lastname"
        static let email        = "email"
        static let vaildUntil   = "validuntil"
        static let password     = "password"
    }
    
}




extension User: DBable {
    
    public static var objectName: String  = "USERS"
    public static var preferedPrimaryKeyName: String? = K.Id
    public static var forriegnKeyName:String?  = ComplexObject.primaryKeyName
    public static var columns: [Column] =
        [
            Column(name: User.primaryKeyName, type: .INTEGER),
            Column(name: K.fname, type: .TEXT),
            Column(name: K.lname, type: .TEXT),
            Column(name: K.email, type: .TEXT),
            Column(name: K.vaildUntil, type: .DATE)
    ]
    
    public static var defaults: [String : String] { return [:]}
    public var columnMap:[String:Any] {
        return [
            K.Id         : self.userID ,
            K.fname      : self.fName,
            K.lname      : self.lName,
            K.email      : self.email,
            K.vaildUntil : self.vaildUntill
        ]
    }
    
    
    
    
    public var columnMapWithPword:[String:Any]{
        var cols = self.columnMap
        cols[K.password] = self.password
        return cols
    }
    
    public static func getAllValid() -> [User]{
        return User.getAllWhereColumn(column: columns[4], greaterThanValue: NSDate())
    }
    
    public func updateValidUntil(date:Date){
        self.updateColumnWithValue(column: User.columns[4] ,value:date)
    }
}

