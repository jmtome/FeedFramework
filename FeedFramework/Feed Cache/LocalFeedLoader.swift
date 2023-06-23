//
//  LocalFeedLoader.swift
//  FeedFramework
//
//  Created by macbook on 21/06/2023.
//

//Use cases are the business logic (some people call them controllers, some interactors, some model controllers)
//The business logic is the what, the recipe, and the framework specific logic is the How.
//For example the CoreData implementation of the FeedStore interface will encode it for CoreData, whereas a Realm implementation of the FeedStore interface will
//encode it for Realm database.
//Frameworks dont make decisions, they just obey commands, so its easier to replace implementations of those frameworks because all of the business logic is encapsulated
//in the Controller types or the Use Case Types. This is the essence of modularity, being able to change implementation on-demand without having to make modifications
//to the system


/*
                          FEED CACHE MODULE
                          ------------------------------------------------
                          |                                              |
                          |    [LocalFeedLoader] ---|> [LocalFeedImage]   |
                          |        |    |                      ^         |
                          |        |    |                      -         |
                          |        |    |                      |         |
                          |        |    |                      |         |
                          |        |    -------------|>   <FeedStore>    |
                          |        |                                     |
                          ---------|--------------------------------------
    -------------------------------|--------
    |                              -       |
    |                              V       |
    |   <FeedLoader> -----|>   [FeedImage]  |
    |                                      |
    ----------------------------------------
                         FEED FEATURE MODULE

 */


import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(feed, with: completion)
            }
        }
    }
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [unowned self] result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .found(feed: let feed, timestamp: let timestamp) where self.validate(timestamp):
                completion(.success(feed.toModels()))
            case .found, .empty:
                completion(.success([]))
            }
        }
    }
    private func validate(_ timestamp: Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        guard let maxCacheAge = calendar.date(byAdding: .day, value: 7, to: timestamp) else { return false }
        return currentDate() < maxCacheAge
    }
    
    private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(feed.toLocal() , timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
    }
}
