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
