//
//  LoadView.swift
//  Music
//
//  Created by sykimy on 2016. 9. 17..
//  Copyright © 2016년 sykimy. All rights reserved.
//

import Cocoa

//색상을 하얀색으로 하기 위해 만들었다.
class LoadView: NSView {
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
        NSColor.white.set()
        NSBezierPath.fill(self.bounds)
    }
    
}
