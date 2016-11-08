//
//  MovieDatabaseClient.swift
//  MovieNight
//
//  Created by Christopher Bonuel on 11/8/16.
//  Copyright © 2016 Christopher Bonuel. All rights reserved.
//

import Foundation

enum MovieDatabase: Endpoint {
    
    case Genres
    
    var baseURL: String {
        return "https://api.themoviedb.org"
    }
    
    var path: String {
        switch self {
        case .Genres: return "/3/genre/movie/list"
        }
    }
    
    var parameters: [String : AnyObject] {
        switch self {
        case .Genres: return ["api_key":"fa302c15c454ce6a52f9f56679bdc266", "language":"en-US"]
        }
    }
}

final class MovieDatabaseClient: APIClient {
    
    let configuration: NSURLSessionConfiguration
    lazy var session: NSURLSession = {
        return NSURLSession(configuration: self.configuration)
    }()
    
    init(configuration: NSURLSessionConfiguration) {
        self.configuration = configuration
    }
    
    convenience init() {
        self.init(configuration: .defaultSessionConfiguration())
    }
}