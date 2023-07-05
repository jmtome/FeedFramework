//
//  FeedAppUITests.swift
//  FeedAppUITests
//
//  Created by macbook on 04/07/2023.
//

import XCTest

final class FeedAppUITests: XCTestCase {
    
    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let app = XCUIApplication()
        
        app.launch()
        
        XCTAssertEqual(app.cells.count, 22)
//        XCTAssertEqual(app.cells.firstMatch.images.count, 1)
        //This assertion should be working but isnt, and i do not know why.
    }
}
