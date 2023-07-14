//
//  FeedEndpoint.swift
//  FeedFramework
//
//  Created by macbook on 13/07/2023.
//

import Foundation

public enum FeedEndpoint {
    case get
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case .get:
            return baseURL.appendingPathComponent("/v1/feed")
        }
    }
}
