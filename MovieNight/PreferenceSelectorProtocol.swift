//
//  PreferenceSelectorProtocol.swift
//  MovieNight
//
//  Created by Christopher Bonuel on 11/11/16.
//  Copyright © 2016 Christopher Bonuel. All rights reserved.
//

import Foundation

enum PreferenceSelectionPhase: Int {
    case Genre
    case Movie
}

protocol PreferenceSelector {
    var itemsSelected: [Selectable] { get set }
    
    var dataSource: PreferenceSelectorDataSource? { get set }
    var delegate: PreferenceSelectorDelegate? { get set }
    var selectionPhase: PreferenceSelectionPhase? { get set }
    var user_id: Int? { get set }
}

protocol PreferenceSelectorDataSource {
    func preferenceSelector(preferenceSelector: PreferenceSelector, numberOfItemsInSelectionPhase selectionPhase: PreferenceSelectionPhase) -> Int
    func preferenceSelector(preferenceSelector: PreferenceSelector, itemForRowAtIndexPath indexPath: NSIndexPath) -> Selectable
    func preferenceSelector(preferenceSelector: PreferenceSelector, itemsForRowsAtIndexPaths indexPaths: [NSIndexPath]) -> [Selectable]
}

extension PreferenceSelectorDataSource {
    func preferenceSelector(preferenceSelector: PreferenceSelector, itemsForRowsAtIndexPaths indexPaths: [NSIndexPath]) -> [Selectable] {
        return indexPaths.map { self.preferenceSelector(preferenceSelector, itemForRowAtIndexPath: $0) }
    }
}

protocol PreferenceSelectorDelegate {
    func preferenceSelectorDidFinishSelectingPreferences(preferenceSelector: PreferenceSelector)
}

protocol FixedNumberPreferenceSelector: PreferenceSelector {
    var numberOfItemsSelected: Int { get set }
    var numberOfItemsToSelect: Int! { get set }
}

protocol YesOrNoPreferenceSelector: PreferenceSelector {}
