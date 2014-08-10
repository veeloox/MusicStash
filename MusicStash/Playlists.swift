//
//  Playlists.swift
//  MusicStash
//
//  Created by Anton Gorskiy on 10.08.14.
//  Copyright (c) 2014 VeelooX. All rights reserved.
//

import Foundation
import CoreData

@objc(Playlists)
class Playlists: NSManagedObject {

    @NSManaged var duration: NSNumber
    @NSManaged var song_count: NSNumber
    @NSManaged var title: String
    @NSManaged var songs: NSSet

}
