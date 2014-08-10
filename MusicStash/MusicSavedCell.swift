//
//  MusicSavedCell.swift
//  MusicStash
//
//  Created by Anton Gorskiy on 09.08.14.
//  Copyright (c) 2014 VeelooX. All rights reserved.
//

import UIKit

class MusicSavedCell: UITableViewCell {

    var metaData:NSDictionary!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
                
    }

}
