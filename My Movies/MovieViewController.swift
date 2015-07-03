//
//  MovieViewController.swift
//  My Movies
//
//  Created by Jelle De Bock on 30/06/15.
//  Copyright (c) 2015 Jelle De Bock. All rights reserved.
//

import UIKit

class MovieViewController: UIViewController {
    var movieTitle  = ""
    var model: Movie? = nil
    var internet: Bool? = Reachablity.checkReachability()
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var inWatchlist: Bool? = false
    var isRated: Bool? = false
    
    
    @IBOutlet var movieLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var releaseLabel: UILabel!
    @IBOutlet var genreLabel: UILabel!
    @IBOutlet var castLabel: UILabel!
    @IBOutlet var plot: UITextView!
    @IBOutlet var coverImage: UIImageView!
    @IBOutlet var WatchlistButton: UIButton!
    @IBOutlet var openWatchlist: UIButton!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (internet == true)
        {
            var mp = MovieParser()
            self.spinner.startAnimating()
            self.model = mp.getMovie(movieTitle)
            updateUI()
        }
        else
        {
            noConnectionUI()
        }
     
        // Do any additional setup after loading the view.
    }

    func updateUI()
    {
        if self.model != nil
        {
            self.movieLabel.text = model!.title
            self.durationLabel.text = model!.duration
            self.releaseLabel.text = model!.year
            self.genreLabel.text = model!.genre
            self.castLabel.text = model!.cast
            self.plot.text = model!.plot
            
            self.inWatchlist = WatchlistRepo(context: appDelegate.managedObjectContext!).isInWatchlist(model!)
            self.isRated = WatchlistRepo(context: appDelegate.managedObjectContext!).isRated(model!)
            
            self.WatchlistButton.hidden = self.inWatchlist!
            self.openWatchlist.hidden = !self.WatchlistButton.hidden
            
            var image = UIImage(named: "noimage")
            if(model!.cover != nil){
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
                        self.coverImage.image = image
                    }
                }
            }
            else
            {
                self.coverImage.image = image
            }
            self.spinner.stopAnimating()
        }
    }
    
    func noConnectionUI()
    {
        self.movieLabel.text = ":( No internet connection"
        self.durationLabel.text = ""
        self.releaseLabel.text = ""
        self.genreLabel.text = ""
        self.castLabel.text = ""
        self.plot.text = ""
        self.WatchlistButton.hidden = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier!
        {
            case "Show watchlist":
                let vc = segue.destinationViewController as! WatchlistItemViewController
                var title = self.movieLabel.text
                vc.movieTitle = title!.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        default:
            break
        }
    }
    @IBAction func addToWatchlist(sender: UIButton) {
        var success = false
        if model != nil
        {
            var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            var repo = WatchlistRepo(context: appDelegate.managedObjectContext!)
            success=repo.createItem(model!)
        }
        if success == true
        {
            showAlert("Successfully added to watchlist!")
            self.WatchlistButton.hidden=true
        }
        else
        {
            showAlert("Error... Not added to watchlist.")
        }
    }

    func showAlert(message: String)
    {
        let alert:UIAlertController = UIAlertController(title: "Adding to watchlist...", message: message, preferredStyle:.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
            println("ok button clicked")
        }))
        self.presentViewController(alert, animated:true, completion:nil);
   
    }
}
