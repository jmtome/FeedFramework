//
//  RemoteFeedItem.swift
//  FeedFramework
//
//  Created by macbook on 22/06/2023.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}
