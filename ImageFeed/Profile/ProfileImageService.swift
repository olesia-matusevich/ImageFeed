//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Alesia Matusevich on 17/01/2025.
//

import UIKit

struct UserResult: Decodable{
    let profileImage: ProfileImage?
}
struct ProfileImage: Decodable {
    let small: String?
    //let medium: String?
    //let large: String?
}

final class ProfileImageService {
    
    // MARK: - Public Properties
    
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name("ProfileImageProviderDidChange")
    
    // MARK: - Private Properties
    
    private(set) var avatarURL: URL?
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private let jsonDecoder = JSONDecoder()
    
    private init(){}
    
    // MARK: - Private Methods
    
    private func makeProfileImageURLRequest(username: String?, token: String) -> URLRequest?{
        if let username,
           let baseURL = URL(string: Constants.defaultBaseURL.absoluteString),
           let url = URL(string: "/users/\(username)", relativeTo: baseURL) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            return request
        } else {
            print("[makeProfileImageURLRequest]: error creating profile image request")
            return nil
        }
    }
    
    // MARK: - Public Methods
    
    func fetchProfileImageURL(username: String?, handler: @escaping (Result<UserResult, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        task?.cancel()
        
        NotificationCenter.default.post(name: ProfileImageService.didChangeNotification,
                                        object: self,
                                        userInfo: ["URL": self.avatarURL as Any])
        
        guard let token = OAuth2TokenStorage().token else { return }
        guard let request = makeProfileImageURLRequest(username: username, token: token) else { return }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else { return }
            switch result {
            case .success(let userResult):
                guard let resultURL = userResult.profileImage?.small else {
                    print("[fetchProfileImageURL]: profile image URL receiving error.")
                    return}
                self.avatarURL = URL(string: resultURL)
                handler(.success(userResult))
            case .failure(let error):
                print("[fetchProfileImageURL]: error creating URLSessionTask. Error: \(error)")
                handler(.failure(error))
            }
        }
        task.resume()
    }
    
    func deleteImage() {
        avatarURL = nil
    }
}
