//
//  CustomDowloadDelegate.swift
//  MusicStash
//
//  Created by Anton Gorskiy on 08.08.14.
//  Copyright (c) 2014 VeelooX. All rights reserved.
//

import Foundation


protocol CustomDownloadDelegate {
    
    func didFinishDowloadingMp3(metaData:NSDictionary, filePath:String)
    func updateUploadProgress(total: Int64, current:Int64, fileId:Int)
}