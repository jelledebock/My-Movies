//
//  WatchlistTableViewController.swift
//  My Movies
//
//  Created by Jelle De Bock on 29/06/15.
//  Copyright (c) 2015 Jelle De Bock. All rights reserved.
//

import UIKit

class WatchlistTableViewController: UITableViewController{
    var watchlist:[Movie]? = nil
    var internet = Reachablity.checkReachability()
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        //refresh(refreshControl!)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        refresh(refreshControl!)
    }
    
    func refresh()
    {
        watchlist?.removeAll(keepCapacity: false)
        watchlist = WatchlistRepo(context: appDelegate.managedObjectContext!).allItems()
        if watchlist != nil || watchlist?.count == 0
        {
            self.tableView.backgroundView = nil
            tableView.reloadData()
        }
        else
        {
            clearTable()
        }

        refreshControl?.endRefreshing()
    }
    

    @IBAction func refresh(sender: UIRefreshControl) {
        refresh()
    }
    
    func clearTable()
    {
        watchlist = nil
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        if watchlist != nil || watchlist?.count>0
        {
            return 1
        }
        else
        {
            var noData = UILabel(frame: CGRectMake(0,0,
                self.tableView.bounds.size.width,
                self.tableView.bounds.size.height))
            if internet
            {
                noData.text = "No movies on watchlist"
            }
            else
            {
                noData.text = "No internet available, make sure your internet is enabled."
            }
            
            noData.textAlignment = NSTextAlignment.Center
            noData.numberOfLines = 0
            noData.lineBreakMode = NSLineBreakMode.ByClipping
            noData.sizeToFit()
            self.tableView.backgroundView = noData
            return 0
        }
     
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if self.watchlist == nil || self.watchlist?.count==0
        {
            return 0
        }
        else
        {
            return self.watchlist!.count
        }
    }

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
    
        var deleteAction = UITableViewRowAction(style: .Default, title: "Delete") { (action, indexPath) -> Void in
            tableView.editing = false
            WatchlistRepo(context: self.appDelegate.managedObjectContext!).deleteItem(self.watchlist![indexPath.row])
            self.refresh()
        }
    
        return [deleteAction]
    }
  
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Watchlist") as! WatchlistTableViewCell
        
        var movie = watchlist?[indexPath.row]
        
        var genre = movie?.genre ?? "unknown genre"

        cell.title.text = movie?.title
        cell.year.text = movie?.year
        cell.genre.text = genre
        cell.cover.image = nil
        cell.spinner.startAnimating()
        
        if let cover = movie?.cover
        {
            if let url = NSURL(string: cover)
            {
                let qos:Int = Int(QOS_CLASS_USER_INITIATED.value)
                dispatch_async(dispatch_get_global_queue(qos, 0)) {
                    var data = NSData(contentsOfURL: url)
                    if data != nil
                    {
                        dispatch_async(dispatch_get_main_queue())
                            {
                                cell.cover.image = UIImage(data: data!)
                                cell.spinner.stopAnimating()
                        }
                    }
                    else
                    {
                        cell.cover.image = UIImage(named: "noimage")
                        cell.spinner.stopAnimating()
                    }
                }
            }
            
        }
        else
        {
            cell.cover.image = UIImage(named: "noimage")
            cell.spinner.stopAnimating()
        }
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier!
        {
            case "Show watchlist":
                let navigationController = segue.destinationViewController as! UINavigationController
                let vc = navigationController.topViewController as! WatchlistItemViewController
                //cast to SearchTableViewCell
                let cell = sender as! WatchlistTableViewCell
                var title = cell.title.text
                vc.movieTitle = title!.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        default:
            break
        }
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        // Intentionally blank. Required to use UITableViewRowActions
    }

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
