////
////  CodableFeedStore.swift
////  FeedFramework
////
////  Created by macbook on 26/06/2023.
////
//
//import Foundation
//
//
////TODO: - Refactor this store so that it passes the tests, do not use.
//
///// This CodableFeedStore is not compliant with the tests as of now. It should not be used.
///// Use CoreDataFeedStore instead.
//public class CodableFeedStore: FeedStore {
//    private struct Cache: Codable {
//        let feed: [CodableFeedImage]
//        let timestamp: Date
//
//        var localFeed: [LocalFeedImage] {
//            return feed.map { $0.local }
//        }
//    }
//
//    //We create this private mirror type of LocalFeedImage because we do not want to couple the original model with the Codable conformance,
//    //That would not be ideal because looking at the dependency diagram, the CodableFeedStore would be implementing <FeedStore> which depends on LocalFeedImage
//    //and the CodableFeedStore itself depending on LocalFeedImage
//    //but at the same time we would have LocalFeedImage conforming/depending on Codable which is infrastructure(framework specific) layer, with an arrow returning, and we
//    //don't want that. Because in a future we might want to change our Store into perhaps CoreData/Realm (for which we would'nt need Codable) and whoever comes next might
//    //understand its o.k to keep coupling the model with the infrastructure/framework details. But ideally our LocalFeedImage should be a framework-agnostic type.
//    //
//    //Therefore we create a private local mirror type CodableFeedImage
//    private struct CodableFeedImage: Codable {
//        private let id: UUID
//        private let description: String?
//        private let location: String?
//        private let url: URL
//
//        init(_ image: LocalFeedImage) {
//            id = image.id
//            description = image.description
//            location = image.location
//            url = image.url
//        }
//
//        var local: LocalFeedImage {
//            return LocalFeedImage(id: id, description: description, location: location, url: url)
//        }
//    }
//
//    //This Queue is a background queue, but by default operations run serially. (side-effects are the enemy of concurrency)
//    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
//    private let storeURL: URL
//
//    public init(storeURL: URL) {
//        self.storeURL = storeURL
//    }
//
//    public func retrieve(completion: @escaping RetrievalCompletion) {
//        //we use this so as not to capture self inside the DispatchQueue, this way we capture the local 'storeURL' and pass it by copy, not by reference
//        let storeURL = self.storeURL
//
//        queue.async {
//            guard let data = try? Data(contentsOf: storeURL) else {
//                return completion(.success(.none))
//            }
//            do {
//                let decoder = JSONDecoder()
//                let cache = try decoder.decode(Cache.self, from: data)
//                completion(.success(CachedFeed(feed: cache.localFeed, timestamp: cache.timestamp)))
//            } catch {
//                completion(.failure(error))
//            }
//        }
//    }
//
//    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
//        let storeURL = self.storeURL
//
//        //we use the flag .barrier only on the operations that have side effects, so when these operations are running they will put the queue on hold
//        //until they are done. (this way, the operations without side effects can run concurrently, the ones with side-effects wait to finish)
//        queue.async(flags: .barrier) {
//            do {
//                let encoder = JSONEncoder()
//                let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
//                let encoded = try encoder.encode(cache)
//                try encoded.write(to: storeURL)
//                completion(.success(()))
//            } catch {
//                completion(.failure(error))
//            }
//        }
//    }
//
//    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
//        let storeURL = self.storeURL
//
//        queue.async(flags: .barrier) {
//            guard FileManager.default.fileExists(atPath: storeURL.path) else {
//                return completion(.success(()))
//            }
//
//            do {
//                try FileManager.default.removeItem(at: storeURL)
//                completion(.success(()))
//            } catch {
//                completion(.failure(error))
//            }
//        }
//    }
//
//
//}
