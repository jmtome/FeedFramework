//
//  FeedImageViewModel.swift
//  FeedFramework
//
//  Created by macbook on 03/07/2023.
//


public struct FeedImageViewModel {
    public let description: String?
    public let location: String?

    public var hasLocation: Bool {
        return location != nil
    }
}
