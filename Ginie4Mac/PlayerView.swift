//
//  PlayerView.swift
//  Music
//
//  Created by sykimy on 2016. 8. 2..
//  Copyright © 2016년 sykimy. All rights reserved.
//

import Cocoa

protocol PlayerViewDelegate {
    func playerView(isIn:Bool)
}

class PlayerView: NSView {
    var trackingArea:NSTrackingArea!
    
    var delegate:PlayerViewDelegate? = nil
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
        NSColor.white.set()
        NSRectFill(self.bounds)
    }
    
    override func mouseEntered(with theEvent:NSEvent) {
        super.mouseEntered(with: theEvent)
        if self.trackingArea.hashValue == theEvent.trackingNumber {
            self.delegate?.playerView(isIn:true)
        }
    }
    
    override func mouseExited(with theEvent:NSEvent) {
        super.mouseExited(with: theEvent)
        if self.trackingArea.hashValue == theEvent.trackingNumber {
            self.delegate?.playerView(isIn:false)
        }
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        
        if trackingArea != nil {
            self.removeTrackingArea(trackingArea!)
        }
        
        trackingArea = NSTrackingArea(
            rect: self.bounds,
            options: [NSTrackingAreaOptions.mouseEnteredAndExited, NSTrackingAreaOptions.activeAlways],
            owner: self,
            userInfo: nil
        )
        
        if trackingArea != nil {
            self.addTrackingArea(trackingArea!)
        }
    }
}


