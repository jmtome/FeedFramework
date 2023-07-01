//
//  FeedRefreshViewController.swift
//  FeedFrameworkiOS
//
//  Created by macbook on 30/06/2023.
//

import UIKit

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    private(set) lazy var view: UIRefreshControl = loadView()
    
    private let loadFeed: () -> Void
    
    //We could also stablesh an indirect communication channel between the view and the presenter. So that the view would not hold a reference to the concrete
    //presenter type. So instead we can pass a closure, and thus decouple the controller from any other presenter. We inject this closure via the UIComposer
    
    init(loadFeed: @escaping () -> Void) {
        self.loadFeed = loadFeed
    }
        
    @objc func refresh() {
        loadFeed()
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
