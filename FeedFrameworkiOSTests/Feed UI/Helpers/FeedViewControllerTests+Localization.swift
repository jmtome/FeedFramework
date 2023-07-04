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
    func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key :\(key) in table : \(table)", file: file, line: line)
        }
        return value
    }
}
