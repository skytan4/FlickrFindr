//
//  PhotoResultsViewController.swift
//  FlickrFindr
//
//  Created by Skyler Tanner  on 9/18/19.
//  Copyright © 2019 Skyler Tanner . All rights reserved.
//

import UIKit

class PhotoResultsViewController: UIViewController, UISearchControllerDelegate {
    var resultsTableView: UITableView?
    var searchController: UISearchController?
    var activityIndicator: UIActivityIndicatorView?
    
    private var isLoadingNextPage = false
    private var userIsTyping: Bool {
        return searchController?.searchBar.isFirstResponder ?? false
    }
    
    private var latestSearchResult: SearchResult?
    var searchTerms: [String] = []
    var photosToDisplay: [Photo] = [] {
        didSet {
            reloadData()
        }
    }
   
    private let defaultCellHeight: CGFloat = 75.0
    private let pictureCellReuseIdentifier = "pictureCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    func setupViews() {
        title = "Flickr Findr"
        
        activityIndicator = UIActivityIndicatorView(frame: .zero)
        activityIndicator?.style = .whiteLarge
        activityIndicator?.color = .blue
        
        resultsTableView = UITableView(frame: view.frame)
        resultsTableView?.register(PhotoTableViewCell.self, forCellReuseIdentifier: pictureCellReuseIdentifier)
        resultsTableView?.delegate = self
        resultsTableView?.dataSource = self
        activityIndicator?.center = resultsTableView!.center
        
        searchController = UISearchController(searchResultsController: nil)
        resultsTableView?.tableHeaderView = searchController?.searchBar
        
        searchController?.delegate = self
        searchController?.dimsBackgroundDuringPresentation = false
        searchController?.searchBar.placeholder = "Search For a Photo"
        searchController?.searchBar.delegate = self
        
        definesPresentationContext = true

        view.addSubview(resultsTableView!)
        view.addSubview(activityIndicator!)
    }
    
    func searchImages(text: String, page: Int) {
        activityIndicator?.startAnimating()
        
        NetworkController.searchImages(searchTerm: text, page: page) { [weak self] (result, error) in
            guard error == nil else {
                self?.displayError(error: error!)
                return
            }
            
            guard let result = result, let photos = result.resultInfo.photos, !photos.isEmpty else {
                self?.presentNoResultsModal()
                return
            }
            self?.latestSearchResult = result
            self?.photosToDisplay.append(contentsOf: photos)
            self?.isLoadingNextPage = false
        }
    }
    
    func downloadLargerImage(photo: Photo) {
        guard let largerImageURL = URL(string: photo.largerImageRef ?? "") else { return }
        
        activityIndicator?.startAnimating()
        NetworkController.loadImage(url: largerImageURL) { [weak self] (image, error) in
            guard error == nil else {
                self?.displayError(error: error!)
                return
            }
            
            guard let largerImage = image else { return }
            photo.largerImage = largerImage
            self?.presentLargerImage(title: photo.title ?? "No Title", image: largerImage)
        }
    }
    
    func resetSearch() {
        latestSearchResult = nil
        photosToDisplay = []
        NetworkController.cancelNetworkCalls()
    }
    
    func presentLargerImage(title: String, image: UIImage) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        let imageAction = UIAlertAction(title: "", style: .default, handler: nil)
        
        // this is not the best solution, but given that the size is always 150 x 150 this helps ensure it is centered
        let centeredImage = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -49, bottom: 0, right: 49))
        imageAction.setValue(centeredImage.withRenderingMode(.alwaysOriginal), forKey: "image")
        imageAction.isEnabled = false
        alert.addAction(imageAction)
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(dismissAction)
        
        presentModal(modal: alert)
    }
    
    func presentNoResultsModal() {
        let alert = UIAlertController(title: "No Results", message: nil, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(dismissAction)
        
        presentModal(modal: alert)
    }
    
    func displayError(error: EndpointError) {
        let message: String
        switch error {
        case .decodeFailure(let decodingError):
            print(decodingError)
            message = "The service is having a problem"
        case .imageLoadFailed(let reason):
            print(reason ?? "Nil reason for image load failure")
            // return without displaying error so we do not inturrupt user experience
            return
        case .nilData, .nilURL:
            message = "There was an issue, please try again"
        case .serviceError(let serviceMessage):
            print(serviceMessage ?? "Nil service error message")
            message = "The service is having issues, please try again later"
        }
        
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(dismissAction)
        
        presentModal(modal: alert)
    }
    
    private func presentModal(modal: UIAlertController) {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator?.stopAnimating()
            self?.present(modal, animated: true, completion: nil)
        }
    }
    
    private func reloadData() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator?.stopAnimating()
            self?.resultsTableView?.reloadData()
        }
    }
    
}

// MARK: -- SEARCHBAR DELEGATE

extension PhotoResultsViewController: UISearchBarDelegate {
  
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        searchTerms.insert(searchText, at: 0)
        resetSearch()
        searchImages(text: searchText, page: 1)
        reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        reloadData()
    }
   
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        reloadData()
    }
}

// MARK: -- TABLEVIEW DATASOURCE

extension PhotoResultsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if userIsTyping {
            return "Recent Search Terms"
        } else {
            return "Results"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if userIsTyping {
            return searchTerms.count
        } else {
            return photosToDisplay.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = resultsTableView?.dequeueReusableCell(withIdentifier: pictureCellReuseIdentifier) as? PhotoTableViewCell else {
            return UITableViewCell()
        }
        
        // Display search suggestions when entering search text
        guard !userIsTyping else {
            if resultsTableView?.contentOffset.y ?? 0.0 > CGFloat.zero {
                resultsTableView?.setContentOffset(.zero, animated:true)
            }
            
            // For convenience, re-using the PhotoTableViewCell to display recent search terms
            cell.titleLabel.text = searchTerms[safe: indexPath.row]
            return cell
        }
        
        guard let resultInfo = latestSearchResult?.resultInfo,
            let currentPage = resultInfo.currentPage,
            let totalPages = resultInfo.totalPages,
            let latestSearchText = searchTerms.first else {
            return cell
        }
        
        let shouldFetchMore = indexPath.row >= photosToDisplay.count - 11
        let hasMorePages = (currentPage + 1) <= totalPages
        
        if shouldFetchMore, hasMorePages, !isLoadingNextPage {
            isLoadingNextPage = true
            searchImages(text: latestSearchText, page: currentPage + 1)
        }
        
        if let photo = photosToDisplay[safe: indexPath.row] {
            cell.load(photo: photo)
        }
        
        return cell
    }
}

// MARK: -- TABLEVIEW DELEGATE

extension PhotoResultsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Clear out current results and re-search the selected search term
        guard !userIsTyping else {
            searchController?.searchBar.resignFirstResponder()
            resetSearch()
            
            let searchTerm = searchTerms[safe: indexPath.row] ?? ""
            searchController?.searchBar.text = searchTerm
            searchImages(text: searchTerm, page: 1)
            return
        }
        
        guard let photo = photosToDisplay[safe: indexPath.row] else { return }
        
        // If we already have the image, don't load it again.
        if let largerImage = photo.largerImage {
            presentLargerImage(title: photo.title ?? "No Title", image: largerImage)
            return
        } else {
            downloadLargerImage(photo: photo)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let height = photosToDisplay[safe: indexPath.row]?.thumbnailHeight,
            let intValue = Int(height) else {
            return defaultCellHeight
        }
        
        return CGFloat(intValue)
    }
    
}
