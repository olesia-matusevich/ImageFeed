//
//  ImagesListTests.swift
//  ImageFeedTests
//
//  Created by Alesia Matusevich on 19/02/2025.
//

@testable import ImageFeed
import XCTest
import Foundation

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var imagesListService: (any ImageFeed.ImagesListServiceProtocol)?
    var view: (any ImageFeed.ImagesListControllerProtocol)?
    
    var viewDidLoadCalled: Bool = false
    var loadedImagesCalled: Bool = false
    var changeLikeCalled: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    func loadedImages() {
        loadedImagesCalled = true
    }
    
    func changeLike(photo: ImageFeed.Photo, completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCalled = true
    }
}

final class ImagesListViewControllerDummy: ImagesListControllerProtocol {
    func updateTableViewAnimated() {}
    
    var presenter: (any ImageFeed.ImagesListPresenterProtocol)?
    
    var photos: [ImageFeed.Photo] = [
        Photo(
            id: "1",
            size: CGSize(),
            createdAt: nil,
            welcomeDescription: nil,
            regularImageURL: "",
            fullImageURL: "",
            thumbImageURL: "",
            isLiked: false
        )]
}

final class ImageListTest: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let presenter = ImagesListPresenterSpy()
        let viewController = ImagesListViewController()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssert(presenter.viewDidLoadCalled)
    }
    
    func testViewControllerCallsloadedImages() {
        //given
        let presenter = ImagesListPresenterSpy()
        let viewController = ImagesListViewController()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.loadedImages()
        
        //then
        XCTAssert(presenter.loadedImagesCalled)
    }
    
    func testViewControllerCallsChangeLike() {
        //given
        let presenter = ImagesListPresenterSpy()
        let viewController = ImagesListViewControllerDummy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        let photo = viewController.photos[0]
        presenter.changeLike(photo: photo, completion: {[weak self] (result: Result<Void, Error>) in
        })
        
        //then
        XCTAssert(presenter.changeLikeCalled)
    }
    //
    
    
    
    
}
