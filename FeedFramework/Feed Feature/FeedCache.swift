//
//  FeedCache.swift
//  FeedFramework
//
//  Created by macbook on 04/07/2023.
//

import Foundation

public protocol FeedCache {
    func save(_ feed: [FeedImage]) throws
}
