//
//  ProgressBarView.swift
//  Music
//
//  Created by sykimy on 2016. 8. 2..
//  Copyright © 2016년 sykimy. All rights reserved.
//

import Cocoa
import NotificationCenter

class WidgetProgressBarView: NSView {
    let nc = NotificationCenter.default
    var totalTime, playTime:Int!
    var percent:CGFloat! = 0
    var trackingArea:NSTrackingArea!
    var barAlpha:CGFloat = 0.3
    var r:CGFloat! = 0
    var g:CGFloat! = 0
    var b:CGFloat! = 0
    
    let sharedUserDefaults = UserDefaults.init(suiteName: "group.music.sykimy")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nc.addObserver(self, selector: #selector(WidgetProgressBarView.sync), name: NSNotification.Name(rawValue: "syncPlayerTime"), object: nil)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
        /* 백그라운드 색 */
        NSColor(calibratedRed: r, green: g, blue: b, alpha: barAlpha).blended(withFraction: 0.2, of: NSColor.black)?.set()
        NSBezierPath.fill(self.bounds)
        
        let bounds = NSRect(x: 0, y: 0, width: self.bounds.maxX*percent, height: self.bounds.maxY)
        NSColor(calibratedRed: r, green: g, blue: b, alpha: 1.0).blended(withFraction: 0.2, of: NSColor.black)?.set()
        NSBezierPath.fill(bounds)
    }
    
    func sync(_ note:Notification) {
        let userInfo : NSDictionary = (note as NSNotification).userInfo as NSDictionary!
        
        totalTime = userInfo.object(forKey: "totalTimeInt") as! Int
        playTime = userInfo.object(forKey: "playTimeInt") as! Int
        percent = CGFloat(playTime)/CGFloat(totalTime)
        self.setNeedsDisplay(self.bounds)
    }
    
    func changeBarColor(_ r:CGFloat, g:CGFloat, b:CGFloat) {
        self.r = r
        self.g = g
        self.b = b
        
        self.setNeedsDisplay(self.bounds)
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        let per = theEvent.locationInWindow.x/self.bounds.maxX
        
        var playerInfo = [AnyHashable: CGFloat]()  //Notification을 이용해 데이터 전송을 위한 딕셔너리
        playerInfo["percent"] = per
        
        sharedUserDefaults?.set(playerInfo, forKey: "progressInfo")
        sharedUserDefaults?.synchronize()
    }
    
    override func mouseEntered(with theEvent:NSEvent) {
        super.mouseEntered(with: theEvent)
        
        if self.trackingArea.hashValue == theEvent.trackingNumber {
            barAlpha = 0.45
            self.setNeedsDisplay(self.bounds)
        }
    }
    
    override func mouseExited(with theEvent:NSEvent) {
        super.mouseExited(with: theEvent)
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


