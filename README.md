# DatabseSwiftWrap
Database wrapper for iOS using swift

# DatabseSwiftWrap

A simple database wrapper for database operations in swift 3.0, basic methods. Simple installation no pods of flags. Currently implemented for basic queries and transactions. Comming soon feature is support for FTS tables support. 

## Getting Started

Copy or clone the repository on your mac, find DatabaseSingleton.swift file in the project and copy it in your project. Create birdging header file for your project and import sqlite fiel into it Exa: #import<sqlite3.h> 

### Prerequisites

Xcode 8 and above
SQlite3

### Installing

Follow everything on getting started and then start implementing methods for following examples 

Working with this file is easy using its singleton obejct.


### Setting library
The copyDatabseIfNeedeD method is used to copy database from main applications bundle to doccument diredtory
- parameter dbName: dbName A name of the database to be copied from main bundle
- parameter ofType: An extension of the db like db,sqlite

```swift
DatabaseSingleton.copyDatabseIfNeedeD(dbName: "TestDatabase", extenstion: "sqlite")
```

The openDb to be called to open the database
- parameter DBname: String of database name Exa: "Data.sqlite"

```swift
DatabaseSingleton.openDb(DBname: "TestDatabase.sqlite")
```

The closeDB method to be called to close the database

```swift
DatabaseSingleton.closeDB()
```


 If enableLog flag is false wont print query errors on the log

```swift
DatabaseSingleton.enableLog = true
```
### Migration from normal table to FTS table 
MigrateTableToFTS4String Method below can be user to convert the normal tables to FTS tables
```swift
DatabaseHandler.MigrateTableToFTS4String(tableName: "Student") { (result) in
    if result == true{
        print("migration working ")
    }
    else{
        print("Migration failed")
    }
}
```
### Transaction query execution on FTS table
The transactionWithParametersFTS4 method is for transaction operations on FTS table for same query and multiple parameteres
- parameter query: String of query to be executed with "?" at the place of arguments EXA: Insert into Table (_id, ColumnName) Values(?,?)
- parameter dataArray: This is array of arrays with values for the query to be    executed in transcation
- return completion: This is completion handler which will return true for the Successful execution

```swift
let dataArray = ["Kunal", "Pune", "314"]

let string = "INSERT INTO StudentInfo Values(?,?,?)"

let threeDoubles = Array(repeating: dataArray, count: 1000)


DatabaseHandler.transactionWithParametersFTS4(query: string, dataArray: threeDoubles as [[AnyObject]]) { (result) in
if result == true{
print("transaction successful")
// transcation executed successfully
}
}

#### Other CRUD operations can be performed using executeUpdateForFTS4 and executeQueryForFTS4 methods just like normal operations following is the demo for normal databse queries

### Setting library CRUD operations

The executeUpdate method is to execute update like queries like UPDATE, DELETE, INSERT
- parameter queryString: String of query to be executed with "?" at the place of arguments EXA- Insert into Table (_id, ColumnName) Values(?,?)
- parameter parameters: Array of all the parameters to be added in queries
- return BOOL: Success or failure of the query execution

```swift
let result = DatabaseSingleton.executeUpdate(queryString: "INSERT INTO Student Values('Kunal','Pune','314')", parameters: emptyArray)

if result == true{
//executed successflly
}

let updateQuery:String = "UPDATE Student SET name = ? Where address = ?"

let updateResult = DatabaseSingleton.executeUpdate(queryString: updateQuery, parameters: ["One" as AnyObject,"pune" as AnyObject])

if updateResult == true {
//executed successflly
}

```

All kind of select queries has to use executeQuery method
- parameter queryString:  the query Exa: SELECT * from TableName
- return [AnyObject]: Array of dictonary [String: String]

```swift
let theData = DatabaseSingleton.executeQuery(queryString: "SELECT * FROM Student")

```

The transactionWithParameters method is for transaction operations for same query and multiple parameteres
- parameter query: String of query to be executed with "?" at the place of arguments EXA: Insert into Table (_id, ColumnName) Values(?,?)
- parameter dataArray: This is array of arrays with values for the query to be    executed in transcation
- return completion: This is completion handler which will return true for the Successful execution

```swift
let threeDoubles = Array(repeating: dataArray, count: 1000)

DatabaseSingleton.transactionWithParameters(query: string, dataArray: threeDoubles as [[AnyObject]]) { (result) in
if result == true{
print("transaction successful")
// transcation executed successfully
}
}
```
For FTS tables methods with same code flow are implemented in sample code above you can explore them feel free to let us know the issues and contributing as well. 

## Built With

* [Swift 3](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/index.html#//apple_ref/doc/uid/TP40014097-CH3-ID0) - Swift language used
* [Sqlite 3](https://www.sqlite.org/fts3.html) - sqlite FTS concepts are used

## Authors

* **Kunal Darje** - *Initial work* - [DatabseSwiftWrap](https://github.com/kunalone/DatabseSwiftWrap)


## License

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.



