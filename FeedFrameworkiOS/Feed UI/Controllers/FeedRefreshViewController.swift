//
//  FeedRefreshViewController.swift
//  FeedFrameworkiOS
//
//  Created by macbook on 30/06/2023.
//

import UIKit

protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    private(set) lazy var view: UIRefreshControl = loadView()
    
    private let delegate: FeedRefreshViewControllerDelegate
    
    //We can also use a delegate and inject it
    
    init(delegate: FeedRefreshViewControllerDelegate) {
        self.delegate = delegate
    }
        
    @objc func refresh() {
        delegate.didRequestFeedRefresh()
    }

    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
