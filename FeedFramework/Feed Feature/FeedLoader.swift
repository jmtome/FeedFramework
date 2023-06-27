//
//  FeedLoader.swift
//  FeedFramework
//
//  Created by macbook on 30/05/2023.
//

import Foundation

// this is refactorable to the new Result<Success, Error> type from apple
public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
 
 
