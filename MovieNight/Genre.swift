//
//  Genre.swift
//  MovieNight
//
//  Created by Christopher Bonuel on 11/8/16.
//  Copyright © 2016 Christopher Bonuel. All rights reserved.
//

import Foundation

struct Genre: Filter {
    var id: Int
    var description: String
}

extension Genre: JSONDecodable {
    
    init?(JSON: [String : AnyObject]) {
        
        guard let id = JSON["id"] as? Int, name = JSON["name"] as? String else { return nil }
        
        self.id = id
        self.description = name
    }
}