//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Alesia Matusevich on 04/12/2024.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let profileService = ProfileService.shared
    
    private var userName: String?
    private var profileImageServiceObserver: NSObjectProtocol?
    private let profileLogoutService = ProfileLogoutService.shared
    
    private let profileImageView: UIImageView = {
        let view = UIImageView()
        let image = UIImage(named: "UserImage")
        view.image = image
        return view
    }()
    
    private var userNameLabel: UILabel = {
        var label = UILabel()
        label.text = "Екатерина Новикова"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 23)
        return label
    }()
    
    private var userLoginLabel: UILabel = {
        var label = UILabel()
        label.text = "@ekaterina_nov"
        label.textColor = UIColor(named: "CustomGreyColorLogin")
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    
    private var descriptionLabel: UILabel = {
        var label = UILabel()
        label.text = "Hello, World!"
        label.textColor = .white
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .custom)
        let logoutImage =  UIImage(named: "LogoutImage")
        button.setImage(logoutImage, for: button.state)
        button.addTarget(
            nil,
            action: #selector(Self.didTapButton),
            for: .touchUpInside
        )
        return button
    }()
    
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let profile = profileService.profile {
            updateProfileDetails(profile: profile)
        }
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.updateAvatar()
            }
        updateAvatar()
        
        setupUI()
        setupViews()
        setupСonstraints()
    }
    
    // MARK: - Private Methods
    
    @objc
    private func didTapButton() {
        let alert = UIAlertController(title: nil, message: "Выйти из профиля?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Да", style: .default) { _ in
            self.profileLogoutService.logout()
            
            guard let window = UIApplication.shared.windows.first else { return }
            
            let authViewController = UIStoryboard(name: "Main", bundle: .main)
                .instantiateViewController(withIdentifier: "AuthViewController")
            window.rootViewController = authViewController
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {}, completion: nil)
        }
        
        let noAction = UIAlertAction(title: "Нет", style: .default, handler: nil)
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func updateProfileDetails(profile: Profile){
        userName = profile.username
        userNameLabel.text = profile.name
        userLoginLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
    
    private func updateAvatar(){
        guard let profileImageURL = ProfileImageService.shared.avatarURL else { return }
        let processor = RoundCornerImageProcessor(cornerRadius: 20)
        profileImageView.kf.setImage(with: profileImageURL,
                                     placeholder: UIImage(named: "placeholder.jpeg"),
                                     options: [.processor(processor)])
        
    }
    private func setupUI() {
        self.view.backgroundColor = .castomBlack
    }
    
    private func setupViews() {
        [profileImageView, userNameLabel, userLoginLabel, descriptionLabel, logoutButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupСonstraints(){
        NSLayoutConstraint.activate([
            // фото профиля
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            
            // имя
            userNameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            userNameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            
            // логин
            userLoginLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            userLoginLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8),
            
            // дискрипшен
            descriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            descriptionLabel.topAnchor.constraint(equalTo: userLoginLabel.bottomAnchor, constant: 8),
            
            // кнопка логаута
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor)
        ])
    }
}

