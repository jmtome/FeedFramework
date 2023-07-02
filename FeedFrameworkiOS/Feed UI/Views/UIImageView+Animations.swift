//
//  UIImageView+Animations.swift
//  FeedFrameworkiOS
//
//  Created by macbook on 01/07/2023.
//

import UIKit

extension UIImageView {
    func setImageAnimated(_ newImage: UIImage?) {
        image = newImage
        guard newImage != nil else { return }
        
        alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
}
