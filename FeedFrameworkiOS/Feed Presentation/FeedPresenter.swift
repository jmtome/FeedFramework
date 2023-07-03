//
//  FeedPresenter.swift
//  FeedFrameworkiOS
//
//  Created by macbook on 01/07/2023.
//

import FeedFramework


protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}


protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

//In MVP a presenter must have a reference to its view protocol, our views are optional, but ideally they shouldnt be optional, we must have views.
// to improve the design a constructor is better to guarantee we always have references to our views

final class FeedPresenter {
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    
    init(feedView: FeedView, loadingView: FeedLoadingView) {
        self.feedView = feedView
        self.loadingView = loadingView
    }
    
    static var title: String {
        return "My Feed"
    }
    
    func didStartLoadingFeed() {
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
   
    
}

