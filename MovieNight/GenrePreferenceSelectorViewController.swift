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

