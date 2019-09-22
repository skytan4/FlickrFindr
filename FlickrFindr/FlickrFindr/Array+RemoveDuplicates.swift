
//
//  Array+RemoveDuplicates.swift
//  FlickrFindr
//
//  Created by Skyler Tanner  on 9/22/19.
//  Copyright © 2019 Skyler Tanner . All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    mutating func removeDuplicates() {
        var result = [Element]()
        for value in self {
            if !result.contains(value) {
                result.append(value)
            }
        }
        self = result
    }
}
