//
//  UIButton+TestHelpers.swift
//  FeedFrameworkiOSTests
//
//  Created by macbook on 30/06/2023.
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
