//
//  ImageCommentMapper.swift
//  EssentialFeed
//
//  Created by AmritPandey on 10/01/23.
//

import Foundation

class ImageCommentMapper {
    private struct Root: Decodable {
        private let items: [Item]
                
        private struct Item: Decodable {
            let id: UUID
            let message: String
            let created_At: Date
            let author: ItemAuthor
        }
        
        private struct ItemAuthor: Decodable {
            let username: String
        }
        
        var comments: [ImageComment] {
            items.map {ImageComment(id: $0.id, message: $0.message, createdAt: $0.created_At, author: CommentAuthorObject(username: $0.author.username))}
        }
    }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws  -> [ImageComment] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard response.isOK,
                let root = try? decoder.decode(Root.self, from: data) else {
            throw RemoteImageCommentLoader.Error.invalidData
        }
        return root.comments
    }
}
