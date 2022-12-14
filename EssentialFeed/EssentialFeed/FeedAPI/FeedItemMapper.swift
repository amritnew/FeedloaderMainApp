//
//  FeedItemMapper.swift
//  FeedLoader
//
//  Created by AmritPandey on 27/04/22.
//

import Foundation

final class FeedItemsMapper {
    
    private struct Root: Decodable {
        private let items: [RemoteFeedItem]
        
        private struct RemoteFeedItem: Equatable, Decodable {
            let id: UUID
            let description: String?
            let location: String?
            let image: URL
        }
        
        var images: [FeedImage] {
            items.map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image) }
        }
    }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws  -> [FeedImage] {
        guard response.isOK,
                let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.images
    }
}
