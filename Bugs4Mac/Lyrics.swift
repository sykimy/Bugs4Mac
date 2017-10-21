//
//  Lyrics.swift
//  Bugs
//
//  Created by 김세윤 on 2016. 10. 12..
//  Copyright © 2016년 sykimy. All rights reserved.
//

import Cocoa

class Lyrics: NSObject {
    var string = [NSString]()
    var time = [Int]()
    var sync = false
    
    func append(_ time:Int, _ string:String) {
        self.string.append(string as NSString)
        self.time.append(time)
    }
}
