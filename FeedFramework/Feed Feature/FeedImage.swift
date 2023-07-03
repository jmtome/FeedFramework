//
//  FeedImage.swift
//  FeedFramework
//
//  Created by macbook on 30/05/2023.
//

import Foundation

public struct FeedImage: Hashable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL
    
    public init(id: UUID,
                description: String? = nil,
                location: String? = nil,
                url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }
}
