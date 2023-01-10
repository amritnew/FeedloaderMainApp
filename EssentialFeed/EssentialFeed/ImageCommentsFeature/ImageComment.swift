//
//  ImageComment.swift
//  EssentialFeed
//
//  Created by AmritPandey on 10/01/23.
//

import Foundation

public struct ImageComment: Equatable, Decodable {
    let id: UUID
    let message: String
    let createdAt: Date
    let author: CommentAuthorObject
    
    public init(id: UUID, message: String, createdAt: Date, author: CommentAuthorObject) {
        self.id = id
        self.message = message
        self.createdAt = createdAt
        self.author = author
    }
}

public struct CommentAuthorObject: Equatable, Decodable {
    public let username: String
    
    public init(username: String) {
        self.username = username
    }
}
