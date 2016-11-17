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
    
    var genresFromWhichToSelect = [Genre]()
    var moviesFromWhichToSelect = [Movie]()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchGenres()
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
        performSegueWithIdentifier("genrePreferenceSegue", sender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let genrePreferenceSelectorVC = segue.destinationViewController as? GenrePreferenceSelectorViewController {
            genrePreferenceSelectorVC.dataSource = self
            genrePreferenceSelectorVC.delegate = self
            genrePreferenceSelectorVC.selectionPhase = 0
//            genrePreferenceSelectorVC.user_id = button == user1Button ? 0 : 1
        } else if let moviePreferenceSelectorViewController = segue.destinationViewController as? MoviePreferenceSelectorViewController {
            moviePreferenceSelectorViewController.dataSource = self
            moviePreferenceSelectorViewController.delegate = self
            moviePreferenceSelectorViewController.selectionPhase = 1
            moviePreferenceSelectorViewController.user_id = 0
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
            genresSelected[user_id] = preferenceSelector.itemsSelected.map { $0 as! Genre }
        } else {
            moviesSelected[user_id] = preferenceSelector.itemsSelected.map { $0 as! Movie }
        }
    }
}

