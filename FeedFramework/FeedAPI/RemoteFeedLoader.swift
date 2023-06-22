//
//  RemoteFeedLoader.swift
//  FeedFramework
//
//  Created by macbook on 30/05/2023.
//

/*
 FEED API MODULE
--------------------------------------------
| [FeedItemsMapper] <|- [RemoteFeedLoader]  |
|                              |     |      |
| <HttpClient> <|--------------      |      |
|    ^                               |      |
|    |                               |      |
|    |                               -----------> <FeedLoader>
|    |                                      |
|    |                                      |
| [URLSessionHTTPClient]                    |
|      |                                    |
|      |                                    |
|      |                                    |
______ | ___________________________________
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
    
    public typealias Result = LoadFeedResult
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .success(let data, let response):
                completion(FeedItemsMapper.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}




