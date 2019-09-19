//
//  NetworkController.swift
//  FlickrFindr
//
//  Created by Skyler Tanner  on 9/18/19.
//  Copyright © 2019 Skyler Tanner . All rights reserved.
//

import Foundation

/* Example Reference
 https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=1508443e49213ff84d566777dc211f2a&text=tigers&media=photos&extras=url_q%2C+url_sq&per_page=25&page=&format=json&nojsoncallback=1
*/

struct NetworkController {
    private let apiKey = "1508443e49213ff84d566777dc211f2a"
    
    enum EndpointError {
        case nilURL
        case nilData
        case decodeFailure(DecodingError)
        case serviceError(String)
    }
    
    func searchImages(searchTerm: String, page: Int, resultsPerPage: Int = 25, callback: @escaping (SearchResult?, EndpointError?) -> Void) {
  
        guard let imageSearchURL = URL(string: "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&text=\(searchTerm)&media=photos&extras=url_q%2C+url_sq&per_page=\(resultsPerPage)&page=\(page)&format=json&nojsoncallback=1") else {
            callback(nil, .nilURL)
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: imageSearchURL) { (data, response, error) in
            
            guard error == nil else {
                print(error!.localizedDescription)
                callback(nil, .serviceError(error!.localizedDescription))
                return
            }
            
            guard let responseData = data else {
                callback(nil, .nilData)
                print("Error getting data")
                return
            }
            
            do{
                let result = try JSONDecoder().decode(SearchResult.self, from: responseData)
                callback(result, nil)
            } catch (let error) {
                
                print(error)
                if let err = error as? DecodingError {
                    callback(nil, .decodeFailure(err))
                } else {
                    // should not happen
                    callback(nil, .serviceError(error.localizedDescription))
                }
                return
            }

        }
        
        dataTask.resume()
    }
}
