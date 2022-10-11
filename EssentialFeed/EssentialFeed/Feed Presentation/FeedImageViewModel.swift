//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by AmritPandey on 13/09/22.
//

import Foundation

public struct FeedImageViewModel<Image> {
    public let isLoading: Bool
    public let shoulretry: Bool
    public let description: String?
    public let location: String?
    public let image: Image?
    
    public var hasLocation: Bool {
        return location != nil
    }
}
