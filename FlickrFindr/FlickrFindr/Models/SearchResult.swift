//
//  SearchResult.swift
//  FlickrFindr
//
//  Created by Skyler Tanner  on 9/18/19.
//  Copyright © 2019 Skyler Tanner . All rights reserved.
//

import Foundation

struct SearchResult: Codable {
    let resultInfo: SearchResultInfo
    
    enum CodingKeys: String, CodingKey {
        case resultInfo = "photos"
    }
}

struct SearchResultInfo: Codable {
    let currentPage: Int?
    let totalPages: Int?
    let resultsPerPage: Int?
    let totalPhotos: String?
    let photos: [Photo]?
    
    enum CodingKeys: String, CodingKey {
        case currentPage = "page"
        case totalPages = "pages"
        case resultsPerPage = "perpage"
        case totalPhotos = "total"
        case photos = "photo"
    }
}

struct Photo: Codable {
    let id: String?
    let owner: String?
    let secret: String?
    let server: String?
    let farm: Int?
    let title: String?
    
    // May not be used commenting out for now to avoid data bloat
//    let ispublic: Int?
//    let isfriend: Int?
//    let isfamily: Int?
}
