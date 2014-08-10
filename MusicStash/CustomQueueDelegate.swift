//
//  CustomQueueDelegate.swift
//  MusicStash
//
//  Created by Anton Gorskiy on 08.08.14.
//  Copyright (c) 2014 VeelooX. All rights reserved.
//

import Foundation


protocol CustomQueueDelegate {
    
    func queueCell(sender: MusicQueueCell, readyToPlayFile filePath:String, metaData:NSDictionary, downloaded:Bool)
    func queueCell(sender: MusicQueueCell, startedDownloadingFile metaData:NSDictionary)
    
}