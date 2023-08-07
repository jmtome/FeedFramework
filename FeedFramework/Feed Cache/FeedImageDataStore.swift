//
//  FeedImageDataStore.swift
//  FeedFramework
//
//  Created by macbook on 04/07/2023.
//

import Foundation

public protocol FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws
    func retrieve(dataForURL url: URL) throws -> Data?
}
