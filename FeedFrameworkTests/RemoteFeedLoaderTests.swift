//
//  RemoteFeedLoaderTests.swift
//  FeedFramework
//
//  Created by macbook on 30/05/2023.
//

import XCTest
import FeedFramework

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func tests_load_requestsDataFromURL() {
        //MARK: - Given (a client and a sut)
        let url = URL(string: "http://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        //MARK: - When (we invoke sut.load())
        sut.load()
        
        //MARK: - Then (assert that a URL request was initiated in the client)
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func tests_loadTwice_requestsDataFromURLTwice() {
        //MARK: - Given (a client and a sut)
        let url = URL(string: "http://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        //MARK: - When (we invoke sut.load())
        sut.load()
        sut.load()
        
        //MARK: - Then (assert that a URL request was initiated in the client)
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    //MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "http://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut =  RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        
        func get(from url: URL) {
            requestedURLs.append(url)
        }
    }
}
