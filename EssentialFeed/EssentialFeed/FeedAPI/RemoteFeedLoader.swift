//
//  RemoteFeedLoader.swift
//  FeedLoader
//
//  Created by AmritPandey on 14/04/22.
//

import Foundation

public typealias RemoteFeedLoader = RemoteLoader<[FeedImage]>

extension RemoteFeedLoader {
    public convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: FeedItemsMapper.map)
    }
}


