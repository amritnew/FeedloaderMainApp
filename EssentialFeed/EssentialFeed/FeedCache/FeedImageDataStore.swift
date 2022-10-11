//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by AmritPandey on 19/09/22.
//

import Foundation

public protocol FeedImageDataStore {
    typealias RetreivalResult = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
    func retrieve(dataForURL url: URL, completion: @escaping (RetreivalResult) -> Void)
}
