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
        let presenter = FeedPresenter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(presenter: presenter)
        let feedController = FeedViewController(refreshController: refreshController)
        
        presenter.loadingView = WeakRefVirtualProxy(refreshController)
        presenter.feedView = FeedViewAdapter(controller: feedController, imageLoader: imageLoader)
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
    func display(isLoading: Bool) {
        object?.display(isLoading: isLoading)
    }
}

private final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewController?, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(feed: [FeedImage]) {
        controller?.tableModel = feed.map { model in
            FeedImageCellController(viewModel: FeedImageViewModel(model: model, imageLoader: imageLoader, imageTransformer: UIImage.init))
        }
    }

}

