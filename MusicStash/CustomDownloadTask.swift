//
//  CustomDownloadTask.swift
//  MusicStash
//
//  Created by Anton Gorskiy on 08.08.14.
//  Copyright (c) 2014 VeelooX. All rights reserved.
//

import UIKit

class CustomDownloadTask: NSObject, NSURLSessionDownloadDelegate {
    
    let filePath:String
    let metaData:NSDictionary
    let delegate: protocol<CustomDownloadDelegate>
    var downloadTask: NSURLSessionDownloadTask!
    let fileId: Int
    init(filePath:String, metaData:NSDictionary, delegate: protocol<CustomDownloadDelegate>){
        
        self.filePath = filePath
        self.metaData = metaData
        self.delegate = delegate
        self.fileId = metaData["id"] as Int
        super.init()
        
        let app = UIApplication.sharedApplication().delegate as AppDelegate
        let sessionConfig = NSURLSessionConfiguration.backgroundSessionConfiguration(NSUUID.UUID().UUIDString + "_mp3_downloader")
        let session = NSURLSession(configuration: sessionConfig, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
                
        self.downloadTask = session.downloadTaskWithURL(NSURL(string: self.metaData["url"] as String))
    }
    
    func startDownloading(){
        self.downloadTask.resume()
    }
    
    func URLSession(session: NSURLSession!, downloadTask: NSURLSessionDownloadTask!, didFinishDownloadingToURL location: NSURL!) {
        NSFileManager.defaultManager().copyItemAtURL(location, toURL: NSURL(fileURLWithPath: filePath), error: nil)
        self.delegate.didFinishDowloadingMp3(self.metaData, filePath: self.filePath)
    }
    
    func URLSession(session: NSURLSession!, downloadTask: NSURLSessionDownloadTask!, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        self.delegate.updateUploadProgress(totalBytesExpectedToWrite, current: totalBytesWritten, fileId:fileId)
    }
    
}
