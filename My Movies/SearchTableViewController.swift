//
//  SearchTableViewController.swift
//  My Movies
//
//  Created by Jelle De Bock on 29/06/15.
//  Copyright (c) 2015 Jelle De Bock. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var search: UITextField!
    {
        didSet{
            search.delegate = self
        }
    }
    
    var query: String? = nil
        {
        didSet{
            search.text = query
            model?.removeAll()
            refresh()
        }
    }

    var previous: [Movie]? = nil
    var model: [Movie]? = nil
    var internet: Bool = Reachablity.checkReachability()
    
    @IBAction func refresh() {
        self.refreshControl?.beginRefreshing()
        internet = Reachablity.checkReachability()
        if internet
        {
            println("Searching for query \(self.query)...")
            self.tableView.backgroundView = nil
            let parser = MovieParser()
            let qos:Int = Int(QOS_CLASS_USER_INITIATED.value)
            dispatch_async(dispatch_get_global_queue(qos, 0)) {
                var movies = parser.getMovieList(self.query!.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
                if movies.count != 0
                {
                    self.previous = self.model
                    self.model = movies
                    dispatch_async(dispatch_get_main_queue()) {
                        self.updateUI()
                        self.refreshControl!.endRefreshing()
                    }
                }
                else
                {
                    self.clearTable()
                    self.refreshControl!.endRefreshing()
                }
            }
        }
        else
        {
            clearTable()
        }


    }
    
    func clearTable()
    {
        println("No movies found, deleting old rows")
        model = nil
        tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    func updateUI()
    {
        if model != nil{
            println("Found \(self.model!.count) movies")
            tableView.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.query = "Harry Potter"
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.search
        {
            textField.resignFirstResponder()
            
            
            if self.search.text != ""
            {
                self.model=nil
                clearTable()
                query = textField.text
            }
            else
            {
                self.model = nil
                clearTable()
            }
        }
        return true
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier!
        {
          case "Show movie":
            var mp = MovieParser()
            let navigationController = segue.destinationViewController as! UINavigationController
            let vc = navigationController.topViewController as! MovieViewController
            //cast to SearchTableViewCell
            let cell = sender as! SearchTableViewCell
            var title = cell.title.text
            vc.movieTitle = title!.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            
        default:
            break
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections
        if model != nil
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
                noData.text = ":( No movies found"
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
        return model?.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Movie", forIndexPath: indexPath) as! SearchTableViewCell
        cell.cover.image = nil
        cell.spinner.startAnimating()
        cell.title.text = model![indexPath.row].title
        var year = "\(model![indexPath.row].year!)"
        cell.year.text = year ?? "unknown"
        
        if let cover = model![indexPath.row].cover
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

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