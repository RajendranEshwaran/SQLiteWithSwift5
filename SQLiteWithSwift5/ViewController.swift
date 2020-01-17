//
//  ViewController.swift
//  SQLiteWithSwift5
//
//  Created by gomathi saminathan on 1/15/20.
//  Copyright © 2020 Rajendran Eshwaran. All rights reserved.
//

import UIKit
import SQLite3

class ViewController: UIViewController {

    var db : OpaquePointer?
    var name : String?
    var powerrank : Int32?
    var heroList = [Hero]()
    var selectedIndex : Int?
    
    @IBOutlet weak var heroTable : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
// Create a DB file in file manager
        do{
            let fileUrl = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("HeroDB.sqlite")
            
            print(fileUrl)
// Open the DB file
            if sqlite3_open(fileUrl.path, &db) != SQLITE_OK
            {
                print("Erro in file open")
                return
            }
        }
        catch{
            print("Erro in file create")
            return
        }
// Initialy shows the values from sqlite file ( Heros.table)
        showValues()
    }

    @IBAction func createTable(sender : UIButton)
    {
        createTable()
    }
    
    @IBAction func insertValue(sender : UIButton)
    {
        insertValueIntoTable()
    }
    @IBAction func deleteValue(sender : UIButton)
    {
        guard let index = selectedIndex else{print("No Items Selected "); return}
        deleteItemFromList(itemId: Int32(index))
        
    }
    @IBAction func showValue(sender : UIButton)
    {
        showValues()
    }
    
// MARK: Create Operation
    func createTable()
    {
       
            
            let creatTableQuery = "CREATE TABLE IF NOT EXISTS Heros (id INTEGER PRIMARY KEY AUTOINCREMENT , name TEXT , powerrank INTEGER)"
        
            if sqlite3_exec(db, creatTableQuery, nil, nil, nil) != SQLITE_OK
            {
               let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error creating table: \(errmsg)")
                return
            }
    
        print("Table Created Successfully")
    }
    
// MARK: Insert Operation
    
    func insertValue()
    {
        var stmt : OpaquePointer?
        
        // Create insertion query
        let insertQuery = "INSERT INTO Heros(name ,powerrank) VALUES (?,?)"
       
        // Prepare the statement with query
           if sqlite3_prepare(self.db, insertQuery, -1, &stmt, nil) != SQLITE_OK{
               print("Error binding in query")
           }
        // Bind the text value
           if sqlite3_bind_text(stmt, 1, self.name, -1, nil) != SQLITE_OK
           {
               print("Error in binding name value")
           }
        // Bind the integer value
           if sqlite3_bind_int(stmt, 2, self.powerrank ?? 1 ) != SQLITE_OK{
               print("Error in binding rank value")
           }
        // Execute the statement
            if  sqlite3_step(stmt) == SQLITE_DONE
            {
               print("SuperHero Data Saved Successfully")
           }
         showValues()
    }
    
// MARK: Insert Input Operation
    
    func insertValueIntoTable()
    {
       // Alertview controller init
        
        let alert = UIAlertController.init(title: "SuperHeroData", message: "Enter Your SuperHero's", preferredStyle:  .alert)
        
        // Add input textfields on the alertview controller
        alert.addTextField { nameField in
            nameField.font = .systemFont(ofSize: 17.0)
            nameField.placeholder = "Enter SuperHero Name"
        }
        alert.addTextField { rankField in
            rankField.font = .systemFont(ofSize: 17.0)
            rankField.isSecureTextEntry = true
            rankField.placeholder = "Enter SuperHero Rank"
        }
        
        // Create Cancel alert action on alertview
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .destructive,
                                         handler: { _ in
                                            // self.handleUsernamePasswordCanceled(loginAlert: loginAlert)
        })
        alert.addAction(cancelAction)
        
        // Create OK alert action on alertview
        let addAction = UIAlertAction(title: "Add",
                                        style: .default,
                                        handler: { _ in
                                            
                                    if let textField = alert.textFields?[0] {
                                        if textField.text!.count > 0 {
                                            print("Text :: \(textField.text ?? "")")
                                            self.name = textField.text
                                        }
                                    }
                                            
                                    if let textField = alert.textFields?[1] {
                                        if textField.text!.count > 0 {
                                            print("Text :: \(textField.text ?? "")")
                                            self.powerrank = (textField.text as NSString?)?.intValue
                                        }
                                    }
           // Insert values query call
                  self.insertValue()
        })
        
        alert.addAction(addAction)
        alert.preferredAction = addAction
        present(alert, animated: true, completion: nil)
    }
    
  // MARK: Show Operation
    
    func showValues()
    {
        //first empty the list of heroes
        heroList.removeAll()
        
        //select query
        let queryString = "SELECT * FROM Heros"
        
        //statement pointer
        var stmt:OpaquePointer?
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //traversing through all the records
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let name = String(cString: sqlite3_column_text(stmt, 1))
            let powerrank = sqlite3_column_int(stmt, 2)
            
            //adding values to list
            heroList.append(Hero(id: Int(id), name: String(describing: name), powerRanking: Int(powerrank)))
            
            for element in heroList
            {
                print(element.id)
                print(element.name ?? "")
                print(element.powerRanking)
            }
            
            self.heroTable.reloadData()
        }
    }
    
   //MARK: Delete Operation
    
    func deleteItemFromList(itemId: Int32){

        let deleteStatementStirng = "DELETE FROM Heros WHERE id = ?;"
        var deleteStatement: OpaquePointer?

        if sqlite3_prepare(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {

            sqlite3_bind_int(deleteStatement, 1, itemId)

            print("item id: \(itemId)")
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }

        sqlite3_finalize(deleteStatement)
        print("delete")
        self.heroTable.reloadData()
    }
}

extension ViewController : UITableViewDelegate , UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        heroList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        var label : UILabel
        label = cell.viewWithTag(1) as! UILabel
        label.text = "SuperHero ID: " + (heroList[indexPath.row].id as NSNumber).stringValue
        
        label = cell.viewWithTag(2) as! UILabel
        label.text = "SuperHero Name: \( heroList[indexPath.row].name ?? "")"
            
        label = cell.viewWithTag(3) as! UILabel
        label.text = "SuperHero Rank: " + (heroList[indexPath.row].powerRanking as NSNumber).stringValue
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectedIndex = indexPath.row
        print("selectedIndex:\(self.selectedIndex ?? 0)")
    }
    
}
