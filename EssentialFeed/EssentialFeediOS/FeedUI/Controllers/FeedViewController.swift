//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by AmritPandey on 12/07/22.
//

import UIKit
import EssentialFeed

public protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    
    private var loadingControllers = [IndexPath: FeedImageCellController]()
    private var tableModel = [FeedImageCellController]() {
        didSet {tableView.reloadData()}
    }
    
    @IBOutlet var refreshController: UIRefreshControl?
    @IBOutlet private(set) public var errorView: ErrorView?
    
    public var delegate: FeedRefreshViewControllerDelegate?
    
    public override func viewDidLoad() {
        refresh()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.sizeTableHeaderToFit()
    }
    
    public func display(_ cellControllers: [FeedImageCellController]) {
        loadingControllers = [:]
        self.tableModel = cellControllers
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view(in: tableView)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellController(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellController)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        let controller = tableModel[indexPath.row]
        loadingControllers[indexPath] = controller
        return controller
        
    }
    
    private func cancelCellController(forRowAt indexPath: IndexPath) {
        loadingControllers[indexPath]?.cancelLoad()
        loadingControllers[indexPath] = nil
    }
}

//MARK: - Refresh Controller
extension FeedViewController: FeedLoadingView {
        
    @IBAction private func refresh () {
        delegate?.didRequestFeedRefresh()
    }

    public func display(viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            refreshController?.beginRefreshing()
        }
        else {
            refreshController?.endRefreshing()
        }
    }
}

extension FeedViewController: FeedErrorView {
    public func display(_ viewModel: FeedErrorViewModel) {
        errorView?.message = viewModel.message
    }
}


