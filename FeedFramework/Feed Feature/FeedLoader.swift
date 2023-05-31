//
//  FeedLoader.swift
//  FeedFramework
//
//  Created by macbook on 30/05/2023.
//

import Foundation

// this is refactorable to the new Result<Success, Error> type from apple
public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
 
 
