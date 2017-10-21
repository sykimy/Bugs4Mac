//
//  ButtonController.swift
//  Music
//
//  Created by sykimy on 2016. 8. 2..
//  Copyright © 2016년 sykimy. All rights reserved.
//

import Cocoa

//버튼안에 마우스가 들어오고 나갔을때, 버튼의 색을 조절한다.
class ButtonController: NSButton {
    var trackingArea:NSTrackingArea!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
        
    }
    
    //마우스가 들어오면 투명도를 없앤다.
    override func mouseEntered(with theEvent:NSEvent) {
        super.mouseEntered(with: theEvent)
        
        if self.trackingArea.hashValue == theEvent.trackingNumber {
            self.alphaValue = 1.0
        }
    }
    
    //마우스가 나가면 약간 투명하게 만든다.
    override func mouseExited(with theEvent:NSEvent) {
        super.mouseExited(with: theEvent)
        if self.trackingArea.hashValue == theEvent.trackingNumber {
            self.alphaValue = 0.9
        }
    }
    
    //버튼뷰안에서의 마우스의 위치를 업데이트한다.
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

