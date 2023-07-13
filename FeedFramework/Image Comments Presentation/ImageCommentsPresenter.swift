//
//  ImageCommentsPresenter.swift
//  FeedFramework
//
//  Created by macbook on 11/07/2023.
//

import Foundation

public struct ImageCommentsViewModel {
    public let comments: [ImageCommentViewModel]
}

public struct ImageCommentViewModel: Hashable {
    public let message: String
    public let date: String
    public let username: String

    public init(message: String, date: String, username: String) {
        self.message = message
        self.date = date
        self.username = username
    }
}

public final class ImageCommentsPresenter {
    public static var title: String {
        NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
                          tableName: "ImageComments",
                          bundle: Bundle(for: ImageCommentsPresenter.self),
                          comment: "Title for the image comments view")
    }
    
    public static func map(_ comments: [ImageComment],
                           currentDate: Date = Date(),
                           calendar: Calendar = .current,
                           locale: Locale = .current) -> ImageCommentsViewModel {
        
        ImageCommentsViewModel(comments: comments.map { comment in
            let formatter = RelativeDateTimeFormatter()
            formatter.calendar = calendar
            formatter.locale = locale
            
            let localizedDate = formatter.localizedString(for: comment.createdAt, relativeTo: currentDate)
            
            return ImageCommentViewModel(message: comment.message, date: localizedDate, username: comment.username)
        })
    }
}
