//
//  MusicQueueCell.swift
//  MusicStash
//
//  Created by Anton Gorskiy on 08.08.14.
//  Copyright (c) 2014 VeelooX. All rights reserved.
//

import UIKit
import CoreData


class MusicQueueCell: UITableViewCell, CustomDownloadDelegate {

    var filePath:String!
    var metaData:NSDictionary!
    var delegate: protocol<CustomQueueDelegate>!
    var isPlaying: Bool = false
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var isPlayingView: UIImageView!
    @IBOutlet weak var isPlayingViewWidth: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func formatTime(value:Int) -> String{
        let minutes = value / 60
        let seconds = value - minutes * 60
        
        return String(format: "%d:%02d", minutes, seconds)
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.titleLabel.text = metaData["title"] as String
        self.artistLabel.text = metaData["artist"] as String
        self.timeLabel.text = self.formatTime(metaData["duration"] as Int)
        self.backgroundView = nil
        
        self.isPlayingViewWidth.constant = (self.isPlaying == true ? 12 : 0)
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func playOrDownload(){
        if (NSFileManager.defaultManager().fileExistsAtPath(filePath)){
            self.delegate.queueCell(self, readyToPlayFile: filePath, metaData: metaData, downloaded:false)
        } else {
            
            let cdt = CustomDownloadTask(filePath: filePath, metaData: metaData, delegate: self)
            
            self.delegate.queueCell(self, startedDownloadingFile: metaData)
            cdt.startDownloading()
            
        }
    }
    
    func didFinishDowloadingMp3(metaData: NSDictionary, filePath: String) {
        self.backgroundView = nil
        
        let app = UIApplication.sharedApplication().delegate as AppDelegate
        let context:NSManagedObjectContext = app.managedObjectContext
        
        var song = NSEntityDescription.insertNewObjectForEntityForName("Songs", inManagedObjectContext: context) as Songs
        
        song.setValue(metaData["id"], forKey: "id")
        song.setValue(metaData["artist"], forKey: "artist")
        song.setValue(metaData["title"], forKey: "title")
        song.setValue(metaData["duration"], forKey: "duration")
        song.setValue(metaData["lyrics_id"], forKey: "lyrics_id")
        song.setValue(Int(NSDate().timeIntervalSinceReferenceDate), forKey: "date_added")
        
        context.save(nil)
        
        self.delegate.queueCell(self, readyToPlayFile: filePath, metaData: metaData, downloaded:true)
    }
    
    func updateUploadProgress(total: Int64, current: Int64, fileId:Int) {
        if (self.metaData["id"] as Int == fileId){
            let width = UIScreen.mainScreen().bounds.width
            let ratio = CGFloat(Float(current) / Float(total))
            
            let progressView = UIView(frame: CGRectMake(0, 0, width*ratio, self.frame.height))
            progressView.backgroundColor = UIColor(red: 0, green: 0.7, blue: 0.3, alpha: 0.5)
            self.backgroundView = progressView
        } else {
            self.backgroundView = nil
        }
        
    }

}
