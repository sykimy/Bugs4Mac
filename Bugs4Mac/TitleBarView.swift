//
//  TitleBarView.swift
//  Bugs
//
//  Created by 김세윤 on 2016. 10. 9..
//  Copyright © 2016년 sykimy. All rights reserved.
//

import Cocoa

class TitleBarView: NSView {
    
    var trackingArea:NSTrackingArea!
    let nc = NotificationCenter.default
    var al: CGFloat = 0.15;
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
        NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: al).set()
        NSRectFill(self.bounds)
        NSBezierPath.fill(self.bounds)
        
    }
    
    func full() {
        al = 0.0
        self.setNeedsDisplay(self.bounds)
    }
    
    func defull() {
        al = 0.15
        self.setNeedsDisplay(self.bounds)
    }
    
    override func mouseEntered(with theEvent:NSEvent) {
        super.mouseEntered(with: theEvent)
        
        if self.trackingArea.hashValue == theEvent.trackingNumber {
            nc.post(name: Notification.Name(rawValue: "titleMouseIn"), object: self)
        }
    }
    
    override func mouseExited(with theEvent:NSEvent) {
        super.mouseExited(with: theEvent)
        if self.trackingArea.hashValue == theEvent.trackingNumber {
            nc.post(name: Notification.Name(rawValue: "titleMouseOut"), object: self)
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
