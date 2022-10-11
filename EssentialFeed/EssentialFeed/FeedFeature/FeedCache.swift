//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by AmritPandey on 11/10/22.
//

import Foundation

public protocol FeedCache {
    typealias SaveResult = Result<Void, Error>
    func save(_ items: [FeedImage], completion: @escaping (SaveResult) -> Void)
}
