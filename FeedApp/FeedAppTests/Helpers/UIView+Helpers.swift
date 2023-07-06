//
//  UIView+Helpers.swift
//  FeedAppTests
//
//  Created by macbook on 06/07/2023.
//

import UIKit

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}
