//
//  FeedViewModel.swift
//  EssentialFeed
//
//  Created by AmritPandey on 12/09/22.
//

import Foundation

public struct FeedViewModel {
    public let feeds: [FeedImage]
}

public protocol FeedView {
    func display(viewModel: FeedViewModel)
}
