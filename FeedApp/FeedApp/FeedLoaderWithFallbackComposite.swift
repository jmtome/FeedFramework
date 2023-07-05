//
//  FeedLoaderWithFallbackComposite.swift
//  FeedApp
//
//  Created by macbook on 04/07/2023.
//

import FeedFramework

public class FeedLoaderWithFallbackComposite: FeedLoader {
    private let primary: FeedLoader
    private let fallback: FeedLoader
    
    public init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load { [weak self] result in
            switch result {
            case .success:
                completion(result)
                
            case .failure:
                self?.fallback.load(completion: completion)
            }
        }
    }
}
