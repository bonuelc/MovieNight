//
//  MovieMediatorViewController.swift
//  MovieNight
//
//  Created by Christopher Bonuel on 11/9/16.
//  Copyright © 2016 Christopher Bonuel. All rights reserved.
//

import UIKit

extension Array {
    func all(predicate: (element: Element) -> Bool) -> Bool {
        for item in self {
            if !predicate(element: item) {
                return false
            }
        }
        return true
    }
}

let numberOfUsers = 2

class MovieMediatorViewController: UIViewController {
    
    var genresFromWhichToSelect = [Genre]() {
        didSet {
            performSegueWithIdentifier("genrePreferenceSegue", sender: self)
        }
    }
    var moviesFromWhichToSelect = [Movie]() {
        didSet {
            performSegueWithIdentifier("moviePreferenceSegue", sender: self)
        }
    }
    
    var genresSelected = [[Genre]](count: numberOfUsers, repeatedValue: [])
    var moviesSelected = [[Movie]](count: numberOfUsers, repeatedValue: [])
    
    var last_user_id: Int {
        return numberOfUsers - 1
    }
    
    lazy var movieDatabaseClient: MovieDatabaseClient = {
        return MovieDatabaseClient()
    }()
    
    @IBOutlet weak var startButton: UIButton!
    
    lazy var genreIDsAgreedUpon: [Int] = {
        let genresIDs1 = self.genresSelected[0].map{ $0.id }
        let genresIDs2 = self.genresSelected[1].map{ $0.id }
        
        let set1 = Set(genresIDs1)
        let set2 = Set(genresIDs2)
        
        return Array(set1.intersect(set2))
    }()
    
    lazy var genreIDsDisgreedUpon: [Int] = {
        
        let genresIDs1 = self.genresSelected[0].map{ $0.id }
        let genresIDs2 = self.genresSelected[1].map{ $0.id }
        
        let set1 = Set(genresIDs1)
        let set2 = Set(genresIDs2)
        
        let uniqueGenresIDs1 = Array(set1.subtract(set2))
        let uniqueGenresIDs2 = Array(set2.subtract(set1))
        
        // interleave uniqueGenresIDs1 and uniqueGenresIDs2
        return zip(uniqueGenresIDs1, uniqueGenresIDs2).flatMap { [$0, $1] }
    }()
    
    var nextGenreIDToFetch: Int? {
        
        if let genre = genreIDsAgreedUpon.popLast() {
            return genre
        }
        
        return genreIDsDisgreedUpon.popLast()
    }
    
    var moviesAgreedUpon: [String] {
        
        let movieDescriptions1 = self.moviesSelected[0].map{ $0.description }
        let movieDescriptions2 = self.moviesSelected[1].map{ $0.description }
        
        let set1 = Set(movieDescriptions1)
        let set2 = Set(movieDescriptions2)
        
        return Array(set1.intersect(set2))
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
    
    func fetchMovies(genre_ids: Int...) {
        movieDatabaseClient.fetchMovies(genre_ids) { result in
            switch result {
            case .Success(let movies): self.moviesFromWhichToSelect = movies
            case .Failure(let error as NSError): print(error)
            default: break // TODO: why does the compiler think this is necessary?
            }
        }
    }
    
    @IBAction func startButtonTapped(sender: UIButton) {
        fetchGenres()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        guard let navController = segue.destinationViewController as? UINavigationController else { return }
        
        if let genrePreferenceSelectorVC = navController.topViewController as? GenrePreferenceSelectorViewController {
            genrePreferenceSelectorVC.dataSource = self
            genrePreferenceSelectorVC.delegate = self
            genrePreferenceSelectorVC.selectionPhase = 0
            if sender is MovieMediatorViewController {
                genrePreferenceSelectorVC.user_id = 0
            } else if let sender = sender as? GenrePreferenceSelectorViewController, user_id = sender.user_id {
                genrePreferenceSelectorVC.user_id = user_id + 1
            }
        } else if let moviePreferenceSelectorViewController = navController.topViewController as? MoviePreferenceSelectorViewController {
            moviePreferenceSelectorViewController.dataSource = self
            moviePreferenceSelectorViewController.delegate = self
            moviePreferenceSelectorViewController.selectionPhase = 1
            if sender is MovieMediatorViewController {
                moviePreferenceSelectorViewController.user_id = 0
            } else if let sender = sender as? MoviePreferenceSelectorViewController, user_id = sender.user_id {
                if user_id == last_user_id {
                    // restart selection from a new set of movies
                    moviePreferenceSelectorViewController.user_id = 0
                } else {
                    moviePreferenceSelectorViewController.user_id = user_id + 1
                }
            }
        } else if let resultsTableVC = navController.topViewController as? ResultsTableViewController {
            resultsTableVC.data = moviesAgreedUpon
        }
    }
}

extension MovieMediatorViewController: PreferenceSelectorDataSource {
    
    func preferenceSelector(preferenceSelector: PreferenceSelector, numberOfItemsInSection section: Int) -> Int {
        
        guard let selectionPhase = preferenceSelector.selectionPhase else {
            return 0
        }
        
        return selectionPhase == 0 ? genresFromWhichToSelect.count : moviesFromWhichToSelect.count
    }
    
    func preferenceSelector(preferenceSelector: PreferenceSelector, itemForRowAtIndexPath indexPath: NSIndexPath) -> Selectable {
        
        guard let selectionPhase = preferenceSelector.selectionPhase else {
            return genresFromWhichToSelect[indexPath.row] // TODO: return a different dummy value
        }
        
        if selectionPhase == 0 {
            return genresFromWhichToSelect[indexPath.row]
        } else {
            return moviesFromWhichToSelect[indexPath.row]
        }
    }
}

extension MovieMediatorViewController: PreferenceSelectorDelegate {
    
    func preferenceSelectorDidFinishSelectingPreferences(preferenceSelector: PreferenceSelector) {
        
        if let preferenceSelector = preferenceSelector as? UIViewController {
            preferenceSelector.dismissViewControllerAnimated(true, completion: nil)
        }
        
        guard let selectionPhase = preferenceSelector.selectionPhase, user_id = preferenceSelector.user_id else {
            return
        }
        
        if selectionPhase == 0 {
            
            guard let sender = preferenceSelector as? GenrePreferenceSelectorViewController else {
                return
            }
            
            genresSelected[user_id] = preferenceSelector.itemsSelected.map { $0 as! Genre }
            
            if user_id != last_user_id {
                performSegueWithIdentifier("genrePreferenceSegue", sender: sender)
            } else {
                guard let highestPriorityGenreID = nextGenreIDToFetch else {
                    fatalError("nextGenreIDToFetch returned nil the first time it was called.")
                }
                fetchMovies(highestPriorityGenreID)
            }
            
        } else {
            
            guard let sender = preferenceSelector as? MoviePreferenceSelectorViewController else {
                return
            }
            
            moviesSelected[user_id].appendContentsOf(preferenceSelector.itemsSelected.map { $0 as! Movie })
            
            if user_id != last_user_id {
                performSegueWithIdentifier("moviePreferenceSegue", sender: sender)
            } else {
                if let genreID = nextGenreIDToFetch {
                    fetchMovies(genreID)
                } else {
                    performSegueWithIdentifier("resultsTableViewSegue", sender: sender)
                }
            }
        }
    }
}

