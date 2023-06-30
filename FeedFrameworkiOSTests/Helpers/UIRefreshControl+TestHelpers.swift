//
//  UIRefreshControl+TestHelpers.swift
//  FeedFrameworkiOSTests
//
//  Created by macbook on 30/06/2023.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}
