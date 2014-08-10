//
//  MusicPlaylistsController.swift
//  MusicStash
//
//  Created by Anton Gorskiy on 09.08.14.
//  Copyright (c) 2014 VeelooX. All rights reserved.
//

import UIKit
import CoreData

class MusicPlaylistsController: UITableViewController, UIAlertViewDelegate {

    var playlists: Array<Playlists> = []
    //Array<NSDictionary>! = Array()
    
    func loadLocalData(){
        
        
        let app = UIApplication.sharedApplication().delegate as AppDelegate
        let context:NSManagedObjectContext = app.managedObjectContext
        
        let request = NSFetchRequest(entityName: "Playlists")
        request.returnsObjectsAsFaults = false
        //        request.predicate = NSPredicate(format: "title = %@", "Women")
//        request.sortDescriptors = [
//            NSSortDescriptor(key: "date_added", ascending: false)
//        ]
        
        
        playlists = context.executeFetchRequest(request, error: nil) as [Playlists]
        
//        playlists = results
//            .map({
//            (item:NSManagedObject) -> NSDictionary in
//            return item.dictionaryWithValuesForKeys((item.entity.attributesByName as NSDictionary).allKeys)
//        })
        
        self.refreshControl.endRefreshing()
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 10)
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadLocalData()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.refreshControl.addTarget(self, action: Selector("loadLocalData"), forControlEvents: UIControlEvents.ValueChanged)
        
    }

    @IBAction func addButtonPressed(sender: UIBarButtonItem) {
        println("Create New")
        
        let titlePrompt = UIAlertView(
            title: "New Playlist",
            message: "Enter title of new playlist",
            delegate: self,
            cancelButtonTitle: "Cancel",
            otherButtonTitles: "Save")
        titlePrompt.alertViewStyle = UIAlertViewStyle.PlainTextInput
        titlePrompt.show()
    }
    
    func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int) {
        if (buttonIndex == 1){
            let inputText = alertView.textFieldAtIndex(0)
            
            let app = UIApplication.sharedApplication().delegate as AppDelegate
            let context:NSManagedObjectContext = app.managedObjectContext
            
            var playlist = NSEntityDescription.insertNewObjectForEntityForName("Playlists", inManagedObjectContext: context) as NSManagedObject
            
            playlist.setValue(inputText.text, forKey: "title")
            playlist.setValue(0, forKey: "song_count")
            playlist.setValue(0, forKey: "duration")
            
            context.save(nil)
            
            loadLocalData()
        }
    }
    
    @IBAction func editButtonPressed(sender: UIBarButtonItem) {
        if (self.tableView.editing){
            self.tableView.setEditing(false, animated: true)
        } else {
            self.tableView.setEditing(true, animated: true)
        }
        
    }
    
    func makePlaylistDescription(playlist:Playlists) -> String{
        
        var timeString = ""
        let count = playlist.song_count.integerValue
        let duration = playlist.duration.integerValue
        
        let hours = duration / 3600
        let minutes = (duration % 3600) / 60
        let seconds = duration % 60
        
        if (hours > 0){
            timeString = String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            timeString = String(format: "%d:%02d", minutes, seconds)
        }
        
        return "Tracks: \(count),  Duration: \(timeString)"
        
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
        return playlists.count
    }

    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("music_playlist_cell", forIndexPath: indexPath) as UITableViewCell

        cell.textLabel.text = playlists[indexPath.row].title
        cell.detailTextLabel.text = self.makePlaylistDescription(playlists[indexPath.row])

        return cell
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        
        if (!tableView.editing){
            let app = UIApplication.sharedApplication().delegate as AppDelegate
            let playlist = playlists[indexPath.row]
            
            let pSongs = playlist.songs.sortedArrayUsingDescriptors([
                NSSortDescriptor(key: "order", ascending: true)
                ]) as [PlaylistSong]
            
            
            app.nowPlaying.queue = pSongs.map({ (item:PlaylistSong) -> NSDictionary in
                return item.song.dictionaryWithValuesForKeys((item.song.entity.attributesByName as NSDictionary).allKeys)
            })
            
            println(app.nowPlaying.queue)
            
            app.nowPlaying.currentTrack = 0
            app.nowPlaying.startPlaying()
            
            self.tabBarController.selectedIndex = 3
        }
    }
    
    
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            let app = UIApplication.sharedApplication().delegate as AppDelegate
            let context:NSManagedObjectContext = app.managedObjectContext
            
            let playlist = playlists[indexPath.row]
            
            for ps in playlist.songs {
                context.deleteObject(ps as PlaylistSong)
            }
            
            context.deleteObject(playlist)
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

    override func shouldPerformSegueWithIdentifier(identifier: String!, sender: AnyObject!) -> Bool {
        if (identifier == "edit_playlist"){
            return self.tableView.editing
        }
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        let dest = segue.destinationViewController as MusicPlaylistController
        let playlist = playlists[self.tableView.indexPathForCell(sender as UITableViewCell).row]        
        dest.playlist = playlist
    }
    

}
