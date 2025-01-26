//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Alesia Matusevich on 06/01/2025.
//

import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let alertPresenter = AlertPresenter()

    
    private let vectorImageView: UIImageView = {
        let view = UIImageView()
        let image = UIImage(named: "Vector")
        view.image = image
        return view
    }()
    
    // MARK: - Overrides Methods
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        alertPresenter.delegate = self
       
        // для проверки авторизации
        //OAuth2TokenStorage().removeToken()
        //UserDefaults.standard.removeObject(forKey: "token")
        //UserDefaults.standard.synchronize()
        
        if let token = oauth2TokenStorage.token {
            self.fetchProfile()
        } else {
            let authController = AuthViewController()
            authController.delegate = self
            authController.modalPresentationStyle = .fullScreen
            present(authController, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupСonstraints()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        [vectorImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupСonstraints(){
        NSLayoutConstraint.activate([
            // кнопка логаута
            vectorImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            vectorImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    private func fetchProfileImage(profile: Profile){
        profileImageService.fetchProfileImageURL(username: profile.username) { result in
            switch result {
            case .success(let imageURL):
                print(imageURL)
            case .failure(let error):
                print("[fetchProfileImage()]: error getting profile image. Error: \(error)")
            }
        }
    }
    
    private func fetchProfile(){
        UIBlockingProgressHUD.show()
        
        profileService.fetchProfile(){ [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self else {return}
            switch result {
            case .success(let profileResult):
                let profile = Profile(result: profileResult)
                self.profileService.profile = profile
                self.fetchProfileImage(profile: profile)
                
                self.switchToTabBarController()
            case .failure(let error):
                self.showLoginAlert(error: error)
                print("[fetchProfile()]: error getting profile. Error: \(error)")
                break
            }
        }
    }
    
    private func showLoginAlert(error: Error) {
        alertPresenter.showAlert(title: "Что-то пошло не так",
                                 message: "Не удалось войти в систему, \(error.localizedDescription)") {
            //self.performSegue(withIdentifier: self.ShowAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
}

    // MARK: - Extensions

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.fetchProfile()
        }
        //self.switchToTabBarController()
    }
}



