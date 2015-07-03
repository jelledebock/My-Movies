//
//  MovieParser.swift
//  My Movies
//
//  Created by Jelle De Bock on 29/06/15.
//  Copyright (c) 2015 Jelle De Bock. All rights reserved.
//

import Foundation


class MovieParser{
    struct OmdbapiSettings{
        static let url: String = "https://www.omdbapi.com"
    }
    
    func getMovie(query: String) -> Movie
    {
        var movie: Movie? = nil
        var url = NSURL(string: "\(OmdbapiSettings.url)?t=\(query)")
        //Fetch the url
        var data = NSData(contentsOfURL: url!)
        //Validate our response from the server
        if let json: NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary {
            movie = Movie(json: json)
        }
        
        return movie!
    }
    
    func getMovieList(query: String) ->[Movie]
    {
        var movies: [Movie]? = Array()
        var url = NSURL(string: "\(OmdbapiSettings.url)?s=\(query)&y")
        //Fetch the url
        var data = NSData(contentsOfURL: url!)
        //Loop through search results
        if let json: NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary {
            if (json["Error"] == nil)
            {
                let movieList = json["Search"] as! [NSDictionary]
                
                for movie in movieList
                {
                    movies?.append(getMovie(movie["Title"]!.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!))
                }
            }
        }

        
        return movies!
    }
    
}
