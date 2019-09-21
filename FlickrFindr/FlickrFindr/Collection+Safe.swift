//
//  Collection+Safe.swift
//  FlickrFindr
//
//  Created by Skyler Tanner  on 9/20/19.
//  Copyright © 2019 Skyler Tanner . All rights reserved.
//

import Foundation

public extension Collection {
    // Returns the element at the specified index if its within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
