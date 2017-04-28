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
        
        let emptyArray:[AnyObject] = []
        
        // If this flag is false wont print query errors on the log
        DatabaseSingleton.sharedInstance.enableLog = true
        
        let result = DatabaseSingleton.sharedInstance.executeUpdate(queryString: "INSERT INTO Student Values('Kunal','Pune','314')", parameters: emptyArray)
        
        if result == true{
            //executed successflly
        }
        
        let updateQuery:String = "UPDATE Student SET name = ? Where address = ?"
        
        let updateResult = DatabaseSingleton.sharedInstance.executeUpdate(queryString: updateQuery, parameters: ["One" as AnyObject,"pune" as AnyObject])
        
        if updateResult == true {
            //executed successflly
        }
        
        let theData = DatabaseSingleton.sharedInstance.executeQuery(queryString: "SELECT * FROM Student")
        
        print(theData)
        
        let dataArray = ["Kunal", "Pune", "314"]
        
        let string = "INSERT INTO Student Values('?','?','?')"
        
        let threeDoubles = Array(repeating: dataArray, count: 1000)
        
        DatabaseSingleton.sharedInstance.transactionWithParameters(query: string, dataArray: threeDoubles as [[AnyObject]]) { (result) in
            if result == true{
                print("transaction successful")
                // transcation executed successfully
            }
        }
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

