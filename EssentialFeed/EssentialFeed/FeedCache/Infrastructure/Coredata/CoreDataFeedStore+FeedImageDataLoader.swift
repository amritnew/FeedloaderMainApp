//
//  CoreDataFeedStore+FeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by AmritPandey on 19/09/22.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
    
    public func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        perform { context in
            completion(Result {
                try ManagedFeedImage.first(with: url, in: context)
                    .map {$0.data = data}
                    .map(context.save)
            })
        }
    }
    
    public func retrieve(dataForURL url: URL, completion: @escaping (RetreivalResult) -> Void) {
        perform { context in
            completion(Result {
                try ManagedFeedImage.first(with: url, in: context)?.data
            })
}
    }
    
    
    
}
