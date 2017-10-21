//
//  WallpaperText.swift
//  Bugs
//
//  Created by 김세윤 on 2016. 10. 19..
//  Copyright © 2016년 sykimy. All rights reserved.
//

import Cocoa

class WallpaperImage: NSObject {
    let nc = NotificationCenter.default
    
    var imageView:NSImageView!
    
    var window = NSWindow()
    
    init(rect:NSRect) {
        super.init()
        nc.addObserver(self, selector: #selector(setOptimizedFontSize), name: NSNotification.Name(rawValue: "NSViewFrameDidChangeNotification"), object: nil)
        
        window = NSWindow(contentRect: rect, styleMask: .borderless, backing: .buffered, defer: true)
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.hasShadow = false
        window.backgroundColor = NSColor.clear
        window.isOpaque = false
        
        /* 배경화면모드로 변경 */
        window.level = Int(CGWindowLevelForKey(.desktopWindow))
        
        imageView = NSImageView(frame: window.frame)
        
        window.contentView = imageView
        
        open()
    }
    
    deinit {
        close()
    }
    
    //창의 레벨을 조정한다.(항상위로, 배경화면으로 등등)
    func setLevel(level:Int) {
        window.level = level
    }
    
    //이미지를 세팅한다.
    func set(image:NSImage) {
        imageView.image = image
    }
    
    func setFrame(rect:NSRect) {
        window.setFrame(rect, display: true, animate: false)
    }
    
    func frame()->NSRect {
        return window.frame
    }
    
    func open() {
        let controller = NSWindowController(window: window)
        controller.showWindow(self)
    }
    
    func close() {
        let controller = NSWindowController(window: window)
        controller.close()
    }
    
    func fix() {
        window.styleMask = .fullSizeContentView
        
        window.backgroundColor = NSColor.clear
    }
    
    func unfix() {
        let frame = window.frame
        
        window.styleMask = [.resizable, .titled, .fullSizeContentView]
        window.standardWindowButton(NSWindowButton.closeButton)!.isHidden = true
        window.standardWindowButton(NSWindowButton.zoomButton)!.isHidden = true
        window.standardWindowButton(NSWindowButton.miniaturizeButton)!.isHidden = true
        
        window.setFrame(frame, display: true)
    }
    
    
    func setOptimizedFontSize() {
        window.setFrame(NSRect(x: window.frame.origin.x, y: window.frame.origin.y, width: window.frame.width, height: window.frame.width), display: true)
        
        if window.frame.width > 150 {
            window.setFrame(NSRect(x: window.frame.origin.x, y: window.frame.origin.y, width: 150, height: 150), display: true)
        }
    }
}
