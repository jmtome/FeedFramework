//
//  LocalFeedLoader.swift
//  FeedFramework
//
//  Created by macbook on 21/06/2023.
//

//tags: core domain, application business logic, business logic, use case, validation policy.
//impure function/ pure function/type

//Use cases are the application specific business logic (some people call them controllers, some interactors, some model controllers)
//The business logic is the what, the recipe, and the framework specific logic is the How.
//For example the CoreData implementation of the FeedStore interface will encode it for CoreData, whereas a Realm implementation of the FeedStore interface will
//encode it for Realm database.
//Frameworks dont make decisions, they just obey commands, so its easier to replace implementations of those frameworks because all of the business logic is encapsulated
//in the Controller types or the Use Case Types. This is the essence of modularity, being able to change implementation on-demand without having to make modifications
//to the system

//Business models are normally separated into models that have identity for example a Customer (you can identify a customer) and models that have no identity like a Policy (you cannot identify a policy), policies are rules. We separate business rules with identity by calling them Entities.
//So, Entities are models with identity, and Value objects are models with no identity. In this case the Policy has no identity it just encaptulates a rule that we need
// which means we dont need an instance of the FeedCachePolicy , it can be Static. (since the policy holds no state, its deterministic and has no side effects and it has no identity), therefore it shouldnt be instanciated so we make its initializer empty and private.

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

//Validation logic is policy, and use cases are not policies, use cases encapsulate application specific logic.
//The policy can be represented as a business model, and use cases are not business models, because business models are
//application-logic agnostic and can be used cross applications, should be agnostic of frameworks and side-effects.

//The LocalFeedLoader should encapsulate application-specific logic only, and communicate with Models to perform business logic
//
//Rules and Policies (validation logic) are better suited in a Domain Model, that is application-agnostic


import Foundation

private final class FeedCachePolicy {
    private init() {}
    
    private static let calendar = Calendar(identifier: .gregorian)
    private static var maxCacheAgeInDays: Int {
        return 7
    }
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else { return false }
        return date < maxCacheAge
    }
}

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}
extension LocalFeedLoader {
    public typealias SaveResult = Error?
    
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
    
    private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(feed.toLocal() , timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

extension LocalFeedLoader: FeedLoader {
    public typealias LoadResult = LoadFeedResult
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                completion(.failure(error))
                
            case .found(feed: let feed, timestamp: let timestamp) where FeedCachePolicy.validate(timestamp, against: self.currentDate()):
                completion(.success(feed.toModels()))
                
            case .found, .empty:
                completion(.success([]))
            }
        }
    }
}

extension LocalFeedLoader {
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                self.store.deleteCachedFeed { _ in }
                
            case .found(feed: _, timestamp: let timestamp) where !FeedCachePolicy.validate(timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed { _ in }
            case .empty, .found: break
            }
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
    }
}
