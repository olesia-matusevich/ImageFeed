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
    
    // MARK: - Overrides Methods
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        alertPresenter.delegate = self
        // для проверки авторизации
//                UserDefaults.standard.removeObject(forKey: "token")
//                UserDefaults.standard.synchronize()
        
        if let token = oauth2TokenStorage.token {
            self.fetchProfile()
            switchToTabBarController()
        } else {
            performSegue(withIdentifier: ShowAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Private Methods
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    private func fetchProfileImage(username: String){
        profileImageService.fetchProfileImageURL(username: username) { [weak self] result in
            switch result {
            case .success(let imageURL):
                let a = 1
                //let profile = Profile(result: profileResult)
                //self?.updateProfile(profile: profile)
            case .failure(let error):
                print("error getting profile image")
            }
        }
    }
    
    private func fetchProfile(){
        UIBlockingProgressHUD.show()
        
        profileService.fetchProfile() { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success(let profileResult):
                self?.profileService.profile = Profile(result: profileResult)
                //self?.profileImageService.fetchProfileImageURL(username: username) {_ in
//                    [weak self] resultURL in
//                    switch resultURL {
//                    case .success():
//                        print("изображение профиля получено")
//                        //let profile = Profile(result: profileResult)
//                        //self?.updateProfile(profile: profile)
//                    case .failure():
//                        print("изображение не получено")
//                    }
 //               }
                
                self?.switchToTabBarController()

            case .failure(let error):
                self?.showLoginAlert(error: error)
                print("error getting profile. Error: \(error)")
                break
            }
        }
    }
    
    private func showLoginAlert(error: Error) {
        alertPresenter.showAlert(title: "Ошибка",
                                 message: "Не удалось получить данные профиля, \(error.localizedDescription)") {
            //self.performSegue(withIdentifier: self.ShowAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
}

// MARK: - Extensions

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for \(ShowAuthenticationScreenSegueIdentifier)") }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.fetchProfile()
        }
        //self.switchToTabBarController()
    }
    
    
}



