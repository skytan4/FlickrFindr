//
//  SearchResultInfo.swift
//  FlickrFindr
//
//  Created by Skyler Tanner  on 9/19/19.
//  Copyright © 2019 Skyler Tanner . All rights reserved.
//

import Foundation

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
