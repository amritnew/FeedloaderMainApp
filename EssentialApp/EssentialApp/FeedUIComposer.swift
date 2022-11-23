//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by AmritPandey on 19/07/22.
//

import Foundation
import EssentialFeed
import EssentialFeediOS
import UIKit

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: @escaping () -> FeedLoader.Publisher, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presentationAdapter = FeedPresenterAdapter(feedLoader: { feedLoader().dispatchOnMainQueue() })
        
        let feedViewController = FeedViewController.makeWith(delegate: presentationAdapter, title: FeedPresenter.title)
        
        let feedViewAdapter = FeedViewAdapter(
            feedViewController: feedViewController,
            imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader))
        presentationAdapter.presenter = FeedPresenter(feedView: feedViewAdapter,
            loadingView: WeakRefVirtualProxy(feedViewController),
            errorView: WeakRefVirtualProxy(feedViewController))
                                                      
        return feedViewController
    }
}

private extension FeedViewController {
    static func makeWith(delegate: FeedRefreshViewControllerDelegate, title: String) -> FeedViewController {
        let storyboard = UIStoryboard(name: "Feed", bundle: Bundle(for: FeedViewController.self))
        let feedViewController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedViewController.delegate = delegate
        feedViewController.title = FeedPresenter.title
        return feedViewController
    }
}


