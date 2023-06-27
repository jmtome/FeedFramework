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
    typealias RetrievalResult = Result<CachedFeed?, Error>

    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrievalResult) -> Void

    /// The completion handler can be invoked in any thread.
    /// Clients are responsible for dispatching to appropriate threads, if needed.
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible for dispatching to appropriate threads, if needed.
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible for dispatching to appropriate threads, if needed.
    func retrieve(completion: @escaping RetrievalCompletion)
}


//MARK: - Expectations/Especifications
/*
 - Retrieve
    - Empty Cache returns empty
    - Empty Cache twice returns empty (no-side-effects)
    - Non-Empty cache returns data
    - Non-Empty cache twice returns same data (no-side-effects)
    - Error returns error (if applicable, e.g., invalid data)
    - Error twice returns same error
 
 - Insert
    - To empty cache stores data
    - To non-empty cache overrides previous data with new data
    - Error (if applicable, e.g, no write permission/ no space)
 
 - Delete
    - Empty cache does nothing (cache stays empty and it does not fail)
    - Non-empty cache leaves cache empty
    - Error (if applicable, e.g., no delete permission)
 
 - Side-effects must run serially to avoid race-conditions
 
 */
