//
//  Songs.swift
//  MusicStash
//
//  Created by Anton Gorskiy on 10.08.14.
//  Copyright (c) 2014 VeelooX. All rights reserved.
//

import Foundation
import CoreData

@objc(Songs)
class Songs: NSManagedObject {

    @NSManaged var artist: String
    @NSManaged var date_added: NSNumber
    @NSManaged var duration: NSNumber
    @NSManaged var id: NSNumber
    @NSManaged var lyrics_id: NSNumber
    @NSManaged var title: String
    @NSManaged var playlistRel: NSSet

}
