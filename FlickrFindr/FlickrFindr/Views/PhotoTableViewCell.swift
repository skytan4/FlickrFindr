//
//  PhotoTableViewCell.swift
//  FlickrFindr
//
//  Created by Skyler Tanner  on 9/19/19.
//  Copyright © 2019 Skyler Tanner . All rights reserved.
//

import UIKit

enum LoadingState {
    case notLoading
    case loading
    case loaded(UIImage)
}

class PhotoTableViewCell: UITableViewCell {
    private let activityIndicator = UIActivityIndicatorView(style: .white)
    let titleLabel = UILabel()
    private let photoImageView = UIImageView()
    
    private var loadingState: LoadingState = .notLoading {
        didSet {
            switch loadingState {
            case .notLoading:
                activityIndicator.stopAnimating()
                photoImageView.image = nil
            case .loading:
                activityIndicator.startAnimating()
                photoImageView.image = nil
            case let .loaded(img):
                activityIndicator.stopAnimating()
                photoImageView.image = img
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    private func setupView() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(activityIndicator)
        contentView.addSubview(photoImageView)

        let imageViewLeftConstraint = NSLayoutConstraint(item: photoImageView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1.0, constant: 1.0)
        let imageViewWidthConstraint = NSLayoutConstraint(item: photoImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 75)
        let imageViewTopConstraint = NSLayoutConstraint(item: photoImageView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 5.0)
        let imageViewBottomConstraint = NSLayoutConstraint(item: photoImageView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: -5.0)
        contentView.addConstraints([imageViewLeftConstraint,
                                    imageViewWidthConstraint,
                                    imageViewTopConstraint,
                                    imageViewBottomConstraint])
        
        let activityIndicatorWidthConstraint = NSLayoutConstraint(item: activityIndicator, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 75.0)
        let activityIndicatorHeightConstraint = NSLayoutConstraint(item: activityIndicator, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 75.0)
        let activityIndicatorCenterXConstraint = NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: photoImageView, attribute: .centerX, multiplier: 1.0, constant: 5.0)
        let activityIndicatorCenterYConstraint = NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: photoImageView, attribute: .centerY, multiplier: 1.0, constant: -5.0)
        contentView.addConstraints([activityIndicatorWidthConstraint,
                                    activityIndicatorHeightConstraint,
                                    activityIndicatorCenterXConstraint,
                                    activityIndicatorCenterYConstraint])
        
        let titleLeftConstraint = NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: photoImageView, attribute: .trailing, multiplier: 1.0, constant: 5.0)
        let titleRightConstraint = NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1.0, constant: -8.0)
        let titleTopConstraint = NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 5.0)
        let titleBottomConstraint = NSLayoutConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: -5.0)
        contentView.addConstraints([titleLeftConstraint,
                                    titleTopConstraint,
                                    titleRightConstraint,
                                    titleBottomConstraint])

        activityIndicator.color = .blue
        titleLabel.numberOfLines = 2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
   
        titleLabel.text = nil
        loadingState = .notLoading
    }
    
    func load(photo: Photo)  {
        titleLabel.text = photo.title ?? "No Title"
        
        // If we already have the image, don't load it again.
        guard photo.thumbnailImage == nil else {
            photoImageView.image = photo.thumbnailImage!
            return
        }
        
        guard let thumbnailRef = photo.thumbnailRef,
            let imageURL = URL(string: thumbnailRef) else { return }
        
        loadingState = .loading
        
        NetworkController.loadImage(url: imageURL) { [weak self] (image, error) in
            guard error == nil, let thumbnailImage = image else {
                // Load a default image
                return
            }
            photo.thumbnailImage = thumbnailImage
            DispatchQueue.main.async { [weak self] in
                self?.loadingState = .loaded(thumbnailImage)
            }
        }
    }
    
}
