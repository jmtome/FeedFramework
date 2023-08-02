//
//  FeedStore.swift
//  FeedFramework
//
//  Created by macbook on 21/06/2023.
//

import Foundation


public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)

//The operations we need to perform here have no business logic. For example 'insert' wont have any business logic deciding whether or not to insert
//according to the timestamp, that was already decided by the business logic, here its simply obeying to commands.
//We have expectations against these protocols, we expect calls to the 'retrieve' method to have no side effects, meaning every time i call it it should return the same result
//Other expectation is that if i 'insert' something, there should be a side effect, because the next time i call 'retrieve', that data inserted should be returned
//Or if we call 'insert', then 'delete', when i call 'retrieve' nothing will be retrieved.
//
//These are expectations not business rules. We expect them to work always exactly the same.

//Here the side effects overlap, when you delete a cache you affect the insert and when you insert you affect the delete and the retrieve is affected by both.


public protocol FeedStore {
    func deleteCachedFeed() throws
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws
    func retrieve() throws -> CachedFeed?
}
