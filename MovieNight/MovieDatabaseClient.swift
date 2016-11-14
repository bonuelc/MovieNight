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
    case Movies(genre_ids: [Int])
    
    var baseURL: String {
        return "https://api.themoviedb.org"
    }
    
    var path: String {
        switch self {
        case .Genres: return "/3/genre/movie/list"
        case .Movies: return "/3/discover/movie"
        }
    }
    
    var parameters: [String : AnyObject] {
        switch self {
        case .Genres:
            return ["api_key":"fa302c15c454ce6a52f9f56679bdc266",
                    "language":"en-US"]
        case .Movies(let genre_ids):
            let genres = genre_ids.map {  $0.description }.joinWithSeparator(",") // "12,16,28"
            return ["api_key" : "fa302c15c454ce6a52f9f56679bdc266",
                    "language" : "en-US",
                    "sort_by" : "popularity.desc",
                    "page" : "1",
                    "with_genres" : genres]
        }
    }
}

final class MovieDatabaseClient: APIClient {
    
    let genresKey = "genres"
    
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
    
    func fetchGenres(completion: APIResult<[Genre]> -> Void) {
        
        let endpoint = MovieDatabase.Genres
        
        fetch(endpoint, parse: { json -> [Genre]? in
            
            guard let genres = json[self.genresKey] as? [[String: AnyObject]] else { return nil }
            
            return genres.flatMap { return Genre(JSON: $0) }
            
            }, completion: completion)
    }
}