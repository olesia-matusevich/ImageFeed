@testable import ImageFeed
import XCTest
import Foundation

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: (any ImageFeed.ProfileViewControllerProtocol)?
    var viewDidLoadCalled: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func handleLogout() {}
    
    func updateAvatar() {}
    
    func updateProfileDetails(profile: ImageFeed.Profile) {}
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: (any ImageFeed.ProfilePresenterProtocol)?
    var updateProfileDetailsDidCalled: Bool = false
    var updateAvatarImageDidCalled: Bool = false
    
    func updateAvatarImage(with url: URL) {
        updateAvatarImageDidCalled = true
    }
    
    func updateProfileDetails(profile: ImageFeed.Profile) {
        updateProfileDetailsDidCalled = true
    }
}

final class ProfileImageServiceDummy: ProfileImageServiceProtocol {
    var avatarURL: URL?
}

final class ProfileViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsUpdateProfileDetails() {
        //given
        let presenter = ProfilePresenter()
        let viewController = ProfileViewControllerSpy()
        presenter.view = viewController
        viewController.presenter = presenter
        
        let profile = Profile(
            username: "",
            name: "",
            loginName: "",
            bio: ""
        )
        
        //when
        presenter.updateProfileDetails(profile: profile)
        
        //then
        XCTAssertTrue(viewController.updateProfileDetailsDidCalled)
    }
    
    func testPresenterCallsUpdateAvatarImage() {
        //given
        let imageService = ProfileImageServiceDummy()
        imageService.avatarURL = URL(string: "https://test.com")
        let presenter = ProfilePresenter(profileImageService: imageService)
        let viewController = ProfileViewControllerSpy()
        presenter.view = viewController
        
        //when
        presenter.updateAvatar()
        
        //then
        XCTAssertTrue(viewController.updateAvatarImageDidCalled)
    }
}
