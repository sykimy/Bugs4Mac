//
//  WallpaperText.swift
//  Bugs
//
//  Created by 김세윤 on 2016. 10. 19..
//  Copyright © 2016년 sykimy. All rights reserved.
//

import Cocoa

class WallpaperLyric: NSObject {
    let nc = NotificationCenter.default
    
    private var innerColor:NSColor = NSColor.black
    private var outerColor:NSColor = NSColor.black
    private var font:NSFont!
    private var alignment = -1
    
    private var textView:BSTextView!
    private var scrollView:NSScrollView!
    
    var textStorage:NSTextStorage!
    var layoutManager:NSLayoutManager!
    var textContainer:NSTextContainer!
    
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
        
        scrollView = NSScrollView(frame: NSRect(x: 0, y: 0, width: window.frame.width, height: window.frame.height))
        scrollView.drawsBackground = false
        scrollView.verticalScroller?.isEnabled = true
        scrollView.verticalScroller?.isHidden = true
        
        textContainer = NSTextContainer(containerSize: window.frame.size)
        layoutManager = NSLayoutManager()
        textStorage = NSTextStorage()
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        
        /* textField설정 */
        textView = BSTextView(frame: window.frame, textContainer: textContainer)
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = NSColor.clear
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.documentView = textView
        
        setFont(font: NSFont.systemFont(ofSize: 15))
        
        window.contentView = scrollView
        
        
        open()
    }
    
    func setAlignment(_ alignment:Int) {
        self.alignment = alignment
    }
    
    func setLevel(level:Int) {
        window.level = level
    }
    
    deinit {
        close()
    }
    
    func isEmpty()->Bool {
        return textView.isEmpty()
    }
    
    func setFrame(rect:NSRect) {
        window.setFrame(rect, display: true, animate: false)
    }
    
    func frame()->NSRect {
        return window.frame
    }
    
    func setInnerColor(color:NSColor) {
        innerColor = color
    }
    
    func setOuterColor(color:NSColor) {
        outerColor = color
    }
    
    func setFont(font:NSFont) {
        self.font = font
    }
    
    func getInnerColor()->NSColor {
        return innerColor
    }
    
    func getOuterColor()->NSColor {
        return outerColor
    }
    
    func setText(lyric:Lyrics) {
        textView.set(lyric)
        
        textView.setNowPlayingLyric(now: 1)
        
        textView.makeLyric2AttributedString(font: font, innerColor: innerColor, outerColor: outerColor, alignment: alignment)
        
        textView.resizeViewAndContainerToFitAttributedString()
        
        /* 현재 재생중인 가사가 중앙에오게 스크롤을 이동시킨다. */
        textView.scrollToNowPlayingLyric(window.frame.height/2)
    }
    
    func refresh(numOflyric:Int) {
        textView.setNowPlayingLyric(now: numOflyric)
        
        textView.makeLyric2AttributedString(font: font, innerColor: innerColor, outerColor: outerColor, alignment: alignment)
        
        /* TextStroage를 비운다. */
        textView.removeTextStorage()
        
        /* 새로운 AttributedString을 TextStorage에 넣는다. */
        textView.addAttributedString2TextStorage()
        
        /* 현재 재생중인 가사가 중앙에오게 스크롤을 이동시킨다. */
        textView.scrollToNowPlayingLyric(window.frame.height/2)
    }
    
    func refreshOneLine(numOflyric:Int) {
        textView.setNowPlayingLyric(now: numOflyric)
        
        textView.makeOneLineLyric2AttributedString(font: font, innerColor: innerColor, outerColor: outerColor, alignment: alignment)
        
        /* TextStroage를 비운다. */
        textView.removeTextStorage()
        
        /* 새로운 AttributedString을 TextStorage에 넣는다. */
        textView.addAttributedString2TextStorage()
        
        /* 현재 재생중인 가사가 중앙에오게 스크롤을 이동시킨다. */
        textView.scrollToTop()
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
        
        window.backgroundColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0.5)
        
        window.styleMask = [.resizable, .titled, .fullSizeContentView]
        window.standardWindowButton(NSWindowButton.closeButton)!.isHidden = true
        window.standardWindowButton(NSWindowButton.zoomButton)!.isHidden = true
        window.standardWindowButton(NSWindowButton.miniaturizeButton)!.isHidden = true
        
        window.setFrame(frame, display: true)
        scrollView.frame(forAlignmentRect: window.frame)
    }
    
    func setOptimizedFontSize() {
        //print("!")
        //scrollView.setFrameOrigin(NSPoint.zero)
        //scrollView.setFrameSize(NSSize(width: window.frame.width, height: window.frame.height))
    }
}
