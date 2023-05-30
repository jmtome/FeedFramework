//
//  FeedItem.swift
//  FeedFramework
//
//  Created by macbook on 30/05/2023.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
