//
//  FeedItemMapper.swift
//  FeedLoader
//
//  Created by AmritPandey on 27/04/22.
//

import Foundation

final class FeedItemsMapper {
    
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws  -> [RemoteFeedItem] {
        guard response.isOK,
                let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }
}
