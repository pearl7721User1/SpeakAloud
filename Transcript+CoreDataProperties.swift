//
//  Transcript+CoreDataProperties.swift
//  SpeakAloud
//
//  Created by GIWON1 on 2018. 10. 23..
//  Copyright © 2018년 SeoGiwon. All rights reserved.
//
//

import Foundation
import CoreData


extension Transcript {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transcript> {
        return NSFetchRequest<Transcript>(entityName: "Transcript")
    }

    @NSManaged public var text: String?
    @NSManaged public var timeStamp: NSDate?
    @NSManaged public var languageCode: String?
    @NSManaged public var contributes: TranscriptsAtTheTime?

}
