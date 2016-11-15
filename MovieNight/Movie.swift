//
//  Movie.swift
//  MovieNight
//
//  Created by Christopher Bonuel on 11/14/16.
//  Copyright © 2016 Christopher Bonuel. All rights reserved.
//

import Foundation
import UIKit

struct Movie: Entity {
    var id: Int
    var description: String
    var posterView: UIView
}

extension Movie: JSONDecodable {
    
    init?(JSON: [String : AnyObject]) {
        
        guard let id = JSON["id"] as? Int, title = JSON["title"] as? String, poster_path = JSON["poster_path"] as? String, url = NSURL(string:"https://image.tmdb.org/t/p/w500\(poster_path)"), data = NSData(contentsOfURL: url), image = UIImage(data: data) else {
            return nil
        }
        
        self.id = id
        self.description = title
        self.posterView = UIImageView(image: image)
    }
}