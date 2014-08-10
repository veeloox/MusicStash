//
//  PlaylistSong.swift
//  MusicStash
//
//  Created by Anton Gorskiy on 10.08.14.
//  Copyright (c) 2014 VeelooX. All rights reserved.
//

import Foundation
import CoreData

@objc(PlaylistSong)
class PlaylistSong: NSManagedObject {

    @NSManaged var order: NSNumber
    @NSManaged var playlist: Playlists
    @NSManaged var song: Songs

}
