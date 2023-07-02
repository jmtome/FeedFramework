//
//  FeedViewController.swift
//  FeedFrameworkiOS
//
//  Created by macbook on 29/06/2023.
//

import UIKit

public final class FeedViewController: UITableViewController {
    var refreshController: FeedRefreshViewController?
    var tableModel = [FeedImageCellController]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    
//    convenience init(refreshController: FeedRefreshViewController) {
//        self.init()
//        self.refreshController = refreshController
//    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = refreshController?.view
        
        tableView.prefetchDataSource = self
        
        refreshController?.refresh()
    }
}
//MARK: - UITableViewDelegate and UITableViewDatasource Conformance
extension FeedViewController {
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view()
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
}

