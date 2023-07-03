//
//  FeedErrorViewModel.swift
//  FeedFrameworkiOS
//
//  Created by macbook on 03/07/2023.
//


struct FeedErrorViewModel {
    let message: String?

    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }

    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}
