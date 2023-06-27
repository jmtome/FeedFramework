//
//  RemoteFeedLoader.swift
//  FeedFramework
//
//  Created by macbook on 30/05/2023.
//

/*
 FEED API MODULE
-------------------------------------------|
|                                          |
| [FeedItemsMapper] <|- [RemoteFeedLoader] |
|    (internal)              |  |  |   |   |
|         |                  |  |  |   |----------------------------------
|         |                  |  |  |       |                             |
|         -                  |  |  |       |                             |
|         V                  |  |  |       |                             |
| [RemoteFeedItem] <|--------|  |  |       |                             |
|     (internal)                |  |       |                             |
|                               |  |       |                             |
|                               |  |       |                             |
|  <HttpClient> <|--------------|  |       |                             |
|      ^                           |       |   --------------------------|-----------
|      |                           |       |   |                         -          |
|      |                           |       |   |                         V          |
|      |                           ---------------> <FeedLoader> ---|> [FeedImage]   |
|      |                                   |   |                                    |
|      |                                   |   --------------------------------------
| [URLSessionHTTPClient]                   |    FEED FEATURE MODULE
|      |                                   |
|      |                                   |
|      |                                   |
______ | __________________________________|
       -
       V
   {Backend}
 */

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = FeedLoader.Result
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .success(let data, let response):
                completion(RemoteFeedLoader.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemsMapper.map(data, from: response)
            return .success(items.toModels())
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image)}
    }
}




