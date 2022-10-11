//
//  LocalFeedLoader.swift
//  FeedLoader
//
//  Created by AmritPandey on 14/04/22.
//

import Foundation

public final class LocalFeedLoader {

    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
}
 
extension LocalFeedLoader: FeedLoader {
    public typealias LoadResult = FeedLoader.Result
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(.some(cache)) where FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                completion(.success(cache.feed.toModels()))
                
            case let .failure(error):
                completion(.failure(error))
            case .success:
                completion(.success([]))
            }
        }
    }
}
 
extension LocalFeedLoader {
    func validate() {
        store.retrieve{ [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                self.store.deleteCache {_ in }
            case let .success(.some(cache)) where !FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                self.store.deleteCache {_ in }
            case .success:
                break
            }
        }
        
    }
}

extension LocalFeedLoader: FeedCache     {
    public typealias SaveResult = FeedCache.SaveResult
    
    public func save(_ items: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCache { [weak self] deletionResult in
            guard let self = self else { return }
            switch deletionResult {
            case .success:
                self.cacheItem(items, with: completion)
            case let .failure(error):
                completion(.failure(error))
            }
            
        }
    }
    
    private func cacheItem(_ items: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insertCache(with: items.toLocal(), timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
    
    
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map {
            LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageUrl: $0.url)
        }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map {
            FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
        }
    }
}

