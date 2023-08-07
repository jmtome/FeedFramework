//
//  FeedImageDataCache.swift
//  FeedFramework
//
//  Created by macbook on 05/07/2023.
//


import Foundation

public protocol FeedImageDataCache {
    func save(_ data: Data, for url: URL) throws
}
