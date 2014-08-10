//
//  MusicSearchController.swift
//  MusicStash
//
//  Created by Anton Gorskiy on 07.08.14.
//  Copyright (c) 2014 VeelooX. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class MusicSearchController: UITableViewController, UISearchDisplayDelegate, UISearchBarDelegate {

    var musicList:NSArray! = NSArray()
    var stashedMusic:NSArray!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let app = UIApplication.sharedApplication().delegate as AppDelegate
        let context:NSManagedObjectContext = app.managedObjectContext
        
        let request = NSFetchRequest(entityName: "Songs")
        request.returnsObjectsAsFaults = false
        //        request.predicate = NSPredicate(format: "title = %@", "Women")
        request.sortDescriptors = [
            NSSortDescriptor(key: "date_added", ascending: false)
        ]
        
        let results:Array<NSManagedObject> = context.executeFetchRequest(request, error: nil) as Array<NSManagedObject>
        
        stashedMusic = results.map({
            (item:NSManagedObject) -> Int in
            return item.valueForKey("id") as Int
        })
        
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        
        self.title = "Search"
        
        println("search loaded")        
        
        
    }

    func searchMusicByQuery(query:String){
        let req = VKRequest(method: "audio.search", andParameters: [
                "q": query,
                "auto_complete": 1,
                "sort": 2
                ], andHttpMethod: "GET")
        
        println("starting search for", query)
        
        req.executeWithResultBlock({ (response:VKResponse!) -> Void in
            
           // self.searchDisplayController.searchBar.text = query
            
            
            
            let res = response.json as NSDictionary
            self.musicList = res["items"] as Array<AnyObject>
            self.tableView.reloadData()
            
            
            
            }, errorBlock: { (err) -> Void in
                println(err)
        })
    }
    
    @IBAction func fetchMyMusic(){
        let req = VKRequest(method: "audio.get", andParameters: [
                "count": 1000
            ], andHttpMethod: "GET")
        
        req.executeWithResultBlock({ (response:VKResponse!) -> Void in
            
            let res = response.json as NSDictionary
            self.musicList = res["items"] as Array<AnyObject>
            self.tableView.reloadData()
            
            }, errorBlock: { (err) -> Void in
                println(err)
        })

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return musicList.count
    }

    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("music_search_cell", forIndexPath: indexPath) as MusicSearchCell

        cell.metaData = musicList[indexPath.row] as NSDictionary
        cell.isStashed = stashedMusic.containsObject(cell.metaData["id"] as Int)
        
        return cell
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar!) {
        self.searchMusicByQuery(searchBar.text)
        searchBar.resignFirstResponder()
        //self.searchDisplayController.setActive(false, animated: false)

    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let app = UIApplication.sharedApplication().delegate as AppDelegate
        
        app.nowPlaying.queue = musicList as Array<NSDictionary>
        app.nowPlaying.currentTrack = indexPath.row
        app.nowPlaying.startPlaying()
        //self.navigationController.pushViewController(app.nowPlaying, animated: true)
        
        self.tabBarController.selectedIndex = 3
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView!) {
        searchBar.resignFirstResponder()
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
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
    override func tableView(tableView: UITableView!, moveRowAtIndexPath fromIndexPath: NSIndexPath!, toIndexPath: NSIndexPath!) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    */

}
    