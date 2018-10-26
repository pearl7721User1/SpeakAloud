//
//  TranscriptsArchiveNavigationViewController.swift
//  SpeakAloud
//
//  Created by GIWON1 on 2018. 10. 26..
//  Copyright © 2018년 SeoGiwon. All rights reserved.
//

import UIKit

class TranscriptsArchiveNavigationController: UINavigationController {

    lazy var transcriptsArchiveViewController: TranscriptsArchiveViewController = {
       
        if let vc = self.viewControllers.first as? TranscriptsArchiveViewController {
            return vc
        } else {
            fatalError()
        }
    }()
    
    

}
