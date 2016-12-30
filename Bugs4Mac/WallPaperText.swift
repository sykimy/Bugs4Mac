//
//  WallpaperText.swift
//  Bugs
//
//  Created by 김세윤 on 2016. 10. 19..
//  Copyright © 2016년 sykimy. All rights reserved.
//

import Cocoa

class WallpaperText: NSObject {
    let nc = NotificationCenter.default
    
    private var innerColor:NSColor = NSColor.black
    private var outerColor:NSColor = NSColor.black
    private var font:NSFont!
    private var alignment = -1
    var string:String!
    
    private var textField:NSTextField!
    
    var window = NSWindow()
    
    init(rect:NSRect) {
        super.init()
        //nc.addObserver(self, selector: #selector(setOptimizedFontSize), name: NSNotification.Name(rawValue: "NSViewFrameDidChangeNotification"), object: nil)
        
        window = NSWindow(contentRect: rect, styleMask: .borderless, backing: .buffered, defer: true)
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.hasShadow = false
        window.backgroundColor = NSColor.clear
        window.isOpaque = false
        
        /* 배경화면모드로 변경 */
        window.level = Int(CGWindowLevelForKey(.desktopWindow))
        
        /* textField설정 */
        textField = NSTextField(frame: window.frame)
        textField.isBezeled = false
        textField.drawsBackground = false
        textField.isEditable = false
        textField.isSelectable = false
        
        setFont(font: NSFont.systemFont(ofSize: 15))
        
        window.contentView = textField
        
        open()
    }
    
    deinit {
        close()
    }
    
    func setAlignment(_ alignment:Int) {
        self.alignment = alignment
    }
    
    func getInnerColor()->NSColor {
        return innerColor
    }
    
    func getOuterColor()->NSColor {
        return outerColor
    }
    
    func setLevel(level:Int) {
        window.level = level
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
    
    func setText(string:String) {
        self.string = string
        var attributes = [String : AnyObject]()
        
        attributes[NSFontAttributeName] = font
        //attributes[NSForegroundColorAttributeName] = innerColor.blended(withFraction: 0.5, of: NSColor.black)
        attributes[NSForegroundColorAttributeName] = innerColor
        attributes[NSStrokeWidthAttributeName] = NSNumber.init(value: -1.0 as Float)
        attributes[NSStrokeColorAttributeName] = outerColor
        
        let textStyle = NSMutableParagraphStyle()
        if alignment == 1 {
            textStyle.alignment = NSTextAlignment.right
        }
        else if alignment == 0 {
            textStyle.alignment = NSTextAlignment.center
        }
        else {
            textStyle.alignment = NSTextAlignment.left
        }
        attributes[NSParagraphStyleAttributeName] = textStyle
        
        textField.attributedStringValue = NSAttributedString(string: string, attributes: attributes)
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
    }
    
    func setOptimizedFontSize() {
        if font != nil {
            for i in 1...1000 {
                if (NSFont(name: font.fontName, size : CGFloat(i))?.boundingRectForFont.height)! > textField.frame.height {
                    setFont(font: NSFont(name: font.fontName, size: CGFloat(i-1))!)
                    setText(string: textField.stringValue)
                    break
                }
            }
        }
    }
}
