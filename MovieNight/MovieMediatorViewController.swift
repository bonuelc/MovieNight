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

enum SegueIdentifier {
    static let GenrePreference = "genrePreferenceSegue"
    static let MoviePreference = "moviePreferenceSegue"
    static let ResultsTableView = "resultsTableViewSegue"
}

class MovieMediatorViewController: UIViewController {
    
    var genresFromWhichToSelect = [Genre]() {
        didSet {
            performSegueWithIdentifier(SegueIdentifier.GenrePreference, sender: self)
        }
    }
    var moviesFromWhichToSelect = [Movie]() {
        didSet {
            performSegueWithIdentifier(SegueIdentifier.MoviePreference, sender: self)
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
            case .Failure(let error as NSError): self.presentAlertController("Unable to retrieve genres", message: error.localizedDescription)
            default: break // TODO: why does the compiler think this is necessary?
            }
        }
    }
    
    func fetchMovies(genre_ids: Int...) {
        movieDatabaseClient.fetchMovies(genre_ids) { result in
            switch result {
            case .Success(let movies): self.moviesFromWhichToSelect = movies
            case .Failure(let error as NSError): self.presentAlertController("Unable to retrieve movies", message: error.localizedDescription)
            default: break // TODO: why does the compiler think this is necessary?
            }
        }
    }
    
    func presentAlertController(title: String, message: String?) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(dismissAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func startButtonTapped(sender: UIButton) {
        if genresFromWhichToSelect.count == 0 {
            fetchGenres()
        } else {
            performSegueWithIdentifier(SegueIdentifier.GenrePreference, sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        guard let navController = segue.destinationViewController as? UINavigationController else { return }
        
        if let genrePreferenceSelectorVC = navController.topViewController as? GenrePreferenceSelectorViewController {
            genrePreferenceSelectorVC.dataSource = self
            genrePreferenceSelectorVC.delegate = self
            genrePreferenceSelectorVC.selectionPhase = .Genre
            if sender is MovieMediatorViewController {
                genrePreferenceSelectorVC.user_id = 0
            } else if let sender = sender as? GenrePreferenceSelectorViewController, user_id = sender.user_id {
                genrePreferenceSelectorVC.user_id = user_id + 1
            }
        } else if let moviePreferenceSelectorViewController = navController.topViewController as? MoviePreferenceSelectorViewController {
            moviePreferenceSelectorViewController.dataSource = self
            moviePreferenceSelectorViewController.delegate = self
            moviePreferenceSelectorViewController.selectionPhase = .Movie
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
    
    func preferenceSelector(preferenceSelector: PreferenceSelector, numberOfItemsInSelectionPhase selectionPhase: PreferenceSelectionPhase) -> Int {
        
        return selectionPhase == .Genre ? genresFromWhichToSelect.count : moviesFromWhichToSelect.count
    }
    
    func preferenceSelector(preferenceSelector: PreferenceSelector, itemForRowAtIndexPath indexPath: NSIndexPath) -> Selectable {
        
        guard let selectionPhase = preferenceSelector.selectionPhase else {
            return genresFromWhichToSelect[indexPath.row] // TODO: return a different dummy value
        }
        
        if selectionPhase == .Genre {
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
        
        if selectionPhase == .Genre {
            
            guard let sender = preferenceSelector as? GenrePreferenceSelectorViewController else {
                return
            }
            
            genresSelected[user_id] = preferenceSelector.itemsSelected.map { $0 as! Genre }
            
            if user_id != last_user_id {
                performSegueWithIdentifier(SegueIdentifier.GenrePreference, sender: sender)
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
                performSegueWithIdentifier(SegueIdentifier.MoviePreference, sender: sender)
            } else {
                // show results as soon as a round of selections produce at least one movie in common
                if !moviesAgreedUpon.isEmpty {
                    performSegueWithIdentifier(SegueIdentifier.ResultsTableView, sender: sender)
                }
                else if let genreID = nextGenreIDToFetch {
                    fetchMovies(genreID)
                } else {
                    // no movies in common
                    performSegueWithIdentifier(SegueIdentifier.ResultsTableView, sender: sender)
                }
            }
        }
    }
}

