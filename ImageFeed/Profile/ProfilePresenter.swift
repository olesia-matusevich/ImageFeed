//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Alesia Matusevich on 19/02/2025.
//

import Foundation

public protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? {get set}
    func viewDidLoad()
    func updateAvatar()
    func updateProfileDetails(profile: Profile)
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private var profileImageService: ProfileImageServiceProtocol?
    private var profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    init(profileImageService: ProfileImageServiceProtocol? = ProfileImageService.shared) {
        self.profileImageService = profileImageService
    }
    
    func viewDidLoad() {
        if let profile = profileService.profile {
            updateProfileDetails(profile: profile)
        }
        updateAvatar()
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.updateAvatar()
            }
    }
    
    func updateAvatar() {
        guard
            let profileImageURL = profileImageService?.avatarURL
        else { return }
        view?.updateAvatarImage(with: profileImageURL)
    }
    
    func updateProfileDetails(profile: Profile) {
        view?.updateProfileDetails(profile: profile)
    }
}
