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

class DatabaseSingleton {
    let serialQueue = DispatchQueue(label: "databaseQueue")
    typealias successCompletaionHandler = (_ succcess:Bool)->()
    var enableLog = true;
    
    var databasename = ""
    var databasePath = ""
    
    static let sharedInstance = DatabaseSingleton()
    fileprivate var DB :TheDB = TheDB()
    
    private init() {
        
    }
    
    /**
      This method is used to copy database from main applications bundle to doccument diredtory
      - parameter dbName: dbName A name of the database to be copied from main bundle
      - parameter ofType: An extension of the db like db,sqlite
     */
    public func copyDatabseIfNeedeD(dbName: String ,extenstion ofType :String){
        
        let pathtoDucuments:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) [0] as String
        let finalPath = pathtoDucuments.appending("/\(dbName).\(ofType)")
        
        let theFileManager = FileManager.default
        
        if theFileManager.fileExists(atPath: finalPath) {
            printOnLog(text: "File exists")
        } else {
            printOnLog(text: "Databse copied")
            let pathToBundledb = Bundle.main.path(forResource:dbName, ofType:ofType)! as String
            
            let pathtoDucuments:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) [0] as String
            let finalPath = pathtoDucuments.appending("/\(dbName).\(ofType)")
            
            do {
                try theFileManager.copyItem(atPath: pathToBundledb, toPath: finalPath)
            } catch  {
                print(error)
            }
            databasePath=finalPath;
        }
    }
    
    /**
      This method is for transaction operations for same query and multiple parameteres
     - parameter query: String of query to be executed with "?" at the place of arguments EXA: Insert into Table (_id, ColumnName) Values(?,?)
     - parameter dataArray: This is array of arrays with values for the query to be    executed in transcation
     - return completion: This is completion handler which will return true for the Successful execution
     */
    public func transactionWithParameters(query: String, dataArray:[[AnyObject]],completion: @escaping successCompletaionHandler){
        serialQueue.sync {
            self.DB.transaction(qureyString: query, parameres: dataArray) { (result) in
                if result == true{
                    self.printOnLog(text: "Transaction working")
                    completion(true)
                }
                else{
                    self.printOnLog(text: "Transaction failed")
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
    public func executeUpdate(queryString:String , parameters: [AnyObject])->Bool{
        var returnValue = false
        serialQueue.sync {
            //DB.trial()
            returnValue = DB.executUpdate(queryString: queryString, parameters: parameters)
        }
        return returnValue
    }
    
    /**
      All kind of select queries has to use this method
     - parameter queryString:  the query Exa: SELECT * from TableName
     - return [AnyObject]: Array of dictonary [String: String]
     */
    public func executeQuery(queryString :String)->[AnyObject]{
        var array:[AnyObject] = []
        serialQueue.sync {
            array = DB.executeCcommand(query: queryString)
        }
        return array
    }
    
    /**
    This method to be called to open the database
     - parameter DBname: String of database name Exa: "Data.sqlite"
     */
    public func openDb(DBname: String){
        let pathtoDucuments:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) [0] as String
        let finalPath = pathtoDucuments.appending("/\(DBname)")
        
        databasePath=finalPath;
        DB.openDB();
    }
    /**
     This method to be called to Close the database
     */
    
    public func closeDB(){
        DB.closeDB()
    }
    
    fileprivate func printOnLog(text: String){
        if enableLog == true{
            print(text)
        }
    }
}

private struct TheDB {
    var sqliteDB: OpaquePointer? = nil
    typealias successCompletaionHandler = (_ succcess:Bool)->()
    
    
    fileprivate func transaction(qureyString: String, parameres : [[AnyObject]],completion :@escaping successCompletaionHandler){
        var transacstionStatus = true;
        
        sqlite3_exec(sqliteDB, "BEGIN EXCLUSIVE TRANSACTION", nil, nil, nil);
        let buffer = qureyString;
        var statement: OpaquePointer? = nil
        sqlite3_prepare_v2(sqliteDB, buffer, Int32(strlen(buffer)),&statement, nil)
        
        for array:Array in parameres {
            for (index,item) in array.enumerated() {
                let theIndex = index + 1
                if item is Int {
                    sqlite3_bind_int(statement, Int32(theIndex), item as! Int32)
                }
                
                if item is String {
                    sqlite3_bind_text(statement, Int32(theIndex), item.utf8String, -1, nil)
                }
            }
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMessage = String(utf8String: sqlite3_errmsg(sqliteDB))
                DatabaseSingleton.sharedInstance.printOnLog(text: "the error \(errorMessage!)")
                DatabaseSingleton.sharedInstance.printOnLog(text: "Commit Failed!")
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
    
    
    fileprivate func executUpdate(queryString: String, parameters: [AnyObject])->Bool{
        var returnValue = false
        var statement: OpaquePointer? = nil
        if sqlite3_prepare_v2(sqliteDB, queryString, -1, &statement, nil) == SQLITE_OK {
            
            for (index,item) in parameters.enumerated() {
                let theIndex = index + 1
                if item is Int {
                    sqlite3_bind_int(statement, Int32(theIndex), item as! Int32)
                }
                
                if item is String {
                    sqlite3_bind_text(statement, Int32(theIndex), item.utf8String, -1, nil)
                }
            }
            
            if sqlite3_step(statement) == SQLITE_DONE {
                returnValue = true
                DatabaseSingleton.sharedInstance.printOnLog(text: "Successfully executed query");
            } else {
                DatabaseSingleton.sharedInstance.printOnLog(text: "Failed executed query");
            }
        } else {
            DatabaseSingleton.sharedInstance.printOnLog(text: "Error while Executing -> \(queryString)");
            let errorMessage = String(utf8String: sqlite3_errmsg(sqliteDB))
            DatabaseSingleton.sharedInstance.printOnLog(text: "the error \(errorMessage!)");
        }
        return returnValue
    }
    
    fileprivate mutating func executeCcommand(query: String)->[AnyObject]{
        var returnArray: [AnyObject] = []
        var pStmt: OpaquePointer? = nil
        
        let status = sqlite3_prepare_v2(sqliteDB, query, -1, &pStmt, nil)
        if status != SQLITE_OK {
            DatabaseSingleton.sharedInstance.printOnLog(text: "Error while Executing -> \(query)");
            let errorMessage = String(utf8String: sqlite3_errmsg(sqliteDB))
            DatabaseSingleton.sharedInstance.printOnLog(text: "the error \(errorMessage!)");
        }
        else{
            DatabaseSingleton.sharedInstance.printOnLog(text: "Successfully executed query");
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
        
        let status = sqlite3_open(DatabaseSingleton.sharedInstance.databasePath.cString(using: String.Encoding.utf8)!, &sqliteDB)
        if status != SQLITE_OK {
            DatabaseSingleton.sharedInstance.printOnLog(text: "SwiftData Error -> During: Opening Database")
            sqlite3_errmsg(sqliteDB)
        }
        else{
            DatabaseSingleton.sharedInstance.printOnLog(text: "databse opened successfully")
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
            DatabaseSingleton.sharedInstance.printOnLog(text: "SwiftData Warning -> Column: \(index) is of an unrecognized type, returning nil")
            return nil
        }
        
    }
    
}
