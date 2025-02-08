//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Alesia Matusevich on 22/12/2024.
//

import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    
    // MARK: - Private Properties
    
    private let urlSession = URLSession.shared
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    static let shared = OAuth2Service()
    private let jsonDecoder = JSONDecoder()
    
    private init() {}
    
    // MARK: - Private Methods
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        if let baseURL = URL(string: "https://unsplash.com"),
           let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            relativeTo: baseURL)
        {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            return request
        } else {
            print("[makeOAuthTokenRequest()]: error creating token request")
            return nil
        }
    }
    
    // MARK: - Public Methods
    
    func fetchOAuthToken(code: String, handler: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        guard lastCode != code else {
            handler(.failure(AuthServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else { return }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            switch result {
            case .success(let decodingToken):
                handler(.success(decodingToken))
            case .failure(let error):
                print("[fetchOAuthToken()]: error creating URLSessionTask. Error: \(error)")
                handler(.failure(error))
            }
        }
        task.resume()
    }
}
