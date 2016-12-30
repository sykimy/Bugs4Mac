//
//  BSTextView.swift
//  Bugs
//
//  Created by 김세윤 on 2016. 10. 10..
//  Copyright © 2016년 sykimy. All rights reserved.
//

import Cocoa

class BSTextView: NSTextView {
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }
    
    var lyric:Lyrics!
    var now = 0
    var attributedStr:NSMutableAttributedString! = NSMutableAttributedString(string: "")
    var pointOfNowPlayingLyric:CGFloat! = 0
    
    func isEmpty()->Bool {
        if lyric == nil {
            return true
        }
        return false
    }
    
    func set(_ lyric:Lyrics) {
        self.lyric = nil
        self.lyric = lyric
    }
    
    func setNowPlayingLyric(now:Int) {
        self.now = now
    }
    
    func makeLyric2AttributedString() {
        attributedStr = NSMutableAttributedString(string: "")
        
        for i in 1..<lyric.string.count {
            var attributes = [String : AnyObject]()
            attributes[NSForegroundColorAttributeName] = NSColor.white
            
            if i == now {
                attributes[NSFontAttributeName] = NSFont.systemFont(ofSize: 15)
                attributes[NSForegroundColorAttributeName] = NSColor.black
            }
            else {
                attributes[NSFontAttributeName] = NSFont.systemFont(ofSize: 14)
            }
            
            attributedStr.append(NSAttributedString(string: lyric.string[i] as String, attributes: attributes))
            
            attributes[NSFontAttributeName] = NSFont.systemFont(ofSize: 5)
            attributedStr.append(NSAttributedString(string: " \n", attributes: attributes))
            
            if i == now {
                pointOfNowPlayingLyric = attributedStr.boundingRect(with: CGSize(width: frame.width, height: 100000), options: [.usesLineFragmentOrigin, .usesFontLeading], context:nil).height-CGFloat(i)
            }
        }
    }
    
    //가사에 글꼴, 색상 등을 적용한다.
    func makeLyric2AttributedString(font:NSFont, innerColor:NSColor, outerColor:NSColor, alignment:Int) {
        attributedStr = NSMutableAttributedString(string: "")
        
        if lyric.string.count < 1 {
            return
        }
        
        for i in 1..<lyric.string.count {
            var attributes = [String : AnyObject]()
            //attributes[NSForegroundColorAttributeName] = innerColor.blended(withFraction: 0.5, of: NSColor.black)
            attributes[NSForegroundColorAttributeName] = innerColor
            
            if i == now {
                attributes[NSFontAttributeName] = font
                
                if innerColor.blueComponent+innerColor.redComponent+innerColor.greenComponent < 1 {
                    attributes[NSForegroundColorAttributeName] = innerColor
                    attributes[NSStrokeColorAttributeName] = outerColor.blended(withFraction: 0.5, of: NSColor.white)
                }
                else {
                    attributes[NSForegroundColorAttributeName] = innerColor.blended(withFraction: 7.0, of: NSColor.black)
                    attributes[NSStrokeColorAttributeName] = outerColor
                }
                attributes[NSStrokeWidthAttributeName] = NSNumber.init(value: -2.0 as Float)
            }
            else {
                attributes[NSFontAttributeName] = font
                attributes[NSStrokeWidthAttributeName] = NSNumber.init(value: -1.0 as Float)
                attributes[NSStrokeColorAttributeName] = outerColor
            }
            
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
            
            attributedStr.append(NSAttributedString(string: lyric.string[i] as String, attributes: attributes))
            
            attributes[NSFontAttributeName] = NSFont.systemFont(ofSize: 1)
            attributedStr.append(NSAttributedString(string: " \n", attributes: attributes))
            
            if i == now {
                pointOfNowPlayingLyric = attributedStr.boundingRect(with: CGSize(width: frame.width, height: 100000), options: [.usesLineFragmentOrigin, .usesFontLeading], context:nil).height
            }
        }
    }
    
    func makeOneLineLyric2AttributedString(font:NSFont, innerColor:NSColor, outerColor:NSColor, alignment:Int) {
        attributedStr = NSMutableAttributedString(string: "")
        
        if lyric.string.count < 1 {
            return
        }
        
        for i in 1..<lyric.string.count {
            var attributes = [String : AnyObject]()
            //attributes[NSForegroundColorAttributeName] = innerColor.blended(withFraction: 0.1, of: NSColor.black)
            attributes[NSForegroundColorAttributeName] = innerColor
            
            if i == now {
                attributes[NSFontAttributeName] = font
                attributes[NSForegroundColorAttributeName] = innerColor
                attributes[NSStrokeWidthAttributeName] = NSNumber.init(value: -2.0 as Float)
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
                
                attributedStr.append(NSAttributedString(string: lyric.string[i] as String, attributes: attributes))
            }
        }
    }
    
    func scrollToTop() {
        self.scroll(NSPoint(x: 0, y: 0))
    }
    
    func scrollToNowPlayingLyric(_ height:CGFloat) {
        self.scroll(NSPoint(x: 0, y: pointOfNowPlayingLyric-height))
    }
    
    func removeTextStorage() {
        /* 테스트뷰의 문자열을 삭제한다. */
        self.textStorage?.deleteCharacters(in: NSRange(location: 0, length: (self.textStorage?.length)!))
    }
    
    func addAttributedString2TextStorage() {
        self.textStorage?.append(attributedStr)
    }
    
    func resizeViewAndContainerToFitAttributedString() {
        /* 텍스트뷰의 크기를 총 가사의 크기로 맞춘다. */
        self.frame = CGRect(origin: .zero, size: NSSize(width: self.frame.width ,height: attributedStr.size().height))
        let rect = attributedStr.boundingRect(with: CGSize(width: frame.width, height: 100000), options: [.usesLineFragmentOrigin, .usesFontLeading], context:nil)
        
        /* 컨테이너의 길이를 조절한다. */
        self.textContainer?.size.height = rect.height
    }
}
