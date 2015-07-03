//
//  WatchlistItemViewController.swift
//  MyMovies
//
//  Created by Jelle De Bock on 3/07/15.
//  Copyright (c) 2015 Jelle De Bock. All rights reserved.
//

import UIKit

class WatchlistItemViewController: UIViewController {
    @IBOutlet var name: UILabel!
    @IBOutlet var year: UILabel!
    @IBOutlet var cover: UIImageView!
    @IBOutlet var plot: UITextView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var rating: HCSStarRatingView!
    
    var internet: Bool? = Reachablity.checkReachability()
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var movieTitle:String = ""
    
    var model:Movie?=nil
    {
        didSet{
            self.spinner?.startAnimating()
            updateUI()
        }
    }
    
    @IBAction func rate(sender: HCSStarRatingView) {
        if model != nil
        {
            var bool = WatchlistRepo(context: appDelegate.managedObjectContext!).rate(model!, rating: Int(rating.value*2))
            println("Changed rating to \(WatchlistRepo(context: appDelegate.managedObjectContext!).getRating(model!))")
        }
        
    }
    
    func updateUI(){
        if self.model != nil{
            self.name.text = model!.title
            self.year.text = model!.year
            self.plot.text = model!.plot
            
            var image = UIImage(named: "noimage")
            
            var rating = WatchlistRepo(context: appDelegate.managedObjectContext!).getRating(model!)
            println("Rating returned from model \(rating)")
            
            self.rating.value = CGFloat(rating)/2.0
            
            if(model!.cover != nil)
            {
                var qos:Int = Int(QOS_CLASS_USER_INITIATED.value)
                dispatch_async(dispatch_get_global_queue(qos, 0)) {
                    var data: NSData? = nil
                    var url:NSURL?=NSURL(string: self.model!.cover!)
                    if url != nil
                    {
                        data = NSData(contentsOfURL: url!)
                        if(data != nil)
                        {
                            image = UIImage(data: data!)
                        }
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        self.cover.image = image
                    }
                }
            }
            else
            {
                self.cover.image = image
            }
        }
        self.spinner.stopAnimating()
    }
    
    func noConnectionUI()
    {
        self.name.text = ":( No internet connection"
        self.year.text = ""
        self.plot.text = ""
        self.rating = nil
        self.cover = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if internet == true
        {
            var mp =  MovieParser()
            model = mp.getMovie(movieTitle)
        }
        else
        {
            noConnectionUI()
        }
    }

}
