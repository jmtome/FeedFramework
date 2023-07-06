//
//  FeedViewController.swift
//  FeedFrameworkiOS
//
//  Created by macbook on 29/06/2023.
//

import UIKit
import FeedFramework

public protocol FeedViewControllerDelegate {
    func didRequestFeedRefresh()
}

public final class FeedViewController: UITableViewController {
    @IBOutlet private(set) public var errorView: ErrorView?
    
    private var tableModel = [FeedImageCellController]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    public var delegate: FeedViewControllerDelegate?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.sizeTableHeaderToFit()
    }
    
    public func display(_ cellControllers: [FeedImageCellController]) {
        tableModel = cellControllers
    }
}
//MARK: - UITableViewDelegate and UITableViewDatasource Conformance
extension FeedViewController {
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view(in: tableView)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }
}

//MARK: - UITableViewDataSourcePrefetching Conformance
extension FeedViewController: UITableViewDataSourcePrefetching {
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }
}

//MARK: - Private FeedViewController Methods
extension FeedViewController {
    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        return tableModel[indexPath.row]
    }
    
    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
    }
    @IBAction private func refresh() {
        delegate?.didRequestFeedRefresh()
    }
}

//MARK: - FeedLoadingView Conformance
extension FeedViewController: FeedLoadingView {
    public func display(_ viewModel: FeedLoadingViewModel) {
        refreshControl?.update(isRefreshing: viewModel.isLoading)
    }
}

//MARK: - FeedErrorView Conformance
extension FeedViewController: FeedErrorView {
    public func display(_ viewModel: FeedErrorViewModel) {
        errorView?.message = viewModel.message
    }
}

