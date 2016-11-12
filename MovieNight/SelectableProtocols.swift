//
//  SelectableProtocols.swift
//  MovieNight
//
//  Created by Christopher Bonuel on 11/11/16.
//  Copyright © 2016 Christopher Bonuel. All rights reserved.
//

import Foundation

protocol Selectable {
    var id: Int { get set }
    var description: String { get set }
}

protocol Entity: Selectable {}
protocol Filter: Selectable {}