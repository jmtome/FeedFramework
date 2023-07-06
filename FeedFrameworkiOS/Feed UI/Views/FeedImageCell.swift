//
//  FeedImageCell.swift
//  FeedFrameworkiOS
//
//  Created by macbook on 29/06/2023.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
    @IBOutlet public var locationContainer: UIView!
    @IBOutlet public var locationLabel: UILabel!
    @IBOutlet public var descriptionLabel: UILabel!
    @IBOutlet public var feedImageContainer: UIView!
    @IBOutlet public var feedImageView: UIImageView!
    @IBOutlet public var feedImageRetryButton: UIButton!
    
    var onRetry: (() -> Void)?
    
    @IBAction private func retryButtonTapped() {
        onRetry?()
    }
        
    func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = "feed-image-cell"
        self.feedImageView.accessibilityIdentifier = "feed-image-view"
    }
}
