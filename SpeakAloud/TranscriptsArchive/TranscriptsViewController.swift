//
//  ViewController.swift
//  SpeakAloud
//
//  Created by SeoGiwon on 17/10/2018.
//  Copyright © 2018 SeoGiwon. All rights reserved.
//

import UIKit
import CoreData

class TranscriptsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var transcripts: [Transcript]?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transcripts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TranscriptCell", for: indexPath)
        
        if let transcripts = transcripts,
            let titleLabel = cell.viewWithTag(10) as? UILabel {
            
            titleLabel.text = transcripts[indexPath.row].text
        }
        
        return cell
    }
}

