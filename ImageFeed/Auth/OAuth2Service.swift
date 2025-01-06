//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Alesia Matusevich on 22/12/2024.
//

import Foundation

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    
    private init() {}
    
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
            print("error creating token request")
            return nil
        }
    }
    
    func fetchOAuthToken(code: String, handler: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else { return }
        
        let urlSession = URLSession.shared
        let task = urlSession.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let token = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    handler(.success(token))
                } catch {
                    print("token decoding error error: \(error)")
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
