//
//  FeedCache.swift
//  FeedFramework
//
//  Created by macbook on 04/07/2023.
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}
