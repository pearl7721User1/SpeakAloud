//
//  TranscriptsAtTheTime+CoreDataProperties.swift
//  SpeakAloud
//
//  Created by SeoGiwon on 24/11/2018.
//  Copyright © 2018 SeoGiwon. All rights reserved.
//
//

import Foundation
import CoreData


extension TranscriptsAtTheTime {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TranscriptsAtTheTime> {
        return NSFetchRequest<TranscriptsAtTheTime>(entityName: "TranscriptsAtTheTime")
    }

    @NSManaged public var commonWords: String?
    @NSManaged public var count: Int16
    @NSManaged public var endTime: NSDate?
    @NSManaged public var memo: String?
    @NSManaged public var startTime: NSDate?
    @NSManaged public var isMadeOf: NSOrderedSet?

}

// MARK: Generated accessors for isMadeOf
extension TranscriptsAtTheTime {

    @objc(insertObject:inIsMadeOfAtIndex:)
    @NSManaged public func insertIntoIsMadeOf(_ value: Transcript, at idx: Int)

    @objc(removeObjectFromIsMadeOfAtIndex:)
    @NSManaged public func removeFromIsMadeOf(at idx: Int)

    @objc(insertIsMadeOf:atIndexes:)
    @NSManaged public func insertIntoIsMadeOf(_ values: [Transcript], at indexes: NSIndexSet)

    @objc(removeIsMadeOfAtIndexes:)
    @NSManaged public func removeFromIsMadeOf(at indexes: NSIndexSet)

    @objc(replaceObjectInIsMadeOfAtIndex:withObject:)
    @NSManaged public func replaceIsMadeOf(at idx: Int, with value: Transcript)

    @objc(replaceIsMadeOfAtIndexes:withIsMadeOf:)
    @NSManaged public func replaceIsMadeOf(at indexes: NSIndexSet, with values: [Transcript])

    @objc(addIsMadeOfObject:)
    @NSManaged public func addToIsMadeOf(_ value: Transcript)

    @objc(removeIsMadeOfObject:)
    @NSManaged public func removeFromIsMadeOf(_ value: Transcript)

    @objc(addIsMadeOf:)
    @NSManaged public func addToIsMadeOf(_ values: NSOrderedSet)

    @objc(removeIsMadeOf:)
    @NSManaged public func removeFromIsMadeOf(_ values: NSOrderedSet)

}
