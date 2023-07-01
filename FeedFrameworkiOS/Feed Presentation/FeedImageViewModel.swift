//
//  FeedImageViewModel.swift
//  FeedFrameworkiOS
//
//  Created by macbook on 30/06/2023.
//

import Foundation

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
}
