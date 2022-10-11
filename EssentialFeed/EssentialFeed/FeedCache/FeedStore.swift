//
//  FeedStore.swift
//  FeedLoader
//
//  Created by AmritPandey on 07/06/22.
//

import Foundation

public typealias CacheFeed  = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
    typealias RetrievalResult = Result<CacheFeed?, Error>
    
    typealias CompletionResult = Result<Void, Error>
    typealias Completion = (CompletionResult) -> Void
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    /// The Completion Handler can be invoked in any thread
    /// Client are responsible to dispatchto appropriate thread. if needed
    func retrieve(completion: @escaping RetrievalCompletion)
    
    /// The Completion Handler can be invoked in any thread
    /// Client are responsible to dispatchto appropriate thread. if needed
    func deleteCache(completion: @escaping Completion)
    
    /// The Completion Handler can be invoked in any thread
    /// Client are responsible to dispatchto appropriate thread. if needed
    func insertCache(with items: [LocalFeedImage], timestamp: Date, completion: @escaping Completion)
}

