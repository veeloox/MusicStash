//
//  MusicPlaylistAddCell.swift
//  MusicStash
//
//  Created by Anton Gorskiy on 10.08.14.
//  Copyright (c) 2014 VeelooX. All rights reserved.
//

import UIKit

class MusicPlaylistAddCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if (selected){
            self.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            self.accessoryType = UITableViewCellAccessoryType.None
        }
    }
    
    
}
