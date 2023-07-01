//
//  FeedUIComposer.swift
//  FeedFrameworkiOS
//
//  Created by macbook on 30/06/2023.
//

import FeedFramework
import UIKit

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)
        
        let refreshController = FeedRefreshViewController(delegate: presentationAdapter)
        let feedController = FeedViewController(refreshController: refreshController)
        
        let presenter = FeedPresenter(
            feedView: FeedViewAdapter(controller: feedController, imageLoader: imageLoader),
                                      loadingView: WeakRefVirtualProxy(refreshController))

        presentationAdapter.presenter = presenter
        return feedController
    }
}

//Memory management is a responsability that belongs in the composer not in your components
//otherwise you'll be leaking infrastructure details into your MVP components

//So we make a WeakRefVirtualProxy that will hold a weak reference to the object instance and pass the messages forward.

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}
//so when we set the LoadView we weakify it with the virutal proxy. And for that to work the proxy should also conform to the FeedLoadingView protocol, which
//we can do in an extension of the VirtualProxy, we constrain the conformance where the object type must also implement the FeedLoadingView protocol, this way we
//can safely forward the messages to the weak instance with compile check guarantees

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

private final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewController?, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map { model in
            FeedImageCellController(viewModel: FeedImageViewModel(model: model, imageLoader: imageLoader, imageTransformer: UIImage.init))
        }
    }
}

//we have a circular dependency in our presentation logic, however
//We dont want to leak composition details in our components, but since the presentation adapter is part of the composition layer, its a good candidate for property
//injection, in this case we are not leaking composition details into the adapter, since the adapter is already a composition component

private final class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    private let feedLoader: FeedLoader
    var presenter: FeedPresenter?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        
        feedLoader.load { [weak self] result in
            switch result {
            case .success(let feed):
                self?.presenter?.didFinishLoadingFeed(with: feed)
                
            case .failure(let error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
    
}
