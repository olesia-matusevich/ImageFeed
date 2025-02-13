//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Alesia Matusevich on 05/12/2024.
//

import UIKit
import ProgressHUD

final class SingleImageViewController: UIViewController {
    
    // MARK: - Public Properties
    var imageURL: URL?
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    // MARK: - IB Outlets
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = imageURL {
            setImage(url: url)
        }
        
        guard let image else { return }
        imageView.image = image
        imageView.frame.size = image.size
        rescaleAndCenterImageInScrollView(image: image)
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
    }
    
    // MARK: - IB Actions
    
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image else { return }
        let shareController = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil)
        present(shareController, animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func setImage(url: URL) {
        UIBlockingProgressHUD.show()
        let placeholderImage = UIImage(named: "placeholder_scribble")
        imageView.image = placeholderImage
        imageView.contentMode = .center
        
        imageView.kf.setImage(
            with: url,
            placeholder: placeholderImage,
            options: nil,
            progressBlock: nil,
            completionHandler: { [weak self] result in
                DispatchQueue.main.async { [weak self] in
                    switch result {
                    case .success(let value):
                        UIBlockingProgressHUD.dismiss()
                        self?.image = value.image
                    case .failure:
                        UIBlockingProgressHUD.dismiss()
                        print("[setImage()]: set image error")
                        self?.showError(url: url)
                       
                    }
                }
            }
        )
    }
    
    private func showError(url: URL){
        
        let alert = UIAlertController(title: "Что-то пошло не так",
                                      message: "Попробовать еще раз?",
                                      preferredStyle: .alert)
        let alertActionNo = UIAlertAction(title: "Не надо", style: .default) {_ in self.dismiss(animated: true)
        }
        alert.addAction(alertActionNo)
        let alertActionReturn = UIAlertAction(title: "Повторить", style: .default) {_ in
            self.setImage(url: url)
        }
        alert.addAction(alertActionReturn)
        self.present(alert, animated: true)
    }
}

// MARK: - Extentions

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
