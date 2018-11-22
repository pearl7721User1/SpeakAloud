//
//  TranscriptsArchiveViewController.swift
//  SpeakAloud
//
//  Created by GIWON1 on 2018. 10. 23..
//  Copyright © 2018년 SeoGiwon. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class TranscriptsArchiveViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var managedContext: NSManagedObjectContext?
    var fetchRequest: NSFetchRequest<TranscriptsAtTheTime>?
    var fetchResults: [TranscriptsAtTheTime] = [TranscriptsAtTheTime]()
    let synthesizer = AVSpeechSynthesizer()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let managedContext = managedContext, let fetchRequest = fetchRequest,
            let results = try? managedContext.fetch(fetchRequest) {
            
            fetchResults = results
        }
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    @IBAction func closeBtnTapped(_ sender: UIBarButtonItem) {
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    
    
    // MARK: - table view
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return fetchResults.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let transcripts = fetchResults[section].isMadeOf {
            return transcripts.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TranscriptsArchiveCell", for: indexPath)
        
        if let textView = cell.viewWithTag(10) as? UITextView {
            
            if let transcripts = fetchResults[indexPath.section].isMadeOf {
                
                let transcriptsArray = transcripts.array as! [Transcript]
                textView.text = transcriptsArray[indexPath.row].text
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let startDate = fetchResults[section].startTime {
            
            let f = DateFormatter()
            f.dateStyle = .medium
            f.timeStyle = .medium
            
            return f.string(from: startDate as Date)
        } else {
            return nil
        }
    }
    
    
    /*
    //////
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "TranscriptsViewController") as? TranscriptsViewController {
            
            if let transcripts = fetchResults[indexPath.row].isMadeOf {
                
                vc.transcripts = transcripts.array as! [Transcript]
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }
        
    }
    */
    /*
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            if let managedContext = managedContext,
                let transcripts = fetchResults[indexPath.section].isMadeOf {
                    
                    let transcriptsArray = transcripts.array as! [Transcript]
                    
                    // delete from the persistent store
                    let transcript = transcriptsArray[indexPath.row]
                    managedContext.delete(transcript)
                
                do {
                    try managedContext.save()
                } catch {
                    print("couldn't delete transcriptsAtTheTime")
                    return
                }
                
                // delete from the fetchResults array
                //fetchResults[indexPath.section].isMadeOf!.inde
                
//                fetchResults.remove(at: indexPath.row)
                
                // delete from the table view
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
 */
        
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
            self.delete(indexPath: indexPath)
            success(true)
        })
        deleteAction.backgroundColor = .red
        
        let editAction = UIContextualAction(style: .normal, title:  "Edit", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
            // enable edit
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TranscriptsArchiveCell", for: indexPath)
            
            if let textView = cell.viewWithTag(10) as? UITextView {
                textView.isEditable = true
                textView.becomeFirstResponder()
            }
            
            success(true)
        })
        editAction.backgroundColor = .gray
        
        let speakAction = UIContextualAction(style: .normal, title:  "Speak", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
            if let transcripts = self.fetchResults[indexPath.section].isMadeOf {
                
                let transcriptsArray = transcripts.array as! [Transcript]
                let transcript = transcriptsArray[indexPath.row]
                self.speak(transcript: transcript)
            }
            
            success(true)
        })
        editAction.backgroundColor = .gray
        
        return UISwipeActionsConfiguration(actions: [editAction, deleteAction])
    }
    
    private func delete(indexPath: IndexPath) {
        
        if let managedContext = managedContext,
            let transcripts = fetchResults[indexPath.section].isMadeOf {
            
            let transcriptsArray = transcripts.array as! [Transcript]
            
            // delete from the persistent store
            let transcript = transcriptsArray[indexPath.row]
            managedContext.delete(transcript)
            
            do {
                try managedContext.save()
            } catch {
                print("couldn't delete transcriptsAtTheTime")
                return
            }
            
            // delete from the fetchResults array
            //fetchResults[indexPath.section].isMadeOf!.inde
            
            //                fetchResults.remove(at: indexPath.row)
            
            // delete from the table view
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
 
    private func speak(transcript: Transcript) {
        
        guard let text = transcript.text,
            let languageCode = transcript.languageCode else {
                return
        }
        
        let utterance = AVSpeechUtterance(string: text)
        let voiceToUse = AVSpeechSynthesisVoice(language: languageCode)
        
        utterance.voice = voiceToUse
        synthesizer.speak(utterance)
    }
 
}
