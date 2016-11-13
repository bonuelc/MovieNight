//
//  MovieMediatorViewController.swift
//  MovieNight
//
//  Created by Christopher Bonuel on 11/9/16.
//  Copyright © 2016 Christopher Bonuel. All rights reserved.
//

import UIKit

class MovieMediatorViewController: UIViewController {
    
    var genresFromWhichToSelect = [Genre]()
    var moviesFromWhichToSelect = [Movie]()
    
    // count = 1 per user
    var genresSelected = [[Genre]](count: 2, repeatedValue: [])
    var moviesSelected = [[Movie]](count: 2, repeatedValue: [])

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
