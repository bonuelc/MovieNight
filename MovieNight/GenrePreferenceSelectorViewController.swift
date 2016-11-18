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
    var selectionPhase: Int?
    var user_id: Int?

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension GenrePreferenceSelectorViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let dataSource = dataSource, selectionPhase = selectionPhase else {
            let numberOfCellsForTesting = 20
            return numberOfCellsForTesting
        }
        
        return dataSource.preferenceSelector(self, numberOfItemsInSection: selectionPhase)
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
        
        let indexPath = NSIndexPath(forRow: indexPath.row, inSection: selectionPhase)
        
        cell.textLabel?.text = dataSource.preferenceSelector(self, itemForRowAtIndexPath: indexPath).description
        
        return cell
    }
}