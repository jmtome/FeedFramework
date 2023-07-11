//
//  FeedImagePresenterTests.swift
//  FeedFrameworkTests
//
//  Created by macbook on 03/07/2023.
//

import XCTest
import FeedFramework


class FeedImagePresenterTests: XCTestCase {
    
    func test_map_createsViewModel() {
        let image = uniqueImage()

        let viewModel = FeedImagePresenter.map(image)
        
        XCTAssertEqual(viewModel.description, image.description)
        XCTAssertEqual(viewModel.location, image.location)
    }
}
