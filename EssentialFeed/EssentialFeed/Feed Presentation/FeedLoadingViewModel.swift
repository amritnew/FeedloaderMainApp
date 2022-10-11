//
//  FeedLoadingViewModel.swift
//  EssentialFeed
//
//  Created by AmritPandey on 12/09/22.
//

import Foundation

public struct FeedLoadingViewModel {
    public let isLoading: Bool
}

public protocol FeedLoadingView {
    func display(viewModel: FeedLoadingViewModel)
}
