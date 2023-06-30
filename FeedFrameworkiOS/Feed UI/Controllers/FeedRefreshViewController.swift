//
//  FeedRefreshViewController.swift
//  FeedFrameworkiOS
//
//  Created by macbook on 30/06/2023.
//

import UIKit
import FeedFramework

final class FeedRefreshViewController: NSObject {
    private(set) lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    private let feedLoader: FeedLoader
    
    var onRefresh: (([FeedImage]) -> Void)?
    
    @objc func refresh() {
        view.beginRefreshing()
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onRefresh?(feed)
            }
            self?.view.endRefreshing()
        }
    }
}
