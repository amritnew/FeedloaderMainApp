//
//  FeedPresenterAdapter.swift
//  EssentialFeediOS
//
//  Created by AmritPandey on 29/07/22.
//

import EssentialFeed
import EssentialFeediOS

public final class FeedPresenterAdapter: FeedRefreshViewControllerDelegate  {
    private let feedLoader: FeedLoader
    var presenter: FeedPresenter?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    public func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        feedLoader.load{ [weak self] result in
            switch result {
            case let .success(feeds):
                self?.presenter?.didFinishLoadingFeed(with: feeds)
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}
