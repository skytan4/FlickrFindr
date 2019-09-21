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
    private let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    private let titleLabel = UILabel()
    private let photoImageView = UIImageView()
    
    private var loadingState: LoadingState = .notLoading {
        didSet {
            switch loadingState {
            case .notLoading:
                photoImageView.image = nil
            case .loading:
                photoImageView.image = nil
            case let .loaded(img):
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
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(photoImageView)

        let imageViewLeftConstraint = NSLayoutConstraint(item: photoImageView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1.0, constant: 1.0)
        let imageViewWidthConstraint = NSLayoutConstraint(item: photoImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 75)
        let imageViewTopConstraint = NSLayoutConstraint(item: photoImageView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 5.0)
        let imageViewBottomConstraint = NSLayoutConstraint(item: photoImageView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: -5.0)
        contentView.addConstraints([imageViewLeftConstraint,
                                    imageViewWidthConstraint,
                                    imageViewTopConstraint,
                                    imageViewBottomConstraint])
        
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
   
        loadingState = .notLoading
    }
    
    func load(photo: Photo)  {
        titleLabel.text = photo.title
        guard let thumbnailRef = photo.thumbnailRef, let imageURL = URL(string: thumbnailRef) else { return }
        
        loadingState = .loading
        NetworkController.loadImage(url: imageURL) { [weak self] (image, error) in
            guard error == nil, let image = image else {
                // Load default image
                print("missing image")
                return
            }
            
            self?.loadingState = .loaded(image)
        }
    }
    
}
