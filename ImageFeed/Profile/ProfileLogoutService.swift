//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Alesia Matusevich on 08/02/2025.
//

import Foundation
import WebKit

final class ProfileLogoutService {
    
    // MARK: - Public Properties
    
    static let shared = ProfileLogoutService()
    
    private init() {}
    
    // MARK: - Public Methods
    
    func logout() {
        ProfileService.shared.deleteProfile()
        ProfileImageService.shared.deleteImage()
        ImagesListService().deleteList()
        OAuth2TokenStorage().removeToken()
        
        cleanCookies()
    }
    
    // MARK: - Private Methods
    
    private func cleanCookies() {
        // Очищаем все куки из хранилища
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        // Запрашиваем все данные из локального хранилища
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            // Массив полученных записей удаляем из хранилища
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
        
    }
}
