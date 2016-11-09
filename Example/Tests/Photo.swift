//
//  Photo.swift
//  GuardApp
//
//  Created by Mark on 07/07/2016.
//  Copyright © 2016 Mark. All rights reserved.
//

import Foundation
import UIKit
import DBable


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
struct Photo {
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
    
    init?(json: JSON) {
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
    
    static var forriegnKeyName: String? = "complex_object"
    
  //  static var parentPrimaryKeyColumns:[Column] {return [Column(columnName:K.ppKey,columnType: .INTEGER)]}
    static var preferedPrimaryKeyName: String?  { return K.pKey }
    static var objectName: String       { return "photo"}
    static var columns: [Column]        {
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
    var columnMap: [String : Any] {
        return [
            K.pKey      : self.photoID,
            K.ppKey     : self.cameraId,
            K.taken     : self.dateTaken,
            K.uploaded  : self.uploaded ,
            K.ext       : self.fileType.rawValue,
            K.name      : self.name ,
            K.type      : self.fileType.rawValue
        ]
    }
    
    var jsonMap:JSON {
        var map = self.jsonMap
        map[ K.type] = self.fileType.str()
        return map
    }
    
 
}
