//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Alesia Matusevich on 04/12/2024.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private lazy var profileImageView = UIImageView()
    private lazy var userNameLabel = UILabel()
    private lazy var userLoginLabel = UILabel()
    private lazy var descriptionLabel = UILabel()
    private lazy var logoutButton = UIButton(type: .custom)
    
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureProfileImageView()
        configureUserNameLabel()
        configureUserLoginLabel()
        configureDescriptionLabel()
        configureLogoutButton()
   
        createСonstraints()
    }
    
    // MARK: - Private Methods
    
    @objc
       private func didTapButton() {
//           TODO: Добавить обработчик нажатия кнопки логаута
       }
    
    private func configureProfileImageView() {
        let profileImage = UIImage(named: "UserImage")
        profileImageView.image = profileImage
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
       
        view.addSubview(profileImageView)
    }
    
    private func configureUserNameLabel() {
        userNameLabel.text = "Екатерина Новикова"
        userNameLabel.textColor = .white
        userNameLabel.font = .boldSystemFont(ofSize: 23)
        
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(userNameLabel)
    }
    
    private func configureUserLoginLabel(){
        userLoginLabel.text = "@ekaterina_nov"
        userLoginLabel.textColor = UIColor(named: "CustomGreyColorLogin")
        userLoginLabel.font = .systemFont(ofSize: 13)
        
        userLoginLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(userLoginLabel)
    }
    
    private func configureDescriptionLabel(){
        descriptionLabel.text = "Hello, World!"
        descriptionLabel.textColor = .white
        descriptionLabel.font = .systemFont(ofSize: 13)
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(descriptionLabel)
    }
    
    private func configureLogoutButton(){
        let logoutImage =  UIImage(named: "LogoutImage")
        logoutButton.setImage(logoutImage, for: logoutButton.state)
        logoutButton.addTarget(
            self,
            action: #selector(Self.didTapButton),
            for: .touchUpInside
        )
        
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(logoutButton)
    }
    
    private func createСonstraints(){
        // фото пользователя
        profileImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        
        // имя пользователя
        userNameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        userNameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8).isActive = true
       
        // логин
        userLoginLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        userLoginLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8).isActive = true
        
        // дискрипшен
        descriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: userLoginLabel.bottomAnchor, constant: 8).isActive = true
       
        // кнопка логаута
        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
    }
}

