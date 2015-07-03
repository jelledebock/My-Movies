//
//  Movie.swift
//  My Movies
//
//  Created by Jelle De Bock on 29/06/15.
//  Copyright (c) 2015 Jelle De Bock. All rights reserved.
//

import Foundation

class Movie {
    var title :String?
    var year :String?
    var rated :String?
    var duration :String?
    var genre : String?
    var director : String?
    var cast : String?
    var plot: String?
    var cover: String?
    
    private let pegiRating = [
        "PG-3" : "pegi3.gif",
        "PG-7":  "pegi7.gif",
        "PG-12" : "pegi12.gif",
        "PG-16" : "pegi16.gif",
        "PG-18" : "pegi18.gif"
    ]
    
    init(json: NSDictionary)
    {
        self.title = json["Title"] as? String
        self.year = json["Year"] as? String
        pegi = json["Rated"] as? String
        self.duration = json["Runtime"] as? String
        self.genre = json["Genre"] as? String
        self.director = json["Director"] as? String
        self.cast = json["Cast"] as? String
        self.plot = json["Plot"] as? String
        self.cover = json["Poster"] as? String
        
    }
    
    init()
    {
    
    }
    
    var pegi:String?{
        get{
            return rated
        }
        set{
            if newValue != nil
            {
                rated = pegiRating[newValue!]
            }
        }
    }
    
    func toString() -> String{
        return "Movie with title \(title!) and produced in \(year!) with cover url of \(cover!)"
    }
}

