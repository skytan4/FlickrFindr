//
//  Photo.swift
//  FlickrFindr
//
//  Created by Skyler Tanner  on 9/19/19.
//  Copyright © 2019 Skyler Tanner . All rights reserved.
//

import Foundation

struct Photo: Codable {
    let title: String?
    let thumbnailRef: String?
    let thumbnailHeight: String?
    let thumbnailWidth: String?
    let largerImageRef: String?
    let largerImageHeight: String?
    let largerImageWidth: String?
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case thumbnailRef = "url_sq"
        case thumbnailHeight = "height_sq"
        case thumbnailWidth = "width_sq"
        case largerImageRef = "url_q"
        case largerImageHeight = "height_q"
        case largerImageWidth = "width_q"
    }
}
