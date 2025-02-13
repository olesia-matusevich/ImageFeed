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
    
    // MARK: - Private Properties
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    // MARK: - Public Properties
    
    static let shared = ProfileService()
    var profile: Profile?
    
    private init() {}
    
    // MARK: - Private Methods
    
    private func makeProfileURLRequest(token: String) -> URLRequest?{
        if let baseURL = URL(string: Constants.defaultBaseURL.absoluteString),
           let url = URL(string: "/me", relativeTo: baseURL) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            return request
        } else {
            print("[makeProfileURLRequest()]: error creating profile request")
            return nil
        }
    }
    
    // MARK: - Public Methods
    
    func fetchProfile(handler: @escaping (Result<ProfileResult, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        task?.cancel()
        guard let token = OAuth2TokenStorage().token else { return }
        guard let request = makeProfileURLRequest(token: token) else { return }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let profileResult):
                handler(.success(profileResult))
            case .failure(let error):
                print("[fetchProfile()]: error creating URLSessionTask. Error: \(error)")
                handler(.failure(error))
            }
        }
        task.resume()
    }
    
    func deleteProfile() {
        profile = nil
    }
}
