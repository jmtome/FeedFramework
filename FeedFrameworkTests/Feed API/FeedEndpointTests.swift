//
//  FeedEndpointTests.swift
//  FeedFrameworkTests
//
//  Created by macbook on 13/07/2023.
//


import XCTest
import FeedFramework

class FeedEndpointTests: XCTestCase {
    
    func test_feed_endpointURL() {
        let baseURL = URL(string: "http://base-url.com")!
        
        let received = FeedEndpoint.get.url(baseURL: baseURL)
        let expected = URL(string: "http://base-url.com/v1/feed")!
        
        XCTAssertEqual(received, expected)
    }
    
}
