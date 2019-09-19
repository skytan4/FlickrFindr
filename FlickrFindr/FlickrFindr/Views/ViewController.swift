//
//  ViewController.swift
//  FlickrFindr
//
//  Created by Skyler Tanner  on 9/18/19.
//  Copyright © 2019 Skyler Tanner . All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var pictureTableView: UITableView?
    var latestSearchResult: SearchResult?
    let networkController = NetworkController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        networkController.searchImages(searchTerm: "Tiger", page: 2) { [weak self] (result, error) in
            self?.latestSearchResult = result
            print(result)
            print(error)
        }
    }
    
    func setupViews() {
        // TODO: setup search/results view
    }


}

