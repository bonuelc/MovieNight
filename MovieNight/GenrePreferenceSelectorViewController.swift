//
//  GenrePreferenceSelectorViewController
//  MovieNight
//
//  Created by Christopher Bonuel on 11/7/16.
//  Copyright © 2016 Christopher Bonuel. All rights reserved.
//

import UIKit

class GenrePreferenceSelectorViewController: UIViewController, PreferenceSelector {
    
    var itemsSelected: [Selectable] = []
        
    var dataSource: PreferenceSelectorDataSource?
    var delegate: PreferenceSelectorDelegate?
    var selectionPhase: PreferenceSelectionPhase?
    var user_id: Int?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var directionsLabel: UILabel!

    var numberOfItemsSelected = 0 {
        didSet {
            directionsLabel.hidden = numberOfItemsSelected == numberOfItemsToSelect
            updateDirectionsLabel()
        }
    }
    let numberOfItemsToSelect = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user_id = user_id {
            title = "User \(user_id + 1)"
        }

        tableView.dataSource = self
        tableView.delegate = self

        updateDirectionsLabel()
    }

    func updateDirectionsLabel() {

        directionsLabel.text = "\(numberOfItemsSelected) out of \(numberOfItemsToSelect) selected"
    }
    
    @IBAction func doneButtonTapped() {
        
        if let dataSource = dataSource, indexPaths = tableView.indexPathsForSelectedRows {
            itemsSelected = dataSource.preferenceSelector(self, itemsForRowsAtIndexPaths: indexPaths)
        }
        
        if let delegate = delegate {
            delegate.preferenceSelectorDidFinishSelectingPreferences(self)
        }
    }
}

extension GenrePreferenceSelectorViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let dataSource = dataSource, selectionPhase = selectionPhase else {
            let numberOfCellsForTesting = 20
            return numberOfCellsForTesting
        }
        
        return dataSource.preferenceSelector(self, numberOfItemsInSelectionPhase: selectionPhase)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let dataSource = dataSource, selectionPhase = selectionPhase else {
            let cellForTesting = UITableViewCell()
            cellForTesting.textLabel?.text = "\(indexPath.row)"
            return cellForTesting
        }

        guard let cell = tableView.dequeueReusableCellWithIdentifier("genreCell") else {
            return UITableViewCell()
        }
        
        let indexPath = NSIndexPath(forRow: indexPath.row, inSection: selectionPhase.rawValue)
        
        cell.textLabel?.text = dataSource.preferenceSelector(self, itemForRowAtIndexPath: indexPath).description
        
        return cell
    }
}

extension GenrePreferenceSelectorViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        guard let cell = tableView.cellForRowAtIndexPath(indexPath) else {
            return
        }

        if numberOfItemsSelected < numberOfItemsToSelect {

            cell.accessoryType = .Checkmark

            numberOfItemsSelected += 1

        } else {

            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
    }

    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {

        guard let cell = tableView.cellForRowAtIndexPath(indexPath) else {
            return
        }

        cell.accessoryType = .None

        numberOfItemsSelected -= 1
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

        cell.accessoryType = cell.selected ? .Checkmark : .None
    }
}
