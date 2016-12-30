//
//  UserDefaultsController.swift
//  Bugs
//
//  Created by 김세윤 on 2016. 10. 21..
//  Copyright © 2016년 sykimy. All rights reserved.
//

import Cocoa

class UserDefaultsController:NSObject {
    let defaults = UserDefaults.standard
    
    /* 배경화면 기능 설정 입출력 */
    func setTextColor(type:String, color:NSColor) {
        let tmp = color.usingColorSpace(NSColorSpace.genericRGB)!
        defaults.set(tmp.redComponent, forKey: "\(type)ColorRed")
        defaults.set(tmp.greenComponent, forKey: "\(type)ColorGreen")
        defaults.set(tmp.blueComponent, forKey: "\(type)ColorBlue")
        defaults.set(tmp.alphaComponent, forKey: "\(type)ColorAlpha")
    }
    
    func bool(forKey:String)->Bool {
        return defaults.bool(forKey: forKey)
    }
    
    func be(forKey:String)->Bool {
        if (defaults.object(forKey: forKey) != nil) {
            return true
        }
        return false
    }
    
    func cgFloat(forKey:String)->CGFloat {
        return defaults.object(forKey: forKey) as! CGFloat
    }
    
    func color(type:String)->NSColor {
        var r:CGFloat! = 0
        var g:CGFloat! = 0
        var b:CGFloat! = 0
        var a:CGFloat! = 1
        
        if be(forKey: "\(type)ColorRed") { r = cgFloat(forKey: "\(type)ColorRed") }
        if be(forKey: "\(type)ColorGreen") { g = cgFloat(forKey: "\(type)ColorGreen") }
        if be(forKey: "\(type)ColorBlue") { b = cgFloat(forKey: "\(type)ColorBlue") }
        if be(forKey: "\(type)ColorAlpha") { a = cgFloat(forKey: "\(type)ColorAlpha") }
        
        return NSColor(calibratedRed: r, green: g, blue: b, alpha: a)
    }
    
    func frame(type:String)->NSRect {
        var originX:CGFloat!
        var originY:CGFloat!
        var frameW:CGFloat!
        var frameH:CGFloat!
        var count = 0
        
        if (defaults.object(forKey: "\(type)WindowFrameX") != nil) { originX = defaults.object(forKey: "\(type)WindowFrameX") as! CGFloat; count+=1 }
        if (defaults.object(forKey: "\(type)WindowFrameY") != nil) { originY = defaults.object(forKey: "\(type)WindowFrameY") as! CGFloat; count+=1 }
        if (defaults.object(forKey: "\(type)WindowFrameW") != nil) { frameW = defaults.object(forKey: "\(type)WindowFrameW") as! CGFloat; count+=1 }
        if (defaults.object(forKey: "\(type)WindowFrameH") != nil) { frameH = defaults.object(forKey: "\(type)WindowFrameH") as! CGFloat; count+=1 }
        
        if count == 4 {
            return NSMakeRect(originX, NSScreen.main()!.visibleFrame.size.height-originY, frameW, frameH)
        }
        return NSRect.null
    }
    
    func set(alignment:Int, forKey:String) {
        defaults.set(alignment, forKey: forKey)
    }
    
    func set(_ value:Bool, forKey:String) {
        defaults.set(value, forKey: forKey)
    }
    
    func set(rect:NSRect, type:String) {
        defaults.set(rect.origin.x, forKey: "\(type)WindowFrameX")
        defaults.set(NSScreen.main()!.visibleFrame.size.height-rect.origin.y, forKey: "\(type)WindowFrameY")
        defaults.set(rect.width, forKey: "\(type)WindowFrameW")
        defaults.set(rect.height, forKey: "\(type)WindowFrameH")
    }
}
