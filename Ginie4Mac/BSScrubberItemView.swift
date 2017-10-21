//
//  BSScrubberItemView.swift
//  Bugs4Mac
//
//  Created by 김세윤 on 2017. 2. 27..
//  Copyright © 2017년 sykimy. All rights reserved.
//

import Cocoa

@available(OSX 10.12.2, *)
class BSScrubberItemView: NSScrubberItemView {
    /*
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let path: NSBezierPath = NSBezierPath(roundedRect: self.bounds, xRadius: 18.0, yRadius: 18.0)
        path.addClip()
        
        // Drawing code here.
        NSColor.gray.set()
        NSRectFill(self.bounds)

        // Drawing code here.
    }*/
    
    let roundLayer: CALayer = CALayer()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        self.wantsLayer = true
        self.layer?.addSublayer(roundLayer)
        roundLayer.frame = self.bounds
        roundLayer.cornerRadius = 6.28
        roundLayer.backgroundColor = NSColor.red.cgColor
    }
    
    func setColor(_ color:CGColor) {
        roundLayer.backgroundColor = color
    }
    
}
