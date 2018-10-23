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

        // Do any additional setup after loading the view.
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                print(error)
            } else if let recordID = recordID {
                print(recordID)
            }
        }
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
