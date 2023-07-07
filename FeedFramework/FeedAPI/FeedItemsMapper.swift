//
//  FeedItemsMapper.swift
//  FeedFramework
//
//  Created by macbook on 30/05/2023.
//

import Foundation

public final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.items
    }
    
    public static func mapToFeedImages(_ data: Data, from response: HTTPURLResponse) throws -> [FeedImage] {
        do {
            let remoteItems = try self.map(data, from: response)
            return remoteItems.map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image)}
        } catch {
            throw error
        }
    }
}
