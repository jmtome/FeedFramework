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
    //Implemented by Storyboard
//    private(set) lazy var view: UIRefreshControl = loadView()
    @IBOutlet private var view: UIRefreshControl!

    var delegate: FeedRefreshViewControllerDelegate?
    
    //We can also use a delegate and inject it
    
//    init(delegate: FeedRefreshViewControllerDelegate) {
//        self.delegate = delegate
//    }
        
    @IBAction func refresh() {
        delegate?.didRequestFeedRefresh()
    }

    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    //Implemented by Storyboard
//    private func loadView() -> UIRefreshControl {
//        let view = UIRefreshControl()
//        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
//        return view
//    }
}
