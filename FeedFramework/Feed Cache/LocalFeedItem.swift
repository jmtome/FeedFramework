//
//  LocalFeedItem.swift
//  FeedFramework
//
//  Created by macbook on 22/06/2023.
//

import Foundation

//DTO: Data transfer object, used to remove coupling.
public struct LocalFeedItem: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(id: UUID,
                description: String? = nil,
                location: String? = nil,
                imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}
