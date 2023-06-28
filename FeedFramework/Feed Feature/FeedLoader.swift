//
//  FeedLoader.swift
//  FeedFramework
//
//  Created by macbook on 30/05/2023.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    func load(completion: @escaping (Result) -> Void)
}
 
 
