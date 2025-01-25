//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Alesia Matusevich on 13/12/2024.
//

import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let screenLogoImageView: UIImageView = {
        let view = UIImageView()
        let image = UIImage(named: "auth_screen_logo")
        view.image = image
        return view
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(
            nil,
            action: #selector(Self.didTapButton),
            for: .touchUpInside
        )
        button.setTitle("Войти", for: button.state)
        button.setTitleColor(.castomBlack, for: button.state)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        
        return button
    }()
    
    private let tokenStorage = OAuth2TokenStorage()
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupСonstraints()
        configureBackBatton()
    }
    
    // MARK: - Private Methods
    
    @objc
    private func didTapButton() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
       
        guard let webViewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as? WebViewViewController else {return}
        webViewController.delegate = self
       
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    private func setupViews() {
        [screenLogoImageView, loginButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupСonstraints(){
        NSLayoutConstraint.activate([
            // лого
            screenLogoImageView.heightAnchor.constraint(equalToConstant: 60),
            screenLogoImageView.widthAnchor.constraint(equalToConstant: 60),
            screenLogoImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            screenLogoImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            // кнопка логина
            loginButton.heightAnchor.constraint(equalToConstant: 48),
            loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -124)
        ])
    }
    
    private func configureBackBatton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "CastomBlackColor")
    }
}

// MARK: - Extensions

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        
        UIBlockingProgressHUD.show()
        OAuth2Service.shared.fetchOAuthToken(code: code) { [weak self] result in
            guard let self else {return}
            
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let token):
                self.tokenStorage.token = token.token
                self.delegate?.authViewController(self, didAuthenticateWithCode: code)
            case .failure(let error):
                print("[AuthViewController (delegate)]: error saving token. Error: \(error)")
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}

