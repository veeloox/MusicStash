//
//  MusicPlaybackController.swift
//  MusicStash
//
//  Created by Anton Gorskiy on 07.08.14.
//  Copyright (c) 2014 VeelooX. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import CoreMedia

class MusicPlaybackController: UIViewController, AVAudioPlayerDelegate, UITableViewDataSource, UITableViewDelegate, CustomQueueDelegate {
    
    @IBOutlet weak var queueTable: UITableView!
    @IBOutlet weak var positionSlider: UISlider!
    
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var timeLeftLabel: UILabel!
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    
    @IBOutlet weak var playingTitle: UILabel!
    @IBOutlet weak var playingArtist: UILabel!
    
    var queue:Array<NSDictionary>! = Array()
    
    var shuffleStack:Array<Int> = []
    var shufflePosition:Int = 0
    
    var currentTrack:Int = -1
    var currentFileMetaData: Dictionary<String, AnyObject>! = [:]
    var app:AppDelegate!
    
    var isSeekActive:Bool = false
    var updateTimer:NSTimer!
    var seekTimer:NSTimer!
    var nowPlaying:Int! = 0
    var seekStep: NSTimeInterval = 1.0
    var isRemoteSeekActive: Bool = false
    var shouldPlayNextFile: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        app = UIApplication.sharedApplication().delegate as AppDelegate
        self.tabBarItem = UITabBarItem(title: "Now Playing", image: UIImage(named: "headphones"), tag: 3)
        
        queueTable.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        queueTable.dataSource = self
        queueTable.delegate = self
        
        self.currentFileMetaData[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0.0
        
        updateTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateTime"), userInfo: nil, repeats: true)
        seekTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("updateSeekPosition"), userInfo: nil, repeats: true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("headphonesEvent:"), name: AVAudioSessionRouteChangeNotification, object: nil)
        
    }
    
    func startPlaying(){
        if (currentTrack < 0){
            currentTrack = 0
        }
        
        shuffleStack = []
        shufflePosition = 0
        
        self.shuffleButton.selected = false
        
        self.queueTable.reloadData()
        
        if (queue.count > 0){
            self.playCurrent()
        }
        
        self.queueTable.reloadData()
    }
    
    func generateShuffleQueue(first:Int = -1) -> Array<Int> {
        var tmp = Array<Int>()
        for i in (0..<self.queue.count) {
            if (first != i){
                tmp.append(i)
            }
        }
        
        tmp.sort { (_, _) -> Bool in
            arc4random() % 2 == 0
        }
        
        if (first >= 0){
            tmp.insert(first, atIndex: 0)
        }
        
        return tmp
    }
    
    func doNextTrack(force:Bool = false){
        if (force) {
            
            if (self.shuffleButton.selected){
                
                shufflePosition++
                
                if (shufflePosition >= shuffleStack.count){
                    shuffleStack.extend(self.generateShuffleQueue())
                }
                
                currentTrack = shuffleStack[shufflePosition]
                
            } else {
                if (queue.count > 0){
                    currentTrack = (currentTrack + 1) % queue.count
                }
            }
            
        } else if (!self.repeatButton.selected){
            if (queue.count > 0){
                currentTrack = (currentTrack + 1) % queue.count
            }
        }
    }
    
    func doPrevTrack(force:Bool = false){
        if (force){
            
            if (self.shuffleButton.selected){
                
                if (shufflePosition > 0){
                    shufflePosition--
                    currentTrack = shuffleStack[shufflePosition]
                }
                
            } else {
                if (queue.count > 0){
                    currentTrack = (currentTrack - 1 + queue.count) % queue.count
                }
            }
            
        } else if (!self.repeatButton.selected){
            if (queue.count > 0){
                currentTrack = (currentTrack - 1 + queue.count) % queue.count
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    func playCurrent(){
        let indexPath = NSIndexPath(forRow: currentTrack, inSection: 0)
        self.queueTable.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: false)
        self.tableView(self.queueTable, didSelectRowAtIndexPath: indexPath)
    }

    func queueCell(sender: MusicQueueCell, readyToPlayFile filePath: String, metaData: NSDictionary, downloaded:Bool) {
        self.startPlayingFile(metaData, filePath: filePath)
    }
    
    func queueCell(sender: MusicQueueCell, startedDownloadingFile metaData: NSDictionary) {
        self.pause()
        self.startPlayingFile(metaData, filePath: "", dummy: true)
    }
    
    func startPlayingFile(metaData:NSDictionary, filePath: String, dummy:Bool = false){
                
        var err:NSError?
        
        if (dummy) {
            app.player = nil
        } else {
            app.player = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: filePath), error: &err)
            app.player.prepareToPlay()
            app.player.delegate = self
            NSTimer(timeInterval: 0.01, target: self, selector: Selector("updateTime"), userInfo: nil, repeats: false)
            app.player.play()
        }
        
        self.positionSlider.maximumValue = metaData["duration"] as Float
        
        currentFileMetaData = [
            MPMediaItemPropertyArtist: metaData["artist"] as String,
            MPMediaItemPropertyTitle: metaData["title"] as String,
            MPMediaItemPropertyPlaybackDuration: NSTimeInterval(metaData["duration"] as Float),
            MPNowPlayingInfoPropertyPlaybackRate: 1.0
        ]
        
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = self.currentFileMetaData
        
        self.playingArtist.text = metaData["artist"] as String
        self.playingTitle.text = metaData["title"] as String
        
        self.nowPlaying = metaData["id"] as Int
        self.setButtonState("pause")
        self.queueTable.reloadData()
        
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        self.nowPlaying = 0
        self.setButtonState("play")
        
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = nil
        
        self.playingArtist.text = "---"
        self.playingTitle.text = "---"
        
        doNextTrack()
        playCurrent()
    }    
    
    func setButtonState(state:String){
        self.playPauseButton.setImage(UIImage(named: state), forState: UIControlState.Normal)
        if (state == "play"){
            self.playPauseButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
        } else {
            self.playPauseButton.imageEdgeInsets = UIEdgeInsetsZero
        }
    }
    
    func play(){
        if ((app.player) != nil){
            NSTimer(timeInterval: 0.01, target: self, selector: Selector("updateTime"), userInfo: nil, repeats: false)
            app.player.play()
            self.setButtonState("pause")
        }

    }
    
    func pause(){
        if ((app.player) != nil){
            app.player.pause()
            self.setButtonState("play")
        }
    }
    
    @IBAction func playPauseButtonPressed(sender: UIButton!){
        if ((app.player) != nil){
            if (app.player.playing){
                self.pause()
            } else {
                self.play()
            }
        }
    }
    
    @IBAction func nextButtonPressed(sender: UIButton!){
        self.nowPlaying = 0
        self.setButtonState("play")
        doNextTrack(force:true)
        playCurrent()
    }
    
    @IBAction func prevButtonPressed(sender: UIButton!){
        self.nowPlaying = 0
        self.setButtonState("play")
        doPrevTrack(force:true)
        playCurrent()
    }
    
    @IBAction func shuffleButtonPressed(sender: UIButton!){
        self.shuffleButton.selected = !self.shuffleButton.selected
        
        if (self.shuffleButton.selected){
            
            self.shuffleStack = self.generateShuffleQueue(first:currentTrack)
            self.shufflePosition = 0
        }
    }
    
    @IBAction func repeatButtonPressed(sender: UIButton!){
        self.repeatButton.selected = !self.repeatButton.selected
    }
    
    
    @IBAction func seekingStart(sender: UISlider) {
        isSeekActive = true
    }
    
    @IBAction func seekingEnd(sender: UISlider) {
        
        if ((app.player) != nil){
            NSTimer(timeInterval: 0.01, target: self, selector: Selector("updateTime"), userInfo: nil, repeats: false)
            app.player.currentTime = NSTimeInterval(sender.value)
        }
        
        isSeekActive = false
    }
    
    func startRemoteSeekingForward(){
        self.seekStep = 1.0
        self.isRemoteSeekActive = true
    }
    
    
    func startRemoteSeekingBackward(){
        self.seekStep = -1.0
        self.isRemoteSeekActive = true
    }

    func endRemoteSeeking(){
        self.isRemoteSeekActive = false
    }    
    
    func formatTime(value:NSTimeInterval) -> String{
        let minutes = floor(value / 60.0)
        let seconds = lround(value - minutes * 60)
        
        return String(format: "%d:%02d", Int(minutes), Int(seconds))
        
    }
    
    func updateTime(){
        if ((app.player) != nil){
            if (app.player.playing){
                if (!isSeekActive){
                    self.positionSlider.value = Float(app.player.currentTime)
                    timeElapsedLabel.text = self.formatTime(app.player.currentTime)
                    timeLeftLabel.text = self.formatTime(app.player.duration - app.player.currentTime)
                    self.currentFileMetaData[MPNowPlayingInfoPropertyElapsedPlaybackTime] = app.player.currentTime
                    MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = self.currentFileMetaData
                }
            }
        } else {
            self.positionSlider.value = 0.0
            timeElapsedLabel.text = self.formatTime(0.0)
            timeLeftLabel.text = self.formatTime(0.0)
            self.currentFileMetaData[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0.0
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = self.currentFileMetaData
        }
    }
    
    func updateSeekPosition(){
        if (isRemoteSeekActive){
            if ((app.player) != nil){
                if (app.player.playing){
                    if (app.player.currentTime + self.seekStep < app.player.duration
                        && app.player.currentTime - self.seekStep > 0)
                    {
                        app.player.currentTime += self.seekStep
                    }
                }
            }
        }
    }
    
    func headphonesEvent(event: NSNotification){
        
        let reasonOpt: AnyObject? =  event.userInfo["AVAudioSessionRouteChangeReasonKey"]
        let reason = AVAudioSessionRouteChangeReason.fromRaw(reasonOpt! as UInt)
        
        if (reason == AVAudioSessionRouteChangeReason.OldDeviceUnavailable){
            self.pause()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return queue.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("now_playing_queue", forIndexPath: indexPath) as MusicQueueCell
        
        cell.metaData = queue[indexPath.row]
        let fileId = cell.metaData["id"] as Int
        cell.filePath = app.stashRoot.stringByAppendingPathComponent("\(fileId).mp3")
        
        cell.isPlaying = (fileId == nowPlaying)
        
        cell.delegate = self
//        cell.accessoryType = UITableViewCellAccessoryType.None
//        if (self.currentTrack == indexPath.row){
//            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
//        }
        
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        self.currentTrack = indexPath.row
        
        let tcell = tableView.cellForRowAtIndexPath(indexPath) as MusicQueueCell
        let cell = tcell as MusicQueueCell
        
        self.shouldPlayNextFile = true
        cell.playOrDownload()
        
    }    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
