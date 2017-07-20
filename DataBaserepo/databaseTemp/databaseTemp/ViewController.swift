//
//  ViewController.swift
//  databaseTemp
//
//  Created by webwerks on 18/04/17.
//  Copyright © 2017 webwerks. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        trayingAllDatabse()
        saveData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    //let aStr = String(format: "%@%x", "timeNow in hex: ", timeNow)

    func saveData () {
        let emptyArray:[AnyObject] = []
        for index in 0 ... 10 {
            let strName = String(format:"Kunal%d",index)
            let result = DatabaseSingleton.executeUpdate(queryString: "INSERT INTO StudentInfo Values('\(strName)','Pune','314')", parameters: emptyArray)
            if result == true{
                //executed successflly
            }
        }
        let result = DatabaseSingleton.executeUpdate(queryString: "INSERT INTO StudentInfo Values('Kunal iOS abcd a ddfdf asdf asdf Developer sdf sdf','Pune','314')", parameters: emptyArray)
        if result == true{
            //executed successflly
        }

        
        let dataArray = ["Kunal", "Pune", "314"]
        
        let string = "INSERT INTO StudentInfo Values(?,?,?)"
        
        let threeDoubles = Array(repeating: dataArray, count: 1000)

        
        DatabaseSingleton.transactionWithParametersFTS4(query: string, dataArray: threeDoubles as [[AnyObject]]) { (result) in
            if result == true{
                print("transaction successful")
                // transcation executed successfully
            }
        }

        let theData = DatabaseSingleton.executeQueryForFTS4(queryString: "SELECT * FROM StudentInfo WHERE StudentInfo MATCH 'Kunal'")
        
        print(theData)
        
        let theData1 = DatabaseSingleton.executeQueryForFTS4(queryString: "SELECT * FROM StudentInfo")
        print(theData1)

        
        //SELECT * FROM docs WHERE body MATCH 'title: ^lin*';
        
        //Search : -- All StudentInfo begins with "Kun".

        let theData3 = DatabaseSingleton.executeQueryForFTS4(queryString: "SELECT * FROM StudentInfo WHERE StudentInfo MATCH '^Kun*'")
        print(theData3)
        
        //Search(Phrase queries) : -- All StudentInfo in column "address" begins with "Pune".

        let theData4 = DatabaseSingleton.executeQueryForFTS4(queryString: "SELECT * FROM StudentInfo WHERE address MATCH 'address: ^Pune'")
        print(theData4)

        //Search : All StudentInfo that contain the phrase "iOS Developer".
        let theData5 = DatabaseSingleton.executeQueryForFTS4(queryString: "SELECT * FROM StudentInfo WHERE StudentInfo MATCH '\"iOS Developer\"'")
        print(theData5)

        /*-- Search for a StudentInfo that contains the terms "ios" and "Developer" with
         -- not more than 6 intervening terms. This also matches the only document in
         table StudentInfo.
         */

        let theData6 = DatabaseSingleton.executeQueryForFTS4(queryString: "SELECT * FROM StudentInfo WHERE StudentInfo MATCH 'ios NEAR/7 Developer'")
        print(theData6)
        


    }
    
    func trayingAllDatabse(){
        let emptyArray:[AnyObject] = []
        
        // If this flag is false wont print query errors on the log
        DatabaseSingleton.enableLog = true
        
        let result = DatabaseSingleton.executeUpdate(queryString: "INSERT INTO Student Values('Kunal','Pune','314')", parameters: emptyArray)
        
        if result == true{
            //executed successflly
        }
        
        let updateQuery:String = "UPDATE Student SET name = ? Where address = ?"
        
        let updateResult = DatabaseSingleton.executeUpdate(queryString: updateQuery, parameters: ["One" as AnyObject,"pune" as AnyObject])
        
        if updateResult == true {
            //executed successflly
        }
        
        let theData = DatabaseSingleton.executeQuery(queryString: "SELECT * FROM Student")
        
        print(theData)
        
        let dataArray = ["Kunal", "Pune", "314"]
        
        let string = "INSERT INTO Student Values('?','?','?')"
        
        let threeDoubles = Array(repeating: dataArray, count: 1000)
        
        DatabaseSingleton.transactionWithParameters(query: string, dataArray: threeDoubles as [[AnyObject]]) { (result) in
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

