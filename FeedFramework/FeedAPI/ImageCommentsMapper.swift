//
//  ImageCommentsMapper.swift
//  FeedFramework
//
//  Created by macbook on 07/07/2023.
//

import Foundation

public final class ImageCommentsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard isOK(response), let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteImageCommentsLoader.Error.invalidData
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
    
    private static func isOK(_ response: HTTPURLResponse) -> Bool {
        (200...299).contains(response.statusCode)
    }
}

