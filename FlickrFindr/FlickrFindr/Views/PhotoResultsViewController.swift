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
    
    var latestSearchResult: SearchResult?
    var photosToDisplay: [Photo] = []
    var searchTerms: [String] = []
    var latestSearchText: String?
    private var isLoadingNextPage = false
   
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
        activityIndicator?.center = resultsTableView!.center
        resultsTableView!.register(PhotoTableViewCell.self, forCellReuseIdentifier: pictureCellReuseIdentifier)
        searchController = UISearchController(searchResultsController: nil)
   
        resultsTableView!.tableHeaderView = searchController?.searchBar
        resultsTableView!.delegate = self
        resultsTableView!.dataSource = self
        
        searchController?.delegate = self
        searchController?.dimsBackgroundDuringPresentation = false
        searchController?.searchBar.placeholder = "Search For a Photo"
        searchController?.searchBar.delegate = self
        
        definesPresentationContext = true

        view.addSubview(resultsTableView!)
        view.addSubview(activityIndicator!)
    }
    
    func searchForPicture(text: String, page: Int) {
        isLoadingNextPage = true
        
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator?.startAnimating()
        }
        
        NetworkController.searchImages(searchTerm: text, page: page) { [weak self] (result, error) in
            guard let result = result else { return }
            self?.latestSearchResult = result
            self?.latestSearchText = text
            self?.photosToDisplay.append(contentsOf: result.resultInfo.photos ?? [])
            self?.isLoadingNextPage = false
            DispatchQueue.main.async { [weak self] in
                self?.activityIndicator?.stopAnimating()
                self?.resultsTableView?.reloadData()
            }
        }
    }
    
    func resetSearch() {
        latestSearchText = nil
        latestSearchResult = nil
        photosToDisplay = []
        NetworkController.cancelNetworkCalls()
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator?.stopAnimating()
            self?.resultsTableView?.reloadData()
        }
    }
    
}

extension PhotoResultsViewController: UISearchBarDelegate {
  
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        searchTerms.append(searchText)
        resetSearch()
        searchForPicture(text: searchText, page: 1)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            resetSearch()
        }
    }
   
}

extension PhotoResultsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosToDisplay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = resultsTableView?.dequeueReusableCell(withIdentifier: pictureCellReuseIdentifier) as? PhotoTableViewCell else {
            return UITableViewCell()
        }
        
        guard let resultInfo = latestSearchResult?.resultInfo,
            let currentPage = resultInfo.currentPage,
            let totalPages = resultInfo.totalPages,
            let latestSearchText = self.latestSearchText else {
            return cell
        }
        
        let shouldFetchMore = indexPath.row >= photosToDisplay.count - 11
        let hasMorePages = currentPage + 1 <= totalPages
        
        if shouldFetchMore, hasMorePages, !isLoadingNextPage {
            print("loading next page")
            searchForPicture(text: latestSearchText, page: currentPage + 1)
        }
        
        if let photo = photosToDisplay[safe: indexPath.row] {
            cell.load(photo: photo)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let height = photosToDisplay[safe: indexPath.row]?.thumbnailHeight,
            let intValue = Int(height) else {
            return defaultCellHeight
        }
        
        return CGFloat(intValue)
    }
    
}
