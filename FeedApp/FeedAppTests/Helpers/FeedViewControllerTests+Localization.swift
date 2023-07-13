//
//  FeedViewControllerTests+Localization.swift
//  FeedFrameworkiOSTests
//
//  Created by macbook on 03/07/2023.
//

import Foundation
import XCTest
import FeedFramework

extension FeedUIIntegrationTests {
    private class DummyView: ResourceView {
        func display(_ viewModel: Any) {}
    }
    
    var loadError: String {
        LoadResourcePresenter<Any, DummyView>.loadError
    }
    
    var feedTitle: String {
        FeedPresenter.title
    }
    
    var commentsTitle: String {
        ImageCommentsPresenter.title
    }
}
