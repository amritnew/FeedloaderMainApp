//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by AmritPandey on 29/07/22.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapter: FeedView {
    private weak var feedViewController:FeedViewController?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    
    init(feedViewController:FeedViewController, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.feedViewController = feedViewController
        self.imageLoader = imageLoader
    }
    
    func display(viewModel: FeedViewModel) {
        feedViewController?.display( viewModel.feeds.map { feed in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: feed, imageLoader: imageLoader)
            let view = FeedImageCellController(delegate: adapter)
            adapter.presenter = FeedImagePresenter(feedImage: WeakRefVirtualProxy(view), imageTranformer: UIImage.init)
            return view
        })
    }
}
