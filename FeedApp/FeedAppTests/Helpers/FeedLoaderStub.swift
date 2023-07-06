//
//  FeedLoaderStub.swift
//  FeedAppTests
//
//  Created by macbook on 04/07/2023.
//

import FeedFramework

class FeedLoaderStub: FeedLoader {
    private let result: FeedLoader.Result
    
    init(result: FeedLoader.Result) {
        self.result = result
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
}
