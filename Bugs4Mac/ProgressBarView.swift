//
//  ProgressBarView.swift
//  Music
//
//  Created by sykimy on 2016. 8. 2..
//  Copyright © 2016년 sykimy. All rights reserved.
//

import Cocoa

protocol ProgressBarDelegate {
    func progressBar(percent: CGFloat)
}

class ProgressBarView: NSView {
    var totalTime, playTime:Int!
    var percent:CGFloat! = 0
    var trackingArea:NSTrackingArea!
    var barAlpha:CGFloat = 0.3
    var r:CGFloat! = 0
    var g:CGFloat! = 0
    var b:CGFloat! = 0
    
    var delegate:ProgressBarDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
        /* 백그라운드 색 */
        NSColor(calibratedRed: r, green: g, blue: b, alpha: barAlpha).set()
        NSBezierPath.fill(self.bounds)
        
        let bounds = NSRect(x: 0, y: 0, width: self.bounds.maxX*percent, height: self.bounds.maxY)
        NSColor(calibratedRed: r, green: g, blue: b, alpha: 1.0).set()
        NSBezierPath.fill(bounds)
    }
    
    //PlayerController로 부터 노래 곡의 길이와 현재 진행상태를 받아와 이를 반영한다.
    func sync(totalTime:Int, playTime:Int) {
        percent = CGFloat(playTime)/CGFloat(totalTime)
        self.setNeedsDisplay(self.bounds)
    }
    
    //진행바의 색상을 변경한다.
    func changeBarColor(_ r:CGFloat, g:CGFloat, b:CGFloat) {
        self.r = r
        self.g = g
        self.b = b
        
        self.setNeedsDisplay(self.bounds)
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        self.delegate?.progressBar(percent: theEvent.locationInWindow.x/self.bounds.maxX)
    }
    
    override func mouseEntered(with theEvent:NSEvent) {
        if self.trackingArea.hashValue == theEvent.trackingNumber {
            barAlpha = 0.6
            self.setNeedsDisplay(self.bounds)
        }
    }
    
    override func mouseExited(with theEvent:NSEvent) {
        if self.trackingArea.hashValue == theEvent.trackingNumber {
            barAlpha = 0.3
            self.setNeedsDisplay(self.bounds)
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


