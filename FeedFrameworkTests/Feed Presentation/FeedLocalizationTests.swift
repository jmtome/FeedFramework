//
//  FeedLocalizationTests.swift
//  FeedFrameworkiOSTests
//
//  Created by macbook on 03/07/2023.
//

import XCTest
import FeedFramework

final class FeedLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)

        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }
    
}
