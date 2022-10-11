//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by AmritPandey on 12/09/22.
//

import Foundation

public final class FeedPresenter {
    private let errorView: FeedErrorView
    private let loadingView: FeedLoadingView
    private let feedView: FeedView
    private var feedLoaderError: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR", tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    public static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE", tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Feed view title")
    }
    
    public init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.feedView = feedView
        self.errorView = errorView
        self.loadingView = loadingView
    }
    
    public func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingFeed(with feeds: [FeedImage]) {
        feedView.display(viewModel: FeedViewModel(feeds: feeds))
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with error: Error) {
        errorView.display(.error(message: feedLoaderError))
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
    
}
