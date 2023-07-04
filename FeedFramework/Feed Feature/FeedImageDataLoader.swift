//
//  FeedImageDataLoader.swift
//  FeedFrameworkiOS
//
//  Created by macbook on 30/06/2023.
//

import Foundation

public protocol FeedImageDataLoaderTask {
    func cancel()
}
public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}
//Instead of having two protocol methods, one to load, one to cancel, we have 1 method, load and we make it return a LoaderTask, and we make the
//implementing clients responsable for tracking this state instead of making our protocols stateful.
