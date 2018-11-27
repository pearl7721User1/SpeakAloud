//
//  Transcript+CoreDataProperties.swift
//  SpeakAloud
//
//  Created by SeoGiwon on 24/11/2018.
//  Copyright © 2018 SeoGiwon. All rights reserved.
//
//

import Foundation
import CoreData


extension Transcript {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transcript> {
        return NSFetchRequest<Transcript>(entityName: "Transcript")
    }

    @NSManaged public var languageCode: String?
    @NSManaged public var text: String?
    @NSManaged public var timeStamp: NSDate?
    @NSManaged public var contributes: TranscriptsAtTheTime?

}
