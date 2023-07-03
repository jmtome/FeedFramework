//
//  UIRefreshControl+Helpers.swift
//  FeedFrameworkiOS
//
//  Created by macbook on 03/07/2023.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
