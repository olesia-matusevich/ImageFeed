//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Alesia Matusevich on 26/11/2024.
//

import UIKit

final class ImagesListCell: UITableViewCell {

    // MARK: - Static properties
    
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - @IBOutlet properties
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
}
