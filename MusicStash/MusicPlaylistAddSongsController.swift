//
//  MusicPlaylistAddSongsController.swift
//  MusicStash
//
//  Created by Anton Gorskiy on 09.08.14.
//  Copyright (c) 2014 VeelooX. All rights reserved.
//

import UIKit
import CoreData

class MusicPlaylistAddSongsController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var musicList: Array<Songs> = []
    var parent:MusicPlaylistController!
    var playlist: Playlists!
    
    func loadLocalData(){
        let app = UIApplication.sharedApplication().delegate as AppDelegate
        let context:NSManagedObjectContext = app.managedObjectContext
        
        let request = NSFetchRequest(entityName: "Songs")
        request.returnsObjectsAsFaults = false

        request.sortDescriptors = [
            NSSortDescriptor(key: "date_added", ascending: false)
        ]
        
        musicList = context.executeFetchRequest(request, error: nil) as [Songs]
        let addedMusic = (playlist.songs.allObjects as [PlaylistSong]).map({
            (ps:PlaylistSong) -> Songs in
            return ps.song
        })
        
        musicList = musicList.filter { (s:Songs) -> Bool in
            return !contains(addedMusic, s)
        }
        
        
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        self.tableView.reloadData()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        loadLocalData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return musicList.count
    }

    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("music_playlist_add_cell", forIndexPath: indexPath) as MusicPlaylistAddCell
        let song = musicList[indexPath.row]
        
        cell.textLabel.text = song.valueForKey("title") as String
        cell.detailTextLabel.text = song.valueForKey("artist") as String

        return cell
    }
    
    @IBAction func saveButton(){
        
        parent.addSongsToPlaylist(
            (self.tableView.indexPathsForSelectedRows() as [NSIndexPath]).map({
                (p:NSIndexPath) -> Songs in
                return self.musicList[p.row] as Songs
            })
        )
        
        self.presentingViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelButton(){
                
        self.presentingViewController.dismissViewControllerAnimated(true, completion: nil)
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
