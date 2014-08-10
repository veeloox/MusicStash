//
//  MusicSavedController.swift
//  MusicStash
//
//  Created by Anton Gorskiy on 09.08.14.
//  Copyright (c) 2014 VeelooX. All rights reserved.
//

import UIKit
import CoreData

class MusicSavedController: UITableViewController {

    var musicList: Array<Songs> = []
    
    func loadLocalData(){
        let app = UIApplication.sharedApplication().delegate as AppDelegate
        let context:NSManagedObjectContext = app.managedObjectContext
        
        let request = NSFetchRequest(entityName: "Songs")
        request.returnsObjectsAsFaults = false
//        request.predicate = NSPredicate(format: "title = %@", "Women")
        request.sortDescriptors = [
            NSSortDescriptor(key: "date_added", ascending: false)
        ]
        
        musicList = context.executeFetchRequest(request, error: nil) as [Songs]
        
//         = results.map({
//            (item:NSManagedObject) -> NSDictionary in
//            return item.dictionaryWithValuesForKeys((item.entity.attributesByName as NSDictionary).allKeys)
//        })
        
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        self.refreshControl.endRefreshing()
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.loadLocalData()        
        
        self.refreshControl.addTarget(self, action: Selector("loadLocalData"), forControlEvents: UIControlEvents.ValueChanged)
    }

    @IBAction func editButtonPressed(sender: UIBarButtonItem) {
        if (self.tableView.editing){
            self.tableView.setEditing(false, animated: true)
        } else {
            self.tableView.setEditing(true, animated: true)
        }
        
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
        let cell = tableView.dequeueReusableCellWithIdentifier("music_saved_cell", forIndexPath: indexPath) as MusicSavedCell
        let song = musicList[indexPath.row]
        
        cell.metaData = song.dictionaryWithValuesForKeys((song.entity.attributesByName as NSDictionary).allKeys)
        
        return cell
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        
        if (!self.tableView.editing){
            let app = UIApplication.sharedApplication().delegate as AppDelegate
            
            app.nowPlaying.queue = musicList.map({
                (item:Songs) -> NSDictionary in
                return item.dictionaryWithValuesForKeys((item.entity.attributesByName as NSDictionary).allKeys)
            })
            
            app.nowPlaying.currentTrack = indexPath.row
            app.nowPlaying.startPlaying()
            //self.navigationController.pushViewController(app.nowPlaying, animated: true)
            
            self.tabBarController.selectedIndex = 3
        }
    }
    
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            let app = UIApplication.sharedApplication().delegate as AppDelegate
            let context:NSManagedObjectContext = app.managedObjectContext
            
            let song = musicList[indexPath.row]
            
            for ps in song.playlistRel {
                context.deleteObject(ps as PlaylistSong)
            }
            
            let filePath = app.stashRoot.stringByAppendingPathComponent("\(song.id).mp3")
            
            context.deleteObject(song)
            NSFileManager.defaultManager().removeItemAtURL(NSURL(fileURLWithPath: filePath), error: nil)
            
            context.save(nil)
            
            loadLocalData()
            
        }
        
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
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
