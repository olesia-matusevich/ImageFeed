//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Alesia Matusevich on 14/01/2025.
//

import UIKit

struct ProfileResult: Decodable {
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

extension Profile {
    init(result profile: ProfileResult) {
        self.init(username: profile.username,
                  name: "\(profile.firstName ?? "") \(profile.lastName ?? "")",
                  loginName: "@\(profile.username)",
                  bio: profile.bio)
    }
}

final class ProfileService {
    static let shared = ProfileService()
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private let jsonDecoder = JSONDecoder()
    
    var profile: Profile?
    
    private init() {}
    
    func makeProfileURLRequest(token: String) -> URLRequest?{
        if let baseURL = URL(string: Constants.defaultBaseURL.absoluteString),
           let url = URL(string: "/me", relativeTo: baseURL) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
           
            return request
        } else {
            print("error creating profile request")
            return nil
        }
    }
    
    func fetchProfile(handler: @escaping (Result<ProfileResult, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        task?.cancel()
        guard let token = OAuth2TokenStorage().token else { return }
        guard let request = makeProfileURLRequest(token: token) else { return }
        
        let task = urlSession.data(for: request) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    self?.jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                    let profileResult = try self?.jsonDecoder.decode(ProfileResult.self, from: data)
                    //let profile = Profile(result: profileResult!)
                    handler(.success(profileResult!))
                } catch {
                    print("profile result decoding error error: \(error)")
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
