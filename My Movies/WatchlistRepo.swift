//
//  WatchlistRepo.swift
//  My Movies
//
//  Created by Jelle De Bock on 30/06/15.
//  Copyright (c) 2015 Jelle De Bock. All rights reserved.
//

import UIKit
import CoreData

class  WatchlistRepo{
    var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext)
    {
        self.context = context
    }
    
    func createItem(movie: Movie) -> Bool
    {
        let item = NSEntityDescription.insertNewObjectForEntityForName("Watchlist", inManagedObjectContext: self.context ) as! Watchlist
        
        item.title = movie.title!
        item.cover = movie.cover!
        item.year = movie.year!
        item.genre = movie.genre!
        item.rating = -1
        
        return self.context.save(nil)
    }
    
    func allItems() -> [Movie]?
    {
        let fetchRequest = NSFetchRequest(entityName: "Watchlist")
        let fetchedEntities = self.context.executeFetchRequest(fetchRequest, error: nil) as! [Watchlist]
        
        var movies = [Movie]()
        
        for watchlist in fetchedEntities
        {
            var movie = Movie()
            
            movie.title = watchlist.title
            movie.year = watchlist.year
            movie.cover = watchlist.cover
            movie.genre = watchlist.genre
            
            movies.append(movie)
        }
        
        
        return movies
    }
    
    func getMovie(title: String) -> Movie?
    {
        let movies = self.allItems()
        
        if movies != nil{
            for movie:Movie in movies!
            {
                if movie.title == title
                {
                    return movie
                }
            }
        }
        return nil
    }
    
    func rate(movie: Movie, rating: Int) -> Bool
    {
        let fetchRequest = NSFetchRequest(entityName: "Watchlist")
        let fetchedEntities = self.context.executeFetchRequest(fetchRequest, error: nil) as! [Watchlist]
        
        for watchlist in fetchedEntities
        {
            if watchlist.title == movie.title
            {
                watchlist.watched = true
                watchlist.rating = rating
                return self.context.save(nil)
            }
        }
        
        return false
    }
    
    func getRating(movie: Movie) -> Int
    {
        let fetchRequest = NSFetchRequest(entityName: "Watchlist")
        let fetchedEntities = self.context.executeFetchRequest(fetchRequest, error: nil) as! [Watchlist]
        
        for watchlist in fetchedEntities
        {
            if watchlist.title == movie.title
            {
                if watchlist.watched == true
                {
                    return watchlist.rating as Int
                }
            }
        }
        return 0
    }
    
    
    func deleteItem(movie: Movie) -> Bool
    {
        let fetchRequest = NSFetchRequest(entityName: "Watchlist")
        let fetchedEntities = self.context.executeFetchRequest(fetchRequest, error: nil) as! [Watchlist]
        
        for watchlist in fetchedEntities
        {
            if watchlist.title == movie.title
            {
                self.context.deleteObject(watchlist)
                return self.context.save(nil)
            }
        }
        return false
    }
    
    func isInWatchlist(movie: Movie) -> Bool
    {
        if getMovie(movie.title!) != nil
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func isRated(movie: Movie) -> Bool
    {
        let fetchRequest = NSFetchRequest(entityName: "Watchlist")
        let fetchedEntities = self.context.executeFetchRequest(fetchRequest, error: nil) as! [Watchlist]
        
        for watchlist in fetchedEntities
        {
            if watchlist.title == movie.title
            {
                return (watchlist.watched == true && watchlist.rating != -1)
            }
        }
        return false
    }
    
    func deleteAll() -> Bool{
        let request = NSFetchRequest(entityName: "Watchlist")
        let items = context.executeFetchRequest(request, error: nil)!
        
        for item in items
        {
            self.context.deleteObject(item as! NSManagedObject)
        }
        return true
    }
}