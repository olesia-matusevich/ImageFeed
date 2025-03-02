//
//  ImageListPresenter.swift
//  ImageFeed
//
//  Created by Alesia Matusevich on 19/02/2025.
//

import Foundation
//import UIKit

public protocol ImagesListPresenterProtocol: AnyObject {
    func viewDidLoad()
    var view: ImagesListControllerProtocol? { get set }
    var imagesListService: ImagesListServiceProtocol? { get }
    func changeLike(photo: Photo, completion: @escaping (Result<Void, Error>) -> Void)
    func loadedImages() 
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    private var ImageListServiceObserver: NSObjectProtocol?
    weak var view: ImagesListControllerProtocol?
    var imagesListService: ImagesListServiceProtocol?
    
    init(imageListService: ImagesListServiceProtocol? = ImagesListService.shared) {
        self.imagesListService = imageListService
    }
    
    func viewDidLoad() {
        NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                view?.updateTableViewAnimated()
            }
    }

    func loadedImages(){
        imagesListService?.fetchPhotosNextPage{ result in
            switch result {
            case .success(let imagesResult):
                print("success")
            case .failure(let error):
                print("[ImagesListPresenter.loadedImages()]: error getting images. Error: \(error)")
                break
            }
        }
    }
    
    
    func changeLike(photo: Photo, completion: @escaping (Result<Void, Error>) -> Void) {
        imagesListService?.changeLike(photoId: photo.id, isLike: photo.isLiked, completion)
    }
}
