//
//  MusicPlaylistController.swift
//  MusicStash
//
//  Created by Anton Gorskiy on 09.08.14.
//  Copyright (c) 2014 VeelooX. All rights reserved.
//

import UIKit
import CoreData

class MusicPlaylistController: UITableViewController, UIAlertViewDelegate {

    var playlist: Playlists!
    var musicList: Array<Songs> = []
    
    func loadLocalData(){
        let pSongs = playlist.songs.sortedArrayUsingDescriptors([
            NSSortDescriptor(key: "order", ascending: true)
            ]) as [PlaylistSong]
        
        
        musicList = pSongs.map({ (ps:PlaylistSong) -> Songs in
            return ps.song
        })
        
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.title = playlist.title
     
        self.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        
        loadLocalData()
        
        let customTitle = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        
        customTitle.setTitle(playlist.title, forState: UIControlState.Normal)
        customTitle.titleLabel.font = UIFont(name: "HelveticaNeue-Light", size: 16.0)
        customTitle.titleLabel.textColor = UIColor.whiteColor()
        customTitle.titleLabel.textAlignment = NSTextAlignment.Center
        customTitle.frame = CGRectMake(0, 0, 320, 30)
        
        customTitle.addTarget(self, action: Selector("editTitleButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.navigationItem.titleView = customTitle
        self.navigationController.navigationBar.topItem.title = ""
        
        self.setEditing(true, animated: false)
    }

    
    func editTitleButtonPressed(sender: UIBarButtonItem) {
        
        let titlePrompt = UIAlertView(
            title: "Edit playlist title",
            message: "Enter new title for playlist",
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
            
            self.playlist.title = inputText.text
            (self.navigationItem.titleView as UIButton).setTitle(self.playlist.title, forState: UIControlState.Normal)
            
            context.save(nil)
            
            loadLocalData()
        }
    }
    
    func addSongsToPlaylist(songs: [Songs]){
        
        println(songs)
        let app = UIApplication.sharedApplication().delegate as AppDelegate
        let context:NSManagedObjectContext = app.managedObjectContext
        
        playlist.songs = playlist.songs.setByAddingObjectsFromArray(songs.map({ (s:Songs) -> PlaylistSong in
            let tps = NSEntityDescription.insertNewObjectForEntityForName("PlaylistSong", inManagedObjectContext: context) as PlaylistSong
            tps.song = s
            tps.playlist = self.playlist
            return tps
        }))
        
        var pss = playlist.songs.sortedArrayUsingDescriptors([
            NSSortDescriptor(key: "order", ascending: true)
            ]) as [PlaylistSong]
        
        
        var songsCount:Int = 0
        var duration:Int = 0
        
        for (index, ps) in enumerate(pss) {
            ps.order = index
            songsCount++
            duration += ps.song.duration.integerValue
        }
        
        playlist.song_count = NSNumber(long: songsCount)
        playlist.duration = NSNumber(long: duration)
        
        
        context.save(nil)
        
        loadLocalData()
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
        let cell = tableView.dequeueReusableCellWithIdentifier("music_playlist_song_cell", forIndexPath: indexPath) as UITableViewCell
        let song = musicList[indexPath.row]
        
        cell.textLabel.text = song.title
        cell.detailTextLabel.text = song.artist

        return cell
    }
    
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            let app = UIApplication.sharedApplication().delegate as AppDelegate
            let context:NSManagedObjectContext = app.managedObjectContext
            
            var tempObjects = playlist.songs.sortedArrayUsingDescriptors([
                    NSSortDescriptor(key: "order", ascending: true)
                ]) as [PlaylistSong]
            
            tempObjects.removeAtIndex(indexPath.row)
            
            playlist.songs = NSSet(array: tempObjects)
            
            var songsCount:Int = 0
            var duration:Int = 0
            
            for (index, ps) in enumerate(tempObjects) {
                ps.order = index
                songsCount++
                duration += ps.song.duration.integerValue
            }
            
            playlist.song_count = NSNumber(long: songsCount)
            playlist.duration = NSNumber(long: duration)
            
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

    override func tableView(tableView: UITableView!, moveRowAtIndexPath fromIndexPath: NSIndexPath!, toIndexPath: NSIndexPath!) {
        
        let app = UIApplication.sharedApplication().delegate as AppDelegate
        let context:NSManagedObjectContext = app.managedObjectContext
        
        var pss = playlist.songs.sortedArrayUsingDescriptors([
                NSSortDescriptor(key: "order", ascending: true)
            ]) as [PlaylistSong]
        
        //if (fromIndexPath.row < toIndexPath.row){
        let item = pss[fromIndexPath.row]
        pss.removeAtIndex(fromIndexPath.row)
        pss.insert(item, atIndex: toIndexPath.row)
//        } else {
//            let item = ps[toIndexPath.row]
//            ps.insert(item, atIndex: toIndexPath.row)
//            ps.removeAtIndex(fromIndexPath.row)
//            
//        }
        for (index, ps) in enumerate(pss) {
            ps.order = index
        }
        
        context.save(nil)
        
        //context.save(nil)
        
        println(("moved from", fromIndexPath.row, "to", toIndexPath.row))
    }
    
    override func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }

    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if (segue.identifier == "show_songs_adder"){
            let dest = segue.destinationViewController as MusicPlaylistAddSongsController
            dest.parent = self
            dest.playlist = playlist
        }
    }


}
