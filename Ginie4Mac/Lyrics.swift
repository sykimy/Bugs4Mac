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
    
    func append(_ string:String) {
        if string.range(of: "</strong>") != nil {
            let tmp = string.replacingOccurrences(of: "<strong id=\"rt\">", with: "")
            let str = tmp.replacingOccurrences(of: "</strong>", with: "")
            self.string.append(str as NSString)
            
        }
        else {
            self.string.append(string as NSString)
        }
    }
}
