//
//  FeedLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by AmritPandey on 22/09/22.
//

import Foundation
import EssentialFeed

public final class FeedLoaderWithFallbackComposite: FeedLoader {
    let primaryLoader: FeedLoader
    let fallbackLoader: FeedLoader
    
    public init(primary: FeedLoader, fallback: FeedLoader) {
        primaryLoader = primary
        fallbackLoader = fallback
    }
    
    public func load(completion: @escaping ((FeedLoader.Result) -> Void)) {
        primaryLoader.load { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                self?.fallbackLoader.load(completion: completion)
            }
        }
    }
}
