//
//  Song.swift
//  Music
//
//  Created by sykimy on 2016. 8. 2..
//  Copyright © 2016년 sykimy. All rights reserved.
//

import Foundation

class Song : NSObject {
    var name:String!
    var artist:String!
    var num:Int!
    var nowPlaying:Bool!
    
    override init() {
        self.name = nil
        self.artist = nil
        self.num = -1
        super.init()
    }
    
    init(num:Int, name:String, artist:String, now:Bool) {
        self.name = name
        self.artist = artist
        self.num = num
        self.nowPlaying = now
    }
    
    func getName()->String { return name }
    func getArtist()->String { return artist }
    func getNum()->Int { return num }
    func getNow()->Bool { return nowPlaying }
}
