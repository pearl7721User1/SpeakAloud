//
//  TranscriptsArchiveViewController.swift
//  SpeakAloud
//
//  Created by GIWON1 on 2018. 10. 23..
//  Copyright © 2018년 SeoGiwon. All rights reserved.
//

import UIKit
import CoreData

class TranscriptsArchiveViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var managedContext: NSManagedObjectContext?
    var fetchRequest: NSFetchRequest<TranscriptsAtTheTime>?
    var fetchResults: [TranscriptsAtTheTime] = [TranscriptsAtTheTime]()
    
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let managedContext = managedContext, let fetchRequest = fetchRequest,
            let results = try? managedContext.fetch(fetchRequest) {

            fetchResults = results
        }
    }
    
    @IBAction func closeBtnTapped(_ sender: UIBarButtonItem) {
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TranscriptsArchiveCell", for: indexPath)
        
        if let titleLabel = cell.viewWithTag(10) as? UILabel {
            
            
//            titleLabel.text = fetchResults[indexPath.row].endTime
        }
        
        if let countLabel = cell.viewWithTag(11) as? UILabel {
            
            countLabel.text = "\(fetchResults[indexPath.row].count)"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "TranscriptsViewController") as? TranscriptsViewController {
            
            if let transcripts = fetchResults[indexPath.row].isMadeOf {
                
                vc.transcripts = transcripts.array as! [Transcript]
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            if let managedContext = managedContext {
                let managedObject = fetchResults[indexPath.row]
                
                // delete from the persistent store
                managedContext.delete(managedObject)
                
                do {
                    try managedContext.save()
                } catch {
                    print("couldn't delete transcriptsAtTheTime")
                    return
                }
                
                // delete from the fetchResults array
                fetchResults.remove(at: indexPath.row)
                
                // delete from the table view
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
            
        }
    }
}
