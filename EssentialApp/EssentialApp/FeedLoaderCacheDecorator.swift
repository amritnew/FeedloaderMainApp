//
//  FeedLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by AmritPandey on 11/10/22.
//

import EssentialFeed

public class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    private let cache: FeedCache
    
    public init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(completion: @escaping ((FeedLoader.Result) -> Void)) {
        decoratee.load { [weak self] result in
            completion(result.map({ feeds in
                self?.cache.saveIgnoringResult(feeds)
                return feeds
            }))
        }
        
    }
}

private extension FeedCache {
    func saveIgnoringResult(_ feed: [FeedImage]) {
        save(feed) { _ in }
    }
}

