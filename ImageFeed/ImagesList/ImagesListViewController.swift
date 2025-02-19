//
//  ViewController.swift
//  ImageFeed
//
//  Created by Alesia Matusevich on 21/11/2024.
//

import UIKit
import Kingfisher

public protocol ImagesListControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    var photos: [Photo] { get }
    func updateTableViewAnimated()
}

final class ImagesListViewController: UIViewController & ImagesListControllerProtocol{
    
    // MARK: - Private Properties
    
   
    var photos: [Photo] = []
    var presenter: ImagesListPresenterProtocol?
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService.shared
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - IB Outlets
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
//        NotificationCenter.default
//            .addObserver(
//                forName: ImagesListService.didChangeNotification,
//                object: nil,
//                queue: .main
//            ) { [weak self] _ in
//                guard let self = self else { return }
//                updateTableViewAnimated()
//            }
        presenter?.loadedImages()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            guard indexPath.row < photos.count else {
                assertionFailure("Index out of bounds for photos array")
                return
            }
            let photo = photos[indexPath.row]
            
            guard !photo.fullImageURL.isEmpty, let url = URL(string: photo.fullImageURL) else {
                assertionFailure("Invalid or empty URL for image")
                return
            }
            viewController.imageURL = url
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Private Methods
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
}

// MARK: - Extensions

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1{
            presenter?.loadedImages()
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let imageListCell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
    
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        cell.delegate = self
        
        let image = imagesListService.photos[indexPath.row]
        let placeholderImage = UIImage(named: "placeholder_scribble")
        let imageUrl = URL(string: image.regularImageURL)
        
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(
            with: imageUrl,
            placeholder: placeholderImage,
            options: nil,
            progressBlock: nil
        ) { [weak self] result in
            
            guard let self else { return }
            switch result {
            case .success:
                DispatchQueue.main.async {
                    cell.cellImage.contentMode = .scaleAspectFill
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                }
            case .failure(let error):
                print("Error loading image: \(error)")
            }
            let photo = self.photos[indexPath.row]
            
            if let dateCreatedAt = photo.createdAt {
                cell.dateLabel.text = dateFormatter.string(from: dateCreatedAt)
            } else {
                cell.dateLabel.text = ""
            }
        
            let likeImage = UIImage(named: photo.isLiked ? "LikeActive" : "LikeNoActive")
            cell.likeButton.setImage(likeImage, for: .normal)
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        let isPhotoLiked = !photo.isLiked
        
        presenter?.changeLike(photo: photo){ [weak self] (result: Result<Void, Error>) in
            //imagesListService.changeLike(photoId: photo.id, isLike: isPhotoLiked) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    guard let self = self else { return }
                    
                    if let index = self.photos.firstIndex(where: { $0.id == photo.id }) {
                        self.photos[index].isLiked = isPhotoLiked
                    }
                    cell.setIsLiked(isLiked: isPhotoLiked)
                    UIBlockingProgressHUD.dismiss()
                case .failure:
                    print("Error")
                    UIBlockingProgressHUD.dismiss()
                }
            }
        }
    }
}
