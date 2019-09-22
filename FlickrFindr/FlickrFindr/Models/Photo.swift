//
//  Photo.swift
//  FlickrFindr
//
//  Created by Skyler Tanner  on 9/19/19.
//  Copyright © 2019 Skyler Tanner . All rights reserved.
//

import UIKit

class Photo: Codable {
    let title: String?
    let thumbnailRef: String?
    let largerImageRef: String?
    var largerImage: UIImage?
    var thumbnailImage: UIImage?
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case thumbnailRef = "url_sq"
        case largerImageRef = "url_s"
    }
    
}
