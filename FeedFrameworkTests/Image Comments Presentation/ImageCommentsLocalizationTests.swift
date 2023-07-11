//
//  ImageCommentsLocalizationTests.swift
//  FeedFrameworkTests
//
//  Created by macbook on 11/07/2023.
//

import XCTest
import FeedFramework

final class ImageCommentsLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        
        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }
    
}
