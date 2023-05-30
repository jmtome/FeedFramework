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
        sut.load() { _ in }
        
        //MARK: - Then (assert that a URL request was initiated in the client)
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func tests_loadTwice_requestsDataFromURLTwice() {
        //MARK: - Given (a client and a sut)
        let url = URL(string: "http://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        //MARK: - When (we invoke sut.load())
        sut.load() { _ in }
        sut.load() { _ in }
        
        //MARK: - Then (assert that a URL request was initiated in the client)
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        //MARK: - Given
        let (sut, client) = makeSUT()
        
        //MARK: - When (we tell the sut to load and we complete the client's http request with an error)
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) }
        
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)
        
        //MARK: - Then (we expect the captured load error to be a connectivity error)
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            var capturedErrors = [RemoteFeedLoader.Error]()
            sut.load { capturedErrors.append($0) }
            
            client.complete(withStatusCode: code, at: index)
            XCTAssertEqual(capturedErrors, [.invalidData])

        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) }
        
        let invalidJSON = Data("invalid json".utf8)
        
        client.complete(withStatusCode: 200, data: invalidJSON)
    }
    
    //MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "http://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut =  RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()

        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
             
            messages[index].completion(.success(data, response))
        }
    }
}
