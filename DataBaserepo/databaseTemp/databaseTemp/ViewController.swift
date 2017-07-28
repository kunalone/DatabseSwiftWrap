

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //Mothods creating FTS and non FTS tables and manuplating them are impelmented in functiond given.
        
        // MARK: Demo databse table is empty. Developers can just start uncommenting the mothod calls
        //databaseMethods()
        //databaseMethodsFTS()
    }
    
// MARK: All the FTS databse methods examples
    func databaseMethodsFTS() {
        let emptyArray:[AnyObject] = []
        for index in 0 ... 10 {
            let strName = String(format:"Kunal%d",index)
            let result = DatabaseHandler.executeUpdate(queryString: "INSERT INTO StudentInfo Values('\(strName)','Pune','314')", parameters: emptyArray)
            if result == true{
                //executed successflly
            }
        }
        let result = DatabaseHandler.executeUpdate(queryString: "INSERT INTO StudentInfo Values('Kunal iOS abcd a ddfdf asdf asdf Developer sdf sdf','Pune','314')", parameters: emptyArray)
        if result == true{
            //executed successflly
        }

        
        let dataArray = ["Kunal", "Pune", "314"]
        
        let string = "INSERT INTO StudentInfo Values(?,?,?)"
        
        let threeDoubles = Array(repeating: dataArray, count: 1000)

        
        DatabaseHandler.transactionWithParametersFTS4(query: string, dataArray: threeDoubles as [[AnyObject]]) { (result) in
            if result == true{
                print("transaction successful")
                // transcation executed successfully
            }
        }

        let theData = DatabaseHandler.executeQueryForFTS4(queryString: "SELECT * FROM StudentInfo WHERE StudentInfo MATCH 'Kunal'")
        
        print(theData)
        
        let theData1 = DatabaseHandler.executeQueryForFTS4(queryString: "SELECT * FROM StudentInfo")
        print(theData1)

        
        //SELECT * FROM docs WHERE body MATCH 'title: ^lin*';
        
        //Search : -- All StudentInfo begins with "Kun".

        let theData3 = DatabaseHandler.executeQueryForFTS4(queryString: "SELECT * FROM StudentInfo WHERE StudentInfo MATCH '^Kun*'")
        print(theData3)
        
        //Search(Phrase queries) : -- All StudentInfo in column "address" begins with "Pune".

        let theData4 = DatabaseHandler.executeQueryForFTS4(queryString: "SELECT * FROM StudentInfo WHERE address MATCH 'address: ^Pune'")
        print(theData4)

        //Search : All StudentInfo that contain the phrase "iOS Developer".
        let theData5 = DatabaseHandler.executeQueryForFTS4(queryString: "SELECT * FROM StudentInfo WHERE StudentInfo MATCH '\"iOS Developer\"'")
        print(theData5)

        /*-- Search for a StudentInfo that contains the terms "ios" and "Developer" with
         -- not more than 6 intervening terms. This also matches the only document in
         table StudentInfo.
         */

        let theData6 = DatabaseHandler.executeQueryForFTS4(queryString: "SELECT * FROM StudentInfo WHERE StudentInfo MATCH 'ios NEAR/7 Developer'")
        print(theData6)
        
        
        // MARK: Databse migration method
        // Method below can be user to convert the normal tables to FTS tables 
       /* DatabaseHandler.MigrateTableToFTS4String(tableName: "Student") { (result) in
            if result == true{
                print("migration working ")
            }
            else{
                print("Migration failed")
            }
        }*/


    }
    // MARK: All the normal databse methods examples
    func databaseMethods(){
        let emptyArray:[AnyObject] = []
        
        // If this flag is false wont print query errors on the log
        DatabaseHandler.enableLog = true
        
        let result = DatabaseHandler.executeUpdate(queryString: "INSERT INTO Student Values('Kunal','Pune','314')", parameters: emptyArray)
        
        if result == true{
            //executed successflly
        }
        
        let updateQuery:String = "UPDATE Student SET name = ? Where address = ?"
        
        let updateResult = DatabaseHandler.executeUpdate(queryString: updateQuery, parameters: ["One" as AnyObject,"pune" as AnyObject])
        
        if updateResult == true {
            //executed successflly
        }
        
        let theData = DatabaseHandler.executeQuery(queryString: "SELECT * FROM Student")
        
        print(theData)
        
        let dataArray = ["Kunal", "Pune", "314"]
        
        let string = "INSERT INTO Student Values(?,?,?)"
        
        let threeDoubles = Array(repeating: dataArray, count: 1000)
        
        DatabaseHandler.transactionWithParameters(query: string, dataArray: threeDoubles as [[AnyObject]]) { (result) in
            if result == true{
                print("transaction successful")
                // transcation executed successfully
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

