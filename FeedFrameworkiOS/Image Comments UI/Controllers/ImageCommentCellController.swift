//
//  ImageCommentCellController.swift
//  FeedFrameworkiOS
//
//  Created by macbook on 11/07/2023.
//

import UIKit
import FeedFramework

public class ImageCommentCellController: CellController {
    let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel) {
        self.model = model
    }
   
    public func view(in tableview: UITableView) -> UITableViewCell {
        let cell: ImageCommentCell = tableview.dequeueReusableCell()
        cell.messageLabel.text = model.message
        cell.usernameLabel.text = model.username
        cell.dateLabel.text = model.date
        
        return cell
    }    
}
