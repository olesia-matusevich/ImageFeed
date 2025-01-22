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
    let medium: String?
    let large: String?
    
}

final class ProfileImageService {
    
    static let shared = ProfileImageService()
    private(set) var avatarURL: URL?
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private let jsonDecoder = JSONDecoder()
    
    private init(){}
    
    func makeProfileImageURLRequest(username: String?, token: String) -> URLRequest?{
        if let username,
           let baseURL = URL(string: Constants.defaultBaseURL.absoluteString),
           let url = URL(string: "/users/\(username)", relativeTo: baseURL) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            return request
        } else {
            print("error creating profile image request")
            return nil
        }
    }
    
    func fetchProfileImageURL(username: String?, handler: @escaping (Result<UserResult, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let token = OAuth2TokenStorage().token else { return }
        guard let request = makeProfileImageURLRequest(username: username, token: token) else { return }
        
        let task = urlSession.data(for: request) { [weak self] result in
            
            switch result {
            case .success(let data):
                do {
//                    guard let smallImageURL = profileImageData.profileImage?.small else {return}
                    self?.jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                    let userResult = try self?.jsonDecoder.decode(UserResult.self, from: data)
                    guard let smallImageURL = userResult?.profileImage?.small else {
                        print("profile image result decoding error.")
                        return}
                    self?.avatarURL = URL(string: smallImageURL)
                   print(smallImageURL)
                    handler(.success(userResult!))
                } catch {
                    print("profile image result decoding error. Error: \(error)")
                    handler(.failure(error))
                }
            case .failure(let error):
                print("error creating URLSessionTask error: \(error)")
                handler(.failure(error))
            }
        }
        task.resume()
    }
}
