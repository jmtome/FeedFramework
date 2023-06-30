//
//  FeedViewController.swift
//  FeedFrameworkiOS
//
//  Created by macbook on 29/06/2023.
//

import UIKit
import FeedFramework


final public class FeedViewController: UITableViewController {
    private var refreshController: FeedRefreshViewController?
    private var imageLoader: FeedImageDataLoader?
    private var tableModel = [FeedImage]() {
        didSet {
            tableView.reloadData()
        }
    }
    private var tasks = [IndexPath: FeedImageDataLoaderTask]()
    
    public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.init()
        self.refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = refreshController?.view
        refreshController?.onRefresh = { [weak self] feed in
            self?.tableModel = feed
        }
        tableView.prefetchDataSource = self
        
        refreshController?.refresh()
    }
    

}

extension FeedViewController {
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModel[indexPath.row]
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = (cellModel.location == nil)
        cell.locationLabel.text = cellModel.location
        cell.descriptionLabel.text = cellModel.description
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        cell.feedImageContainer.startShimmering()
        
        let loadImage = { [weak self, weak cell] in
            guard let self = self else { return }
            
            self.tasks[indexPath] = self.imageLoader?.loadImageData(from: cellModel.url) { [weak cell] result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.feedImageView.image = image
                cell?.feedImageRetryButton.isHidden = (image != nil)
                cell?.feedImageContainer.stopShimmering()
            }
        }
        
        cell.onRetry = loadImage
        loadImage()
        
        return cell
    }
    
}

extension FeedViewController: UITableViewDataSourcePrefetching {
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            cancelTask(forRowAt: indexPath)
        }
        
        public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
            indexPaths.forEach { indexPath in
                let cellModel = tableModel[indexPath.row]
                tasks[indexPath] = imageLoader?.loadImageData(from: cellModel.url) { _ in }
            }
        }
        
        public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
            indexPaths.forEach(cancelTask)
        }
        
        private func cancelTask(forRowAt indexPath: IndexPath) {
            tasks[indexPath]?.cancel()
            tasks[indexPath] = nil
        }
}

