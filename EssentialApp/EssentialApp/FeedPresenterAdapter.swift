//
//  FeedPresenterAdapter.swift
//  EssentialFeediOS
//
//  Created by AmritPandey on 29/07/22.
//

import EssentialFeed
import EssentialFeediOS
import Combine

public final class FeedPresenterAdapter: FeedRefreshViewControllerDelegate  {
    private let feedLoader: () -> FeedLoader.Publisher
    private var cancellable: Cancellable?
    var presenter: FeedPresenter?
    
    init(feedLoader: @escaping () -> FeedLoader.Publisher) {
        self.feedLoader = feedLoader
    }
    
    public func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        cancellable = feedLoader().sink { [weak self] completion in
            switch completion {
            case .finished: break
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
        } receiveValue: { [weak self] feeds in
            self?.presenter?.didFinishLoadingFeed(with: feeds)
        }
    }
}
