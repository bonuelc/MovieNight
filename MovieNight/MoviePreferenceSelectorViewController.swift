//  The MIT License (MIT)
//
//  Copyright (c) 2015 Yalantis
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

//
//  MoviePreferenceSelectorViewController.swift
//  MovieNight
//
//  Created by Christopher Bonuel on 11/10/16.
//  Copyright © 2016 Christopher Bonuel. All rights reserved.
//

import UIKit
import Koloda

class MoviePreferenceSelectorViewController: UIViewController, PreferenceSelector {
    
    @IBOutlet weak var movieView: KolodaView!
    
    var itemsSelected: [Selectable] = []
    
    var dataSource: PreferenceSelectorDataSource?
    var delegate: PreferenceSelectorDelegate?
    var selectionPhase: Int?
    var user_id: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        movieView.dataSource = self
    }
}

extension MoviePreferenceSelectorViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(koloda: KolodaView) -> UInt {
        
        guard let dataSource = dataSource, selectionPhase = selectionPhase else {
            return UInt(0)
        }
        
        return UInt(dataSource.preferenceSelector(self, numberOfItemsInSection: selectionPhase))
    }
    
    func koloda(koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        
        guard let dataSource = dataSource, selectionPhase = selectionPhase else {
            return UIView()
        }
        
        let index = Int(index)
        let indexPath = NSIndexPath(forRow: index, inSection: selectionPhase)
        guard let movie = dataSource.preferenceSelector(self, itemForRowAtIndexPath: indexPath) as? Movie else {
            return UIView()
        }
        
        return movie.posterView
    }
}

extension MoviePreferenceSelectorViewController: KolodaViewDelegate {}