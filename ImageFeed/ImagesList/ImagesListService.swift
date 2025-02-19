//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Alesia Matusevich on 30/01/2025.
//

import UIKit

public struct PhotoResult: Decodable {
    let id: String
    let createdAt: String
    let width: Int
    let height: Int
    let description: String?
    let likedByUser: Bool
    let urls: UrlResult
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case createdAt
        case width = "width"
        case height = "height"
        case description = "description"
        case likedByUser
        case urls = "urls"
    }
}

struct UrlResult: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

public struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let regularImageURL: String
    let fullImageURL: String
    let thumbImageURL: String
    var isLiked: Bool
}

extension Photo {
    static let formatter = ISO8601DateFormatter()
    
    init(result photo: PhotoResult) {
        self.init(id: photo.id,
                  size: CGSize(width: photo.width, height: photo.height),
                  createdAt: Photo.formatter.date(from: photo.createdAt),
                  welcomeDescription: photo.description,
                  regularImageURL: photo.urls.regular,
                  fullImageURL: photo.urls.full,
                  thumbImageURL: photo.urls.thumb,
                  isLiked: photo.likedByUser)
    }
}

public protocol ImagesListServiceProtocol: AnyObject {
    func fetchPhotosNextPage(handler: @escaping (Result<[PhotoResult], Error>) -> Void)
    var photos: [Photo] { get }
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
}

final class ImagesListService: ImagesListServiceProtocol {

    // MARK: - Public Properties
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    // MARK: - Private Properties
    
    private let tokenStorage = OAuth2TokenStorage()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    var photos: [Photo] = []
    private var lastLoadedPage: Int = 0
    private let perPage: String = "10"
    private var previousID = ""
    static let shared = ImagesListService()
    private init() {}
    // MARK: - Private Methods
    
    private func makeImagesListURLRequest() -> URLRequest?{
        var components = URLComponents(string: Constants.defaultBaseURL.absoluteString + "/photos")
        components?.queryItems = [
            URLQueryItem(name: "page", value: String(lastLoadedPage))]
        
        guard let url = components?.url else {
            print("[makeImagesListURLRequest()]: error creating profile URL request")
            return nil}
        guard let token = tokenStorage.token else {
            print("[makeImagesListURLRequest()]: error receiving token")
            return nil}
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    func likePhoto(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else {
            print("[likePhoto()]: error creating profile URL request")
            return }
        guard let token = tokenStorage.token else {
            print("[likePhoto()]: error receiving token")
            return }
        
        var request = URLRequest(url: url)
        if isLike {
            request.httpMethod = "POST"
        } else {
            request.httpMethod = "DELETE"
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("[ProfileService]: error liking photo. Error: \(error)")
                completion(.failure(error))
                return
            }
            self.updatePhoto(photoId: photoId)
            completion(.success(()))
        }
        task.resume()
    }
    
    private func updatePhoto(photoId: String) -> Void {
        if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
            
            let photo = self.photos[index]
            let newPhoto = Photo(
                id: photo.id,
                size: photo.size,
                createdAt: photo.createdAt,
                welcomeDescription: photo.welcomeDescription,
                regularImageURL: photo.regularImageURL,
                fullImageURL: photo.fullImageURL,
                thumbImageURL: photo.thumbImageURL,
                isLiked: !photo.isLiked
            )
            self.photos[index] = newPhoto
        }
    }
    
    // MARK: - Public Methods
    
    func fetchPhotosNextPage(handler: @escaping (Result<[PhotoResult], Error>) -> Void){
        let nextPage = lastLoadedPage + 1
        
        guard task == nil else { return }
        //task?.cancel()
        guard let request = makeImagesListURLRequest() else { return }
        
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            switch result {
            case .success(let photosResult):
                for photo in photosResult {
                    
                    //обработка ошибки дублирования картинок, которые приходят с сервера
                    guard let previousID = self?.previousID else { continue }
                    if previousID == photo.id {
                        continue
                    }
                    let newPhoto = Photo(result: photo)
                    self?.previousID = photo.id
                    
                    DispatchQueue.main.async {
                        self?.photos.append(newPhoto)
                        
                        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                    }
                }
                self?.lastLoadedPage = nextPage
                handler(.success(photosResult))
            case .failure(let error):
                print("[fetchProfile()]: error creating URLSessionTask. Error: \(error)")
                handler(.failure(error))
            }
            self?.task = nil
        }
        task?.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        
        likePhoto(photoId: photoId, isLike: isLike, completion: completion)
    }
    
    func deleteList() {
        photos.removeAll()
    }
    
}

