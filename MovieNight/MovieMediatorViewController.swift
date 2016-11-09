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
    
    lazy var movieDatabaseClient: MovieDatabaseClient = {
        return MovieDatabaseClient()
    }()

    @IBOutlet weak var user1Button: UIButton!
    @IBOutlet weak var user2Button: UIButton!
    @IBOutlet weak var directionsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchGenres()
    }
    
    @IBAction func user1ButtonTapped(sender: UIButton) {
        performSegueWithIdentifier("genrePreferenceSegue", sender: sender)
    }
    
    @IBAction func user2ButtonTapped(sender: UIButton) {
        performSegueWithIdentifier("genrePreferenceSegue", sender: sender)
    }
    
    func fetchGenres() {
        movieDatabaseClient.fetchGenres { result in
            switch result {
            case .Success(let genres): self.genresFromWhichToSelect = genres
            case .Failure(let error as NSError): print(error)
            default: break // TODO: why does the compiler think this is necessary?
            }
        }
    }
}
