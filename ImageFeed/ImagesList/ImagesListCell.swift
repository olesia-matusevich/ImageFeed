//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Alesia Matusevich on 26/11/2024.
//

import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    weak var delegate: ImagesListCellDelegate?
    
    // MARK: - Static properties
    
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - @IBOutlet properties
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    // MARK: - Overrides Methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Отменяем загрузку, чтобы избежать багов при переиспользовании ячеек
        cellImage.kf.cancelDownloadTask()
    }
    
    // MARK: - @IBAction Methods
    
    @IBAction private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    // MARK: - @Public Methods
    
    func setIsLiked(isLiked: Bool) {
        likeButton.setImage(UIImage(named: isLiked ? "LikeActive" : "LikeNoActive"), for: .normal)
    }
}
