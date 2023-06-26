//
//  CodableFeedStoreTests.swift
//  FeedFrameworkTests
//
//  Created by macbook on 24/06/2023.
//

import XCTest
import FeedFramework

class CodableFeedStore {
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map { $0.local }
        }
    }

    //We crate this private mirror type of LocalFeedImage because we do not want to couple the original model with the Codable conformance,
    //That would not be ideal because looking at the dependency diagram, the CodableFeedStore would be implementing <FeedStore> which depends on LocalFeedImage
    //and the CodableFeedStore itself depending on LocalFeedImage
    //but at the same time we would have LocalFeedImage conforming/depending on Codable which is infrastructure(framework specific) layer, with an arrow returning, and we
    //don't want that. Because in a future we might want to change our Store into perhaps CoreData/Realm (for which we would'nt need Codable) and whoever comes next might
    //understand its o.k to keep coupling the model with the infrastructure/framework details. But ideally our LocalFeedImage should be a framework-agnostic type.
    //
    //Therefore we create a private local mirror type CodableFeedImage
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        init(_ image: LocalFeedImage) {
            id = image.id
            description = image.description
            location = image.location
            url = image.url
        }
        
        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    private let storeURL: URL

    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
          return completion(.empty)
        }
        
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        completion(nil)
        
    }
}

final class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = createSUT()
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { result in
            switch result {
            case .empty: break
            default:
                XCTFail("Expected empty result, got \(result), instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_HasNoSideEffectsOnEmptyCache() {
        let sut = createSUT()
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty): break
                default:
                    XCTFail("Expected retrieving twice from empty cache to deliver sae empty result, got \(firstResult) and \(secondResult) instead")
                }
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = createSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()

        let exp = expectation(description: "Wait for cache retrieval")

        sut.insert(feed, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")

            sut.retrieve { retrieveResult in
                switch retrieveResult {
                case .found(feed: let retrievedFeed, timestamp: let retrievedTimestamp):
                    XCTAssertEqual(retrievedFeed, feed)
                    XCTAssertEqual(retrievedTimestamp, timestamp)
                default:
                    XCTFail("Expected found result with feed \(feed) and timestamp \(timestamp), got \(retrieveResult) instead ")
                }
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = createSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()

        let exp = expectation(description: "Wait for cache retrieval")

        sut.insert(feed, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")

            sut.retrieve { firstResult in
                sut.retrieve { secondResult in
                    switch (firstResult, secondResult) {
                    case (.found(let firstFoundFeed, let firstFoundTimestamp), .found(let secondFoundFeed, let secondFoundTimestamp)):
                        XCTAssertEqual(firstFoundFeed, feed)
                        XCTAssertEqual(firstFoundTimestamp, timestamp)
                        XCTAssertEqual(secondFoundFeed, feed)
                        XCTAssertEqual(secondFoundTimestamp, timestamp)
                    default:
                        XCTFail("Expected retrieving twice from non empty cache to deliver same found result with feed \(feed), and timestamp: \(timestamp), got \(firstResult) and \(secondResult) instead")
                    }
                    exp.fulfill()
                }
            }
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    //MARK: - Helpers
    
    private func createSUT(file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
}
