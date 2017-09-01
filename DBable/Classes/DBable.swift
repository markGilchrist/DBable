import Foundation
import FMDB


public enum ColumnTypes: String {
    case REAL
    case INTEGER
    case DECIMAL
    case TEXT
    case DATE
    case BOOL_AS_INTEGER = "INT"
    
    static let values:[ColumnTypes] = [.REAL,.INTEGER,.DECIMAL,.TEXT,.DATE,.BOOL_AS_INTEGER]
    
    init(name:String) {
        if name == "INT" {
            self = .BOOL_AS_INTEGER
        } else {
            self = ColumnTypes.values.first{ name.uppercased() == $0.rawValue } ?? .INTEGER
        }
    }
}

public struct Column{
    public let columnName:String
    public let columnType:ColumnTypes
    public let defaults : String?
    
    public init(name:String,type:ColumnTypes, defaults:String? = nil){
        self.columnName = name
        self.columnType = type
        self.defaults   = defaults
    }
    
}

extension Column:Equatable, Hashable {
    
    public var hashValue:Int{
        return columnName.hashValue
    }
    
    static public func ==(lhs:Column,rhs:Column) -> Bool {
        return lhs.columnName.lowercased() == rhs.columnName.lowercased() && lhs.columnType == rhs.columnType
    }

}

public typealias JSON = [String:Any]

enum JSONErrors: Error{
    case UnWrapJSONFailsForKey
}

public protocol JSONDecodable {
    init?(json:JSON)
}

extension JSONDecodable {
    
    public static func getValue<T>(json:JSON,key:String) throws -> T {
        guard let value:T  = json[key] as? T else {
            print("passing value for key ->\(key) fails  for json ->\(json)")
            throw JSONErrors.UnWrapJSONFailsForKey
        }
        return value
    }
    
    public static func getArray<T: JSONDecodable >(input:Any?) -> [T]{
        guard let json:[JSON] = input as? [JSON] else { return [] }
        return  json.map({ T(json: $0)}).flatMap{$0}
    }
}



public protocol DBableType {}

public protocol DBable: JSONDecodable {
    
    
    /** This is method is called to insert or Update the Object */
    func save()
    
    /** This removes an object from the database */
    func delete()
    
    /** This insert the object into the database*/
    func insert()
    
    /** This uspdates based on the primary key*/
    func update()
    
    /** This is What maps the values to the columns  */
    var columnMap:[String:Any] {get}
    
    
    
    /** This is called when searching for an object by and ID */
    static func get(id:Int) -> Self?
    
    /** This is call to retrieve all the Objects in the Database */
    static func getAll() -> [Self]
    
    /** This creates the table for the object */
    static var createTableString: () -> String { get }
    
    // @available(*, deprecated: 0.1,message:  "please add these defaults to the column Object")
    // static var defaults:[String:String] {get}
    
    /**
     This is the primary key by which all is referanced
     - note: If the object you are modeling does not have primary key return nil
     */
    static var preferedPrimaryKeyName:String? { get }
    
    /**
     This is the foreign key by which all is referanced
     - note: If the object you are modeling does not have forriegn key return nil
     */
    static var forriegnKeyName:String? { get }
    
    /**
     This is the name of the Database Table
     */
    static var objectName:String { get }
    
    static var isPrimaryKeyUsed:Bool { get }
    
    /** This is a touple Array of all the columns,types in the table */
    static var columns:[Column] { get }
    
    
    
    /// Array storable
    
    
    /** This is a dictionay of all the arrays you wish to map*/
    var arrayMap:[ String:[Any]] { get }
    
    
    /** This let us know what we are storing */
    static var arrayType:[String: ColumnTypes] { get }
    
    
    //object storeable
    
    /**
     This finction is called for every row in the datbase that is found.
     this is the point where you add arrays of numbers strings,
     other DBable Objects or arrays of them to your search result.
     If you dont implement this then object JSON returned will be nothing but a
     row in the database without any arrays or child objects
     
     */
    static func addValuesFromOtherTablesToJsonFromDB(json:[JSON]) -> [JSON]
    
    /// This is called as a hook for when the object creates a table for itsself
    static func createReferanceTables()
    
    func onSaveCalled()
    
}






public func getDate(obj:Any?) -> Date? {
    if let date = obj as? Date {
        return date
    } else if let dateStr = obj as? Double {
        return  Date(timeIntervalSince1970: dateStr)
    }
    return nil
}

public func getInt(obj:Any?) ->Int? {
    if let id = obj as? Int{
        return id
    }else if let idStr = obj as? String {
        return Int(idStr)
    }
    return nil
}


//extension Dictionary where Key: StringLiteralConvertible, Value: Any {
//
//    public func bool(key:String) -> Bool {
//        let me = (self as! Any )as! [String:Any]
//        return me[key] as! Int == 1
//    }
//    public func int(key:String) -> Int{
//        let me = (self as! Any )as! [String:Any]
//        return me[key] as! Int
//    }
//    public func double(key:String) -> Double{
//        let me = (self as! Any )as! [String:Any]
//        return me[key] as! Double
//    }
//    public func string(key:String) -> String{
//        let me = (self as! Any )as! [String:Any]
//        return me[key] as! String
//    }
//
//}


extension Date{
    
    public func niceTime() -> String {
        let dateFormatter           = DateFormatter()
        dateFormatter.locale        = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone      = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat    = "HH:mm:ss dd MMM yy "
        return dateFormatter.string(from: self)
    }
    
    public func ISOStringFromDate() -> String {
        let dateFormatter           = DateFormatter()
        dateFormatter.locale        = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone      = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat    = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.string(from: self).appending("Z")
    }
    
    public func dateFromISOString(string: String) -> Date? {
        let dateFormatter           = DateFormatter()
        dateFormatter.locale        = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone      = NSTimeZone.local
        dateFormatter.dateFormat    = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter.date(from: string)
    }
    
    public func dateFromISOsortOfString(string: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: string)
    }
}



extension DBable {
    public static var isPrimaryKeyUsed:Bool     { return Self.preferedPrimaryKeyName != nil  }
    public static var isForreignKeyUsed:Bool    { return Self.forriegnKeyName != nil }
    public static var primaryKeyName:String     { return Self.preferedPrimaryKeyName ?? "ID" }
    // public static var preferedPrimaryKeyName:String? { return nil }
    // public static var forriegnKeyName:String? { return nil  }
    public static var objectName: String        { return String(describing: self).lowercased() }
    public var primaryKeyValue: Int             { return self.columnMap[Self.primaryKeyName] as? Int ?? 0}
    
    public func onSaveCalled(){
    }
    
    public var JsonMap:[String:Any]{
        let colmap = self.columnMap
        var map:JSON = [:]
        for key in colmap.keys {
            if let date = colmap[key] as? Date{
                map[key] = date.ISOStringFromDate()
            }else{
                map[key] = colmap[key]
            }
        }
        return map
    }
    
    
    
    /**
     This function returns a closure that will automatically create you create table string
     */
    public final static var createTableString: () -> String {
        return {
            let strings:[String] = Self.columns.map{
                "\($0.columnName.uppercased()) \($0.columnType.rawValue)\($0.columnName == Self.primaryKeyName ? " \(DB.primaryKey)" : "")\($0.defaults ?? "")"}
            return "\(DB.createTable) \(Self.objectName.uppercased()) (\(strings.joined(separator: ",")));"
        }
    }
    
    /**
     This function returns a closure that will automatically create you an insert string with place holders
     */
    public final static var insertString: ()->String {
        return {
            var strings:[String]    = []
            var endString:[String]  = []
            for column in Self.columns {
                strings.append("\(column.columnName.uppercased())")
                endString.append(":\(column.columnName.lowercased())")
            }
            return "\(DB.insert) \(Self.objectName.uppercased()) (\(strings.joined(separator: ",")))VALUES(\(endString.joined(separator: ",")));"
        }
    }
    
    /**
     This function returns a closure that will automatically create you an insert string with place holders but it removes the placeholder for the primaryKey, so you can insert and let the local db auto increment in it
     */
    public final static var insertFirstString: ()->String {
        return {
            var strings:[String]    = []
            var endString:[String]  = []
            for column in Self.columns.filter({$0.columnName != Self.primaryKeyName }) {
                strings.append("\(column.columnName.uppercased())")
                endString.append(":\(column.columnName.lowercased())")
            }
            return "\(DB.insert) \(Self.objectName.uppercased()) (\(strings.joined(separator: ",")))VALUES(\(endString.joined(separator: ",")));"
        }
    }
    
    /**    */
    public final static var insertOnConflictIgnore:()->String {
        return{
            var strings:[String]    = []
            var endString:[String]  = []
            for column in Self.columns {
                strings.append("\(column.columnName.uppercased())")
                endString.append(":\(column.columnName.lowercased())")
            }
            return "\(DB.insertOnConflict) \(Self.objectName.uppercased()) (\(strings.joined(separator: ",")))VALUES(\(endString.joined(separator: ",")));"
        }
    }
    
    
    public final static var updateString: ()->String {
        return {
            assert(Self.isPrimaryKeyUsed,"Warning, with out using primary key this will fail")
            let updateColumns = Self.columns.filter{ $0.columnName != Self.primaryKeyName}
            var strings:[String]    = []
            for column in updateColumns {
                strings.append("\(column.columnName.uppercased()) = :\(column.columnName.lowercased())")
            }
            return "\(DB.update) \(Self.objectName.uppercased()) SET \(strings.joined(separator: ",")) WHERE \(Self.primaryKeyName.uppercased()) = :\((Self.primaryKeyName).lowercased());"
        }
    }
    
    
    public final static var updateByWhereString: (_ clause:String) -> String {
        return { clause in
            let updateColumns = Self.columns.filter{ $0.columnName != Self.primaryKeyName }
            var strings:[String]    = []
            for column in updateColumns {
                strings.append("\(column.columnName.uppercased()) = :\(column.columnName.lowercased())")
            }
            return "\(DB.update) \(Self.objectName.uppercased()) SET \(strings.joined(separator: ",")) WHERE \(clause);"
        }
    }
    
    public final static var updateColumns:(_ columns:[Column]) -> String {
        return { cols in
            var strings:[String] = []
            for column in cols {
                strings.append("\(column.columnName.uppercased()) = :\(column.columnName.lowercased())")
            }
            return "\(DB.update) \(Self.objectName.uppercased()) SET \(strings.joined(separator: ",")) WHERE \(Self.primaryKeyName.uppercased()) = :\(Self.primaryKeyName.lowercased());"
        }
    }
    
    public static final var countAllString: () -> String{
        return {
            return "\(DB.select) COUNT(\(self.primaryKeyName.uppercased())) FROM \(Self.objectName.uppercased());"
        }
    }
    
    public final static var selectAllString: ()->String {
        return {
            return "\(DB.selectAll) \(Self.objectName.uppercased());"
        }
    }
    
    public final static var selectByIdString: ()->String {
        return {
            assert(Self.isPrimaryKeyUsed,"Warning, with out using primary key this will fail")
            return "\(DB.selectAll) \(Self.objectName.uppercased()) WHERE \(Self.primaryKeyName.uppercased() ) = :\(Self.primaryKeyName.lowercased());"
        }
    }
    
    public final static var selectAllWhereString: (_ clause:String)->String {
        return { clause in
            return "\(DB.selectAll) \(Self.objectName.uppercased()) WHERE \(clause);"
        }
    }
    
    public final static var selectWhereIn: (_ arr:[Int])->String {
        return { arr in
            return "\(DB.selectAll) \(Self.objectName.uppercased()) WHERE ID IN (\(arr.map({ "\($0.description)" }).joined(separator:",") ));"
        }
    }
    
    
    public final static var selectAllByForriegnKeyString: (_ eqaulsValue:AnyObject)->String {
        return { value in
            if let fk = Self.forriegnKeyName {
                return "\(DB.selectAll) \(Self.objectName.uppercased()) WHERE \(fk.uppercased()) = :\(value.description);"
            }else{
                return "foreign key is nil error;"
            }
        }
    }
    
    public final static var selectAllWhereColumnEquals: (_ column:Column)->String {
        return { col in
            return "\(DB.selectAll) \(Self.objectName.uppercased()) WHERE \(col.columnName.uppercased()) = :\(col.columnName.lowercased());"
        }
    }
    
    public final static var selectAllWhereColumnGreaterThan: (_ column:Column)->String {
        return { col in
            return "\(DB.selectAll) \(Self.objectName.uppercased()) WHERE \(col.columnName.uppercased()) > :\(col.columnName.lowercased());"
        }
    }
    
    public final static var selectAllWhereColumnLessThan: (_ column:Column)->String {
        return { col in
            return "\(DB.selectAll) \(Self.objectName.uppercased()) WHERE \(col.columnName.uppercased()) < :\(col.columnName.lowercased());"
        }
    }
    
    
    public final static var deleteByIdString: ()->String {
        return {
            assert(Self.isPrimaryKeyUsed,"Warning, with out using primary key this will fail")
            return "\(DB.delete) \(Self.objectName.uppercased()) WHERE \(Self.primaryKeyName.uppercased()) = :\(Self.primaryKeyName.lowercased());"
        }
    }
    
    public final static var deleteAllString: ()->String {
        return {
            return "\(DB.delete) \(Self.objectName.uppercased());"
        }
    }
    
    public final static var deleteAllByPrimaryKeyString: ()->String {
        return {
            return "\(DB.delete) \(Self.objectName.uppercased()) WHERE \(Self.primaryKeyName.uppercased()) = :\(Self.primaryKeyName.lowercased());"
        }
    }
    
    public final static var deleteAllWhereString: (_ clause:String) -> String {
        return { clause in
            return "\(DB.delete) \(Self.objectName.uppercased()) WHERE \(clause);"
        }
    }
    
    public final static var dropTableString: ()->String {
        return {
            return "\(DB.dropTable) \(Self.objectName.uppercased());"
        }
    }
    
}
