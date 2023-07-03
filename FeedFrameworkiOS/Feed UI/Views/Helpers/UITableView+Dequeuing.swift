//
//  UITableView+Dequeuing.swift
//  FeedFrameworkiOS
//
//  Created by macbook on 01/07/2023.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
