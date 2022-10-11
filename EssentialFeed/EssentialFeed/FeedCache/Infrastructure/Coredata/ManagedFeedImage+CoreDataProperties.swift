//
//  ManagedFeedImage+CoreDataProperties.swift
//  FeedLoader
//
//  Created by AmritPandey on 22/06/22.
//
//

import Foundation
import CoreData


extension ManagedFeedImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedFeedImage> {
        return NSFetchRequest<ManagedFeedImage>(entityName: "ManagedFeedImage")
    }

    @NSManaged public var id: UUID
    @NSManaged public var url: URL
    @NSManaged public var location: String?
    @NSManaged public var imageDescription: String?
    @NSManaged public var cache: ManagedCache?
    @NSManaged public var data: Data?

    var local: LocalFeedImage {
        return LocalFeedImage(id: id, description: imageDescription, location: location, imageUrl: url)
    }
    
    static func managedFeedImages(localFeeds: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet(array: localFeeds.map { local in
            let managedFeedImage = ManagedFeedImage(context: context)
            managedFeedImage.id = local.id
            managedFeedImage.location = local.location
            managedFeedImage.imageDescription = local.description
            managedFeedImage.url = local.url
            return managedFeedImage
        })
    }
}

extension ManagedFeedImage {
    static func first(with url: URL, in context: NSManagedObjectContext) throws -> ManagedFeedImage? {
            let request = NSFetchRequest<ManagedFeedImage>(entityName: entity().name!)
            request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(ManagedFeedImage.url), url])
            request.returnsObjectsAsFaults = false
            request.fetchLimit = 1
            return try context.fetch(request).first
        }

        static func images(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
            return NSOrderedSet(array: localFeed.map { local in
                let managed = ManagedFeedImage(context: context)
                managed.id = local.id
                managed.imageDescription = local.description
                managed.location = local.location
                managed.url = local.url
                return managed
            })
        }
        
}
