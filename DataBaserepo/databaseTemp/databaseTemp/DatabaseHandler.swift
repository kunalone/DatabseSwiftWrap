/*
Copyright 2017 Kunal Darje

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

 */
import UIKit
import Foundation

class DatabaseHandler {
    static let serialQueue = DispatchQueue(label: "databaseQueue")
    typealias successCompletaionHandler = (_ succcess:Bool)->()
    static var enableLog = true;
    
    var databasename = ""
    static var databasePath = ""
    
    static fileprivate var DB :TheDB = TheDB()
    
    private init() {
        
    }
    /**
     This method is used to Migrate your database from normal to FTS
     - parameter tableName: name of existing table to convert from normal table 
     */
    public class func MigrateTableToFTS4String(tableName:String, completion: @escaping successCompletaionHandler){
        self.DB.migrateTableToFTSTable(tableName: tableName) { (result) in
            completion(result)
        }
    }
    
    /**
      This method is used to copy database from main applications bundle to doccument diredtory
      - parameter dbName: dbName A name of the database to be copied from main bundle
      - parameter ofType: An extension of the db like db,sqlite
     */
    public class func copyDatabseIfNeedeD(dbName: String ,extenstion ofType :String){
       // var databasePath = ""

        let pathtoDucuments:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) [0] as String
        let finalPath = pathtoDucuments.appending("/\(dbName).\(ofType)")
        
        let theFileManager = FileManager.default
        
        if theFileManager.fileExists(atPath: finalPath) {
          //..  printOnLog(text: "File exists")
        } else {
           //.. printOnLog(text: "Databse copied")
            let pathToBundledb = Bundle.main.path(forResource:dbName, ofType:ofType)! as String
            
            let pathtoDucuments:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) [0] as String
            
            
            let finalPath = pathtoDucuments.appending("/\(dbName).\(ofType)")
            
            do {
                try theFileManager.copyItem(atPath: pathToBundledb, toPath: finalPath)
            } catch  {
                print(error)
            }
            //DB.db
            databasePath=finalPath;
        }
    }
    
    /**
      This method is for transaction operations for same query and multiple parameteres
     - parameter query: String of query to be executed with "?" at the place of arguments EXA: Insert into Table (_id, ColumnName) Values(?,?)
     - parameter dataArray: This is array of arrays with values for the query to be    executed in transcation
     - return completion: This is completion handler which will return true for the Successful execution
     */
    public class func transactionWithParameters(query: String, dataArray:[[AnyObject]],completion: @escaping successCompletaionHandler){
        serialQueue.sync {
            self.DB.transaction(qureyString: query, parameres: dataArray) { (result) in
                if result == true{
                    self.printOnLog(text: "Transaction working")
                    completion(true)
                }
                else{
                    //self.printOnLog(text: "Transaction failed")
                    completion(false)
                }
            }
        }
    }
    
    /**
     This method is to execute update like queries like UPDATE, DELETE, INSERT
     - parameter queryString: String of query to be executed with "?" at the place of arguments EXA- Insert into Table (_id, ColumnName) Values(?,?)
     - parameter parameters: Array of all the parameters to be added in queries
     - return BOOL: Success or failure of the query execution
     */
    public class func executeUpdate(queryString:String , parameters: [AnyObject])->Bool{
        var returnValue = false
        serialQueue.sync {
            //DB.trial()
            returnValue = DB.executeUpdate(queryString: queryString, parameters: parameters)
        }
        return returnValue
    }
    
    /**
      All kind of select queries has to use this method
     - parameter queryString:  the query Exa: SELECT * from TableName
     - return [AnyObject]: Array of dictonary [String: String]
     */
    public class func executeQuery(queryString :String)->[AnyObject]{
        var array:[AnyObject] = []
        serialQueue.sync {
            array = DB.executeCcommand(query: queryString)
        }
        return array
    }
    /**
     This method is to execute update FTS tables like queries like UPDATE, DELETE, INSERT
     - parameter queryString: String of query to be executed with "?" at the place of arguments EXA- Insert into Table (_id, ColumnName) Values(?,?)
     - parameter parameters: Array of all the parameters to be added in queries
     - return BOOL: Success or failure of the query execution
     */
    public class func executeUpdateForFTS4(queryString:String , parameters: [AnyObject])->Bool{
        var returnValue = false
        serialQueue.sync {
            //DB.trial()
            returnValue = DB.executeUpdate(queryString: queryString, parameters: parameters)
        }
        return returnValue
    }
    /**
     All kind of select queries for FTS table has to use this method
     - parameter queryString:  the query Exa: SELECT * from TableName
     - return [AnyObject]: Array of dictonary [String: String]
     */
    public class func executeQueryForFTS4(queryString :String)->[AnyObject]{
        var array:[AnyObject] = []
        serialQueue.sync {
            array = DB.executeCcommandForFTS4(query: queryString)
        }
        return array
    }
    /**
     This method is for transaction operations on FTS table for same query and multiple parameteres
     - parameter query: String of query to be executed with "?" at the place of arguments EXA: Insert into Table (_id, ColumnName) Values(?,?)
     - parameter dataArray: This is array of arrays with values for the query to be    executed in transcation
     - return completion: This is completion handler which will return true for the Successful execution
     */
    public class func transactionWithParametersFTS4(query: String, dataArray:[[AnyObject]],completion: @escaping successCompletaionHandler){
        serialQueue.sync {
            self.DB.transactionFTS4(qureyString: query, parameres: dataArray) { (result) in
                if result == true{
                    self.printOnLog(text: "Transaction working")
                    completion(true)
                }
                else{
                    //self.printOnLog(text: "Transaction failed")
                    completion(false)
                }
            }
        }
    }

    /**
    This method to be called to open the database
     - parameter DBname: String of database name Exa: "Data.sqlite"
     */
    public class func openDb(DBname: String){
        let pathtoDucuments:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) [0] as String
        let finalPath = pathtoDucuments.appending("/\(DBname)")
        
        DatabaseHandler.databasePath=finalPath;
        DatabaseHandler.DB.openDB();
    }
    
    /**
     This method to be called to Close the database
     */
    public class func closeDB(){
        DatabaseHandler.DB.closeDB()
    }
    
    fileprivate class func printOnLog(text: String){
        if enableLog == true{
            print(text)
        }
    }
}

fileprivate struct TheDB {
    var sqliteDB: OpaquePointer? = nil
    typealias successCompletaionHandler = (_ succcess:Bool)->()
    public var dbPath = ""
    var columnNameArray:[String] = []
    var values:[[String]] = [[]]
    let emptyArray:[AnyObject] = []
    
    fileprivate mutating func migrateTableToFTSTable(tableName:String,completion: @escaping successCompletaionHandler ){
        let query = "SELECT * FROM \(tableName)"
        let recoreds = executeCcommand(query: query)
        
        if recoreds.count > 0 {
            let firstRecord = recoreds[0] as! [String: AnyObject]
            let keysArray = firstRecord.keys;
            columnNameArray = Array(keysArray.map { ($0) })
            print(firstRecord.keys)
        }
        else{
            DatabaseHandler.printOnLog(text: "This is empty table")
            DispatchQueue.main.async {
                completion(false)
            }
            
        }
        
        for dictonary in recoreds {
            let firstRecord = dictonary as! [String: AnyObject]
            let keysArray = firstRecord.values;
            let tempArray = Array(keysArray.map { ($0) }) as! [String]
            values.append(tempArray)
        }
        
        if values.count == 0 {
            DatabaseHandler.printOnLog(text: "This is empty table")
            DispatchQueue.main.async {
                completion(false)
            }
        }
        
        var columnString = columnNameArray.joined(separator: " TEXT,")
        columnString = columnString.appending(" TEXT")
        
        
        let FTStableQuery = "CREATE VIRTUAL TABLE \(tableName)FTS4 USING FTS4(\(columnString))"
        print(FTStableQuery)
        
        let result = executeUpdate(queryString: FTStableQuery, parameters: emptyArray)
        let questionMarkArray = Array(repeating: "?", count: columnNameArray.count)
        let placeholderSring = questionMarkArray.joined(separator: ",")
        let insertQuery = "INSERT INTO \(tableName)FTS4 Values(\(placeholderSring))"
        
        if result == true {
            transactionFTS4(qureyString: insertQuery, parameres: values as [[AnyObject]], completion: { (result) in
                if result == true{
                    DispatchQueue.main.async {
                        completion(true)
                    }
                }
                else{
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            })
        }
    }
    
    fileprivate func transaction(qureyString: String, parameres : [[AnyObject]],completion :@escaping successCompletaionHandler){
        var transacstionStatus = true;
        
        sqlite3_exec(sqliteDB, "BEGIN EXCLUSIVE TRANSACTION", nil, nil, nil);
        let buffer = qureyString;
        var statement: OpaquePointer? = nil
        //sqlite3_prepare_v2(sqliteDB, buffer, Int32(strlen(buffer)),&statement, nil)
        
        sqlite3_prepare_v2(sqliteDB, buffer, Int32(strlen(buffer)),&statement, nil)
        
        for array:[AnyObject] in parameres {
            for (index,item) in array.enumerated() {
               
                let theIndex = index + 1
                if item is Int {
                    sqlite3_bind_int(statement, Int32(theIndex), item as! Int32)
                }
                
                if item is String {
                    let temp = sqlite3_bind_text(statement, Int32(theIndex), item.utf8String, -1, nil)
                    if temp != SQLITE_OK {
                        let errorMessage = String(utf8String: sqlite3_errmsg(sqliteDB))
                        DatabaseHandler.printOnLog(text: "the error \(errorMessage!)")
                    }
                }
            }
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMessage = String(utf8String: sqlite3_errmsg(sqliteDB))
                DatabaseHandler.printOnLog(text: "the error \(errorMessage!)")
                DatabaseHandler.printOnLog(text: "Commit Failed!")
                transacstionStatus = false
                completion(false)
            }
            sqlite3_reset(statement)
        }
        
        if transacstionStatus != false {
            completion(transacstionStatus)
        }
        sqlite3_exec(sqliteDB, "COMMIT TRANSACTION", nil, nil, nil)
        sqlite3_finalize(statement)
    }
    
    
    fileprivate func executeUpdate(queryString: String, parameters: [AnyObject])->Bool{
        var returnValue = false
        var statement: OpaquePointer? = nil
        if sqlite3_prepare_v2(sqliteDB, queryString, -1, &statement, nil) == SQLITE_OK {
            if parameters.count > 0 {
                for (index,item) in parameters.enumerated() {
                    let theIndex = index + 1
                    if item is Int {
                        sqlite3_bind_int(statement, Int32(theIndex), item as! Int32)
                    }
                    
                    if item is String {
                        sqlite3_bind_text(statement, Int32(theIndex), item.utf8String, -1, nil)
                    }
                }

            }
            
            if sqlite3_step(statement) == SQLITE_DONE {
                returnValue = true
                DatabaseHandler.printOnLog(text: "Successfully executed query");
            } else {
                DatabaseHandler.printOnLog(text: "Failed executed query");
            }
        } else {
            DatabaseHandler.printOnLog(text: "Error while Executing -> \(queryString)");
            let errorMessage = String(utf8String: sqlite3_errmsg(sqliteDB))
            DatabaseHandler.printOnLog(text: "the error \(errorMessage!)");
        }
        return returnValue
    }
    
    fileprivate mutating func executeCcommand(query: String)->[AnyObject]{
        var returnArray: [AnyObject] = []
        var pStmt: OpaquePointer? = nil
        
        let status = sqlite3_prepare_v2(sqliteDB, query, -1, &pStmt, nil)
        if status != SQLITE_OK {
            DatabaseHandler.printOnLog(text: "Error while Executing -> \(query)");
            let errorMessage = String(utf8String: sqlite3_errmsg(sqliteDB))
            DatabaseHandler.printOnLog(text: "the error \(errorMessage!)");
        }
        else{
            DatabaseHandler.printOnLog(text: "Successfully executed query");
            while sqlite3_step(pStmt) == SQLITE_ROW {
                var row:[String: AnyObject] = [:]
                let resultCount = sqlite3_column_count(pStmt)
                for index in 0..<resultCount {
                    let columnName = String(utf8String: sqlite3_column_name(pStmt  , index))
                    let columnType:String? = String(utf8String: sqlite3_column_decltype(pStmt  , index))
                    if columnName != nil {
                        if let columnValue: AnyObject = getColumnValue(statement: pStmt!, index:index, type: columnType!) {
                            row[columnName!] = columnValue
                        }
                    }
                    
                }
                returnArray.append(row as AnyObject)
            }
        }
        return returnArray
    }
    
    //Opening database
    fileprivate mutating func openDB(){
        
        let status = sqlite3_open(DatabaseHandler.databasePath.cString(using: String.Encoding.utf8)!, &sqliteDB)
        if status != SQLITE_OK {
            DatabaseHandler.printOnLog(text: "SwiftData Error -> During: Opening Database")
            sqlite3_errmsg(sqliteDB)
        }
        else{
            DatabaseHandler.printOnLog(text: "databse opened successfully")
        }
    }
    
    //Closing database
    fileprivate mutating func closeDB(){
        sqlite3_close(sqliteDB)
    }
    
    //Getting value for column
    func getColumnValue(statement: OpaquePointer, index: Int32, type: String) -> AnyObject? {
        
        switch type {
        case "INT", "INTEGER", "TINYINT", "SMALLINT", "MEDIUMINT", "BIGINT", "UNSIGNED BIG INT", "INT2", "INT8":
            if sqlite3_column_type(statement, index) == SQLITE_NULL {
                return nil
            }
            return Int(sqlite3_column_int(statement, index)) as AnyObject?
        case "CHARACTER(20)", "VARCHAR(255)", "VARYING CHARACTER(255)", "NCHAR(55)", "NATIVE CHARACTER", "NVARCHAR(100)", "TEXT", "CLOB","TEXT DEFALUT \" \"":
            let string = String(cString: sqlite3_column_text(statement, index))
            return string as AnyObject?
        case "BLOB", "NONE":
            let blob = sqlite3_column_blob(statement, index)
            if blob != nil {
                let size = sqlite3_column_bytes(statement, index)
                return NSData(bytes: blob, length: Int(size))
            }
            return nil
        case "REAL", "DOUBLE", "DOUBLE PRECISION", "FLOAT", "NUMERIC", "DECIMAL(10,5)":
            if sqlite3_column_type(statement, index) == SQLITE_NULL {
                return nil
            }
            return Double(sqlite3_column_double(statement, index)) as AnyObject?
        case "BOOLEAN":
            if sqlite3_column_type(statement, index) == SQLITE_NULL {
                return nil
            }
            
            var returnBool = false
            if sqlite3_column_int(statement, index) != 0 {
                returnBool = true
            }
            
            return returnBool as AnyObject?
        case "DATE", "DATETIME":
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let string = String(cString: sqlite3_column_text(statement, index))
            // if let string = String.fromCString(text!) {
            return dateFormatter.date(from: string) as AnyObject?
            // }
            // print("SwiftData Warning -> The text date at column: \(index) could not be castas!a String, returning nil")
        //return nil
        default:
            DatabaseHandler.printOnLog(text: "SwiftData Warning -> Column: \(index) is of an unrecognized type, returning nil")
            return nil
        }
        
    }
    
    //Fetching data from fts4 db
    fileprivate mutating func executeCcommandForFTS4(query: String)->[AnyObject]{
        var returnArray: [AnyObject] = []
        var pStmt: OpaquePointer? = nil
        
        let status = sqlite3_prepare_v2(sqliteDB, query, -1, &pStmt, nil)
        if status != SQLITE_OK {
            DatabaseHandler.printOnLog(text: "Error while Executing -> \(query)");
            let errorMessage = String(utf8String: sqlite3_errmsg(sqliteDB))
            DatabaseHandler.printOnLog(text: "the error \(errorMessage!)");
        }
        else{
            DatabaseHandler.printOnLog(text: "Successfully executed query");
            while sqlite3_step(pStmt) == SQLITE_ROW {
                var row:[String: AnyObject] = [:]
                let resultCount = sqlite3_column_count(pStmt)
                for index in 0..<resultCount {
                    let columnName = String(utf8String: sqlite3_column_name(pStmt  , index))
                   // let columnType = String(utf8String: sqlite3_column_name(pStmt  , index))
                    let columnType="TEXT"
        // let columnType:String? = String(utf8String: sqlite3_column_decltype(pStmt  , index))
                    if columnName != nil {
                        if let columnValue: AnyObject = getColumnValue(statement: pStmt!, index:index, type:columnType) {
                            row[columnName!] = columnValue
                        }
                    }
                    
                }
                returnArray.append(row as AnyObject)
            }
        }
        return returnArray
    }

    fileprivate func transactionFTS4(qureyString: String, parameres : [[AnyObject]],completion :@escaping successCompletaionHandler){
        var transacstionStatus = true;
        
        sqlite3_exec(sqliteDB, "BEGIN EXCLUSIVE TRANSACTION", nil, nil, nil);
        let buffer = qureyString;
        var statement: OpaquePointer? = nil
        sqlite3_prepare_v2(sqliteDB, buffer, Int32(strlen(buffer)),&statement, nil)
        
        for array:[AnyObject] in parameres {
            for (index,item) in array.enumerated() {
                let theIndex = index + 1
                
                if item is String {
                    sqlite3_bind_text(statement, Int32(theIndex), item.utf8String, -1, nil)
                }
                else if item is Int {
                    sqlite3_bind_int(statement, Int32(theIndex), item as! Int32)
                }
                else{
                    DatabaseHandler.printOnLog(text: "Commit Failed!")
                    DatabaseHandler.printOnLog(text: "For FTS4 transaction every entry shoud be String")
                    transacstionStatus = false
                    completion(transacstionStatus)
                }
            }
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMessage = String(utf8String: sqlite3_errmsg(sqliteDB))
                DatabaseHandler.printOnLog(text: "the error \(errorMessage!)")
                DatabaseHandler.printOnLog(text: "Commit Failed!")
                transacstionStatus = false
                completion(false)
            }
            sqlite3_reset(statement)
        }
        
        if transacstionStatus != false {
            completion(transacstionStatus)
        }
        sqlite3_exec(sqliteDB, "COMMIT TRANSACTION", nil, nil, nil)
        sqlite3_finalize(statement)
    }
    
    fileprivate func executUpdateForFTS4(queryString: String, parameters: [AnyObject])->Bool{
        var returnValue = false
        var statement: OpaquePointer? = nil
        if sqlite3_prepare_v2(sqliteDB, queryString, -1, &statement, nil) == SQLITE_OK {
            
            for (index,item) in parameters.enumerated() {
                let theIndex = index + 1
                
                if item is String {
                    sqlite3_bind_text(statement, Int32(theIndex), item.utf8String, -1, nil)
                }
                else{
                    DatabaseHandler.printOnLog(text: "Commit Failed!")
                    DatabaseHandler.printOnLog(text: "For FTS4 transaction every entry shoud be String")
                    return false
                }
            }
            
            if sqlite3_step(statement) == SQLITE_DONE {
                returnValue = true
                DatabaseHandler.printOnLog(text: "Successfully executed query");
            } else {
                DatabaseHandler.printOnLog(text: "Failed executed query");
            }
        } else {
            DatabaseHandler.printOnLog(text: "Error while Executing -> \(queryString)");
            let errorMessage = String(utf8String: sqlite3_errmsg(sqliteDB))
            DatabaseHandler.printOnLog(text: "the error \(errorMessage!)");
        }
        return returnValue
    }
    
}
