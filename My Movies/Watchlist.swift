//
//  Watchlist.swift
//  MyMovies
//
//  Created by Jelle De Bock on 1/07/15.
//  Copyright (c) 2015 Jelle De Bock. All rights reserved.
//

import Foundation
import CoreData

@objc(Watchlist)
class Watchlist: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var cover: String
    @NSManaged var year: String
    @NSManaged var watched: NSNumber
    @NSManaged var rating: NSNumber
    @NSManaged var genre: String

}
