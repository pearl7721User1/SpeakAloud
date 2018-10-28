//
//  cloudKitViewController.swift
//  SpeakAloud
//
//  Created by GIWON1 on 2018. 10. 22..
//  Copyright © 2018년 SeoGiwon. All rights reserved.
//

import UIKit
import CloudKit

class CloudKitViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Fetch Public Database
        let publicDatabase = CKContainer.default().publicCloudDatabase
        
        // Initialize Query
        let query = CKQuery(recordType: "MemorizingMaterial", predicate: NSPredicate(value: true))
        
        // Configure Query
//        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        // Perform Query
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            records?.forEach({ (record) in
                
                guard error == nil else{
                    print(error?.localizedDescription as Any)
                    return
                }
                
                print(record.value(forKey: "name") ?? "")
                /*
                self.lists.append(record)
                DispatchQueue.main.sync {
                    self.tableView.reloadData()
                    self.messageLabel.text = ""
                    updateView()
                }
 */
            })
            
        }
        
        
    }
    
    
    @IBAction func closeBtnTapped(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
