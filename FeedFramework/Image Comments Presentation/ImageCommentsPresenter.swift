//
//  ImageCommentsPresenter.swift
//  FeedFramework
//
//  Created by macbook on 11/07/2023.
//

import Foundation

public final class ImageCommentsPresenter {
    public static var title: String {
        NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
                          tableName: "ImageComments",
                          bundle: Bundle(for: ImageCommentsPresenter.self),
                          comment: "Title for the image comments view")
    }
}
