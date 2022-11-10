//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by AmritPandey on 28/07/22.
//

import UIKit
import EssentialFeediOS

extension FeedViewController {
    func simulatedUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func isShowingLoadingIndicator() -> Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        return tableView.numberOfRows(inSection: feedImageSection)
    }
    
    private var feedImageSection: Int {
        return 0
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        guard numberOfRenderedFeedImageViews() > row else {
            return nil
        }
        let d = tableView.dataSource
        let index = IndexPath(row: row, section: feedImageSection)
        return d?.tableView(tableView, cellForRowAt: index)
    }
    
    var errorMessage: String? {
        return errorView?.message
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at row: Int) -> FeedImageCell? {
        return feedImageView(at: row) as? FeedImageCell
    }
    
    @discardableResult
    func simulateFeedImageViewNotVisible(at row: Int) -> FeedImageCell? {
        let view = simulateFeedImageViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImageSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
        return view
    }
    
    func simulateFeedImageViewNearVisible(at row: Int = 0)  {
        let d = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImageSection)
        d?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateFeedImageViewNotNearVisible(at row: Int = 0) {
        simulateFeedImageViewVisible(at: row)
        
        let d = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImageSection)
        d?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
    
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func renderedFeedImageData(at index: Int) -> Data? {
        return simulateFeedImageViewVisible(at: index)?.renderedImage
    }
    
}
