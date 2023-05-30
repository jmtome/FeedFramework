//
//  RemoteFeedLoaderTests.swift
//  FeedFramework
//
//  Created by macbook on 30/05/2023.
//

import XCTest

class RemoteFeedLoader {
    let url: URL
    let client: HTTPClient
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    func load() {
        client.get(from: url)
    }
}
protocol HTTPClient {
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    
    func get(from url: URL) {
        requestedURL =  url
    }
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let url = URL(string: "http://aa-url.com")!
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(url: url, client: client)
        
        
        XCTAssertNil(client.requestedURL)
    }
    
    func tests_load_requestDataFromURL() {
        //MARK: - Given (a client and a sut)
        let url = URL(string: "http://aa-url.com")!
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        //MARK: - When (we invoke sut.load())
        sut.load()
        
        //MARK: - Then (assert that a URL request was initiated in the client)
        XCTAssertEqual(url, client.requestedURL)
    }
}
