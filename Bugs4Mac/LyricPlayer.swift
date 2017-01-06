//
//  LyricPlayer.swift
//  Bugs
//
//  Created by 김세윤 on 2016. 10. 9..
//  Copyright © 2016년 sykimy. All rights reserved.
//

import Cocoa

/* 가사 플레이어 */
class LyricPlayer: NSObject, NSWindowDelegate {
    @IBOutlet var webPlayer: WebPlayerController!
    @IBOutlet var radio: RadioController!
    
    var textStorage:NSTextStorage!
    var textView:BSTextView!
    
    var layoutManager:NSLayoutManager!
    var textContainer:NSTextContainer!
    
    var window:NSWindow!
    
    var scrollView:NSScrollView!
    var view:NSView!
    
    var timer:Timer!
    
    var isOpen = false
    
    var titleView:TitleBarView!
    
    var backgroundView:NSView!
    
    let nc = NotificationCenter.default
    
    var mode = PlayerState.WebPlayer
    
    @IBOutlet var menu: NSMenu!
    @IBOutlet var alwaysTop: NSMenuItem!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nc.addObserver(self, selector: #selector(resizeView), name: NSNotification.Name(rawValue: "NSViewFrameDidChangeNotification"), object: nil)
        nc.addObserver(self, selector: #selector(showTitle), name: NSNotification.Name(rawValue: "titleMouseIn"), object: nil)
        nc.addObserver(self, selector: #selector(hideTitle), name: NSNotification.Name(rawValue: "titleMouseOut"), object: nil)
    }
    
    @IBAction func alwaysTop(_ sender: AnyObject) {
        if alwaysTop.state == 0 {
            alwaysTop.state = 1
            window.level = Int(CGWindowLevelForKey(.maximumWindow))
        }
        else {
            alwaysTop.state = 0
            window.level = Int(CGWindowLevelForKey(.normalWindow))
        }
    }
    
    
    @IBAction func showLyric(_ sender: AnyObject) {
        openWindow()
        
        if timer != nil {
            timer.invalidate()
        }
        
        switch mode {
        case .WebPlayer: timer = Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(getPlayerInfo), userInfo: nil, repeats: true)
        case .Radio: timer = Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(getRadioInfo), userInfo: nil, repeats: true)
        }
    }
    var image:NSImageView!
    
    func openWindow() {
        window = NSWindow(contentRect: NSMakeRect(600, 500, 350, 420), styleMask: [.titled, .closable, .resizable, .fullSizeContentView, .borderless], backing: NSBackingStoreType.buffered, defer: true)
        
        window.backgroundColor = NSColor.gray
        window.titlebarAppearsTransparent = true
        window.standardWindowButton(NSWindowButton.closeButton)!.isHidden = true
        window.standardWindowButton(NSWindowButton.zoomButton)!.isHidden = true
        window.standardWindowButton(NSWindowButton.miniaturizeButton)!.isHidden = true
        window.appearance = NSAppearance(named:NSAppearanceNameVibrantDark)
        
        
        
        titleView = TitleBarView(frame: NSRect(x: 0, y: window.frame.height-20, width: window.frame.width, height: 20))
        
        titleView.menu = menu
        
        view = NSView(frame: NSRect(x: 0, y: 0, width: window.frame.width, height: window.frame.height-25))
        scrollView = NSScrollView(frame: NSRect(x: 0, y: 0, width: window.frame.width, height: window.frame.height-25))
        
        image = NSImageView(frame: view.frame)
        
        view.addSubview(scrollView)
        scrollView.drawsBackground = false
        scrollView.verticalScroller?.isEnabled = true
        scrollView.verticalScroller?.isHidden = true
        
        textContainer = NSTextContainer(containerSize: view.frame.size)
        layoutManager = NSLayoutManager()
        textStorage = NSTextStorage()
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        
        textView = BSTextView(frame: view.frame, textContainer: textContainer)
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = NSColor.clear
        textView.alignment = NSTextAlignment.center
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        tmpImage = nil
        
        scrollView.documentView = textView
        
        window.contentView = image
        image.addSubview(view)
        image.addSubview(titleView)
        
        let controller = NSWindowController(window: window)
        controller.showWindow(self)
        
        prevTitle = ""
        prevId = 0
        prevLyric = ""
        prevNumOfLyric = -1
        
        isOpen = true
    }
    
    func closeWindow() {
        let controller = NSWindowController(window: window)
        controller.close()
        
        isOpen = false
        
        textStorage = nil
        textView = nil
        
        layoutManager = nil
        textContainer = nil
        
        image = nil
        scrollView = nil
        view = nil
        window = nil
    }
    
    //앨범커버 이미지를 확대하고 흐리게 한다.
    func blurImage(image:NSImage)->NSImage {
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setDefaults()
        filter?.setValue(CIImage(data: image.tiffRepresentation!), forKey: kCIInputImageKey)
        
        let outputImage = filter?.value(forKey: kCIOutputImageKey) as! CIImage
        let blurredImage = NSImage(size: NSRectFromCGRect(outputImage.extent).size)
        
        blurredImage.lockFocus()
        outputImage.draw(at: NSZeroPoint, from: NSRect(x: 85, y: 90, width: 200, height: 200), operation: .copy, fraction: 0.5)
        NSColor(calibratedRed: 0.6, green: 0.6, blue: 0.6, alpha: 0.5).set()
        NSRectFillUsingOperation(NSRect(origin: .zero, size: NSRectFromCGRect(outputImage.extent).size), .overlay)
        blurredImage.unlockFocus()
        
        return blurredImage
    }
    
    var prevId = 0
    var prevLyric = ""
    var tmpImage:NSImage!
    var prevURL:URL!
    var prevNumOfLyric = -1
    var beLyrics = false
    
    // 플레이어로부터 정보를 받아온다.
    func getPlayerInfo() {
        //라디오 모드라면
        if mode == .Radio {
            //타이머가 켜져있으면 타이머를 종료
            if timer != nil {
                timer.invalidate()
            }
            
            //라디오의 정보를 받아오는 타이머를 실행
            timer = Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(getRadioInfo), userInfo: nil, repeats: true)
            
            //함수 종료
            return
        }
        
        /* 문자열 초기화 */
        let numOflyric = webPlayer.getNumOfNowPlayingLyric()
        
        let id = webPlayer.getSongID()
        
        if prevId != id {
            let lyric = webPlayer.getLyrics()
            //print("id 가 변경됨")
            if webPlayer.beLyrics() && lyric.string.count != 0 {
                beLyrics = true
                //가사가 있는경우
                if prevLyric != lyric.string[0] as String {
                    //print("음악이 바뀜")
                    prevLyric = lyric.string[0] as String
                    
                    /* window title 설정 */
                    window.title = prevLyric
                    
                    /* textView 설정 */
                    /* 가사를 설정한다. */
                    textView.set(webPlayer.getLyrics())
                    
                    /*현재 재생중인 가사의 줄을 첫번째 줄이 되게 설정한다. */
                    textView.setNowPlayingLyric(now: 1)
                    
                    /* 받아온 가사로 AttributedString를 만든다. */
                    textView.makeLyric2AttributedString()
                    
                    /* AttributedString에 맞는 크기로 View와 Container의 크기를 조정한다. */
                    textView.resizeViewAndContainerToFitAttributedString()
                    
                    /* 현재 재생중인 가사가 중앙에오게 스크롤을 이동시킨다. */
                    textView.scrollToNowPlayingLyric(window.frame.height/2)
                    
                    prevNumOfLyric = -1
                    
                    var imageRect = CGRect(x: 0, y: 0, width: 100, height: 100)
                    tmpImage = blurImage(image: NSImage(cgImage: (NSImage(contentsOf: webPlayer.getAlbumImageURL() as URL)?.cgImage(forProposedRect: &imageRect ,context: nil, hints: nil))!, size: NSSize(width: 100, height: 100)))
                    
                    image.image = NSImage(cgImage: (tmpImage.cgImage(forProposedRect: &imageRect ,context: nil, hints: nil))!, size: NSSize(width: window.frame.width, height: window.frame.height))
                    
                    
                    prevId = id
                    
                }
            }
            else {
                //print("가사가 없는 경우")
                let title = webPlayer.getTitle()
                if prevTitle != title {
                    //print("음악이 바뀜")
                    
                    beLyrics = false
                    prevNumOfLyric = -1
                    
                    prevTitle = title
                    prevId = id
                    window.title = "\(webPlayer.getTitle()) - \(webPlayer.getArtist())"
                    
                    var imageRect = CGRect(x: 0, y: 0, width: 100, height: 100)
                    tmpImage = blurImage(image: NSImage(cgImage: (NSImage(contentsOf: webPlayer.getAlbumImageURL() as URL)?.cgImage(forProposedRect: &imageRect ,context: nil, hints: nil))!, size: NSSize(width: 100, height: 100)))
                    image.image = NSImage(cgImage: (tmpImage.cgImage(forProposedRect: &imageRect ,context: nil, hints: nil))!, size: NSSize(width: window.frame.width, height: window.frame.height))
                }
                
                
            }
        }
        else if prevNumOfLyric != numOflyric {
            prevNumOfLyric = numOflyric
            
            if !beLyrics {
                let noLyrics = Lyrics()
                noLyrics.append("")
                noLyrics.append("가사가 없습니다.")
                
                textView.set(noLyrics)
            }
            
            /* 가사를 갱신한다. */
            /*현재 재생중인 가사의 줄수를 설정한다. */
            textView.setNowPlayingLyric(now: numOflyric)
            
            /* 받아온 가사로 AttributedString를 만든다.(줄수를 반영한다.) */
            textView.makeLyric2AttributedString()
            
            /* TextStroage를 비운다. */
            textView.removeTextStorage()
            
            /*.새로운 AttributedString을 TextStorage에 넣는다. */
            textView.addAttributedString2TextStorage()
            
            /* 현재 재생중인 가사가 중앙에오게 스크롤을 이동시킨다. */
            textView.scrollToNowPlayingLyric(window.frame.height/2)
        }
    }
    
    var prevTitle = ""
    func getRadioInfo() {
        if mode == .WebPlayer {
            if timer != nil {
                timer.invalidate()
            }
            
            timer = Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(getPlayerInfo), userInfo: nil, repeats: true)
            
            return
        }
        
        /* 문자열 초기화 */
        let numOflyric = radio.getNumOfNowPlayingLyric()
        
        //id가 없기떄문에 title로 대체
        let title = radio.getTitle()
        
        if prevTitle != title {
            let lyric = radio.getLyrics()
            
            //가사가 있는 경우
            if radio.beLyrics() && lyric.string.count != 0 {
                beLyrics = true
                
                if prevLyric != lyric.string[0] as String {
                    prevLyric = lyric.string[0] as String
                    
                    /* window title 설정 */
                    window.title = prevLyric
                    
                    /* textView 설정 */
                    /* 가사를 설정한다. */
                    textView.set(radio.getLyrics())
                    
                    /*현재 재생중인 가사의 줄을 첫번째 줄이 되게 설정한다. */
                    textView.setNowPlayingLyric(now: 1)
                    
                    /* 받아온 가사로 AttributedString를 만든다. */
                    textView.makeLyric2AttributedString()
                    
                    /* AttributedString에 맞는 크기로 View와 Container의 크기를 조정한다. */
                    textView.resizeViewAndContainerToFitAttributedString()
                    
                    /* 현재 재생중인 가사가 중앙에오게 스크롤을 이동시킨다. */
                    textView.scrollToNowPlayingLyric(window.frame.height/2)
                    
                    prevNumOfLyric = -1
                    
                    var imageRect = CGRect(x: 0, y: 0, width: 100, height: 100)
                    tmpImage = blurImage(image: NSImage(cgImage: (NSImage(contentsOf: radio.getAlbumImageURL() as URL)?.cgImage(forProposedRect: &imageRect ,context: nil, hints: nil))!, size: NSSize(width: 100, height: 100)))
                    image.image = NSImage(cgImage: (tmpImage.cgImage(forProposedRect: &imageRect ,context: nil, hints: nil))!, size: NSSize(width: window.frame.width, height: window.frame.height))
                    
                    prevTitle = title
                    
                }
            }
            else {
                beLyrics = false
                prevNumOfLyric = -1
                
                window.title = "\(radio.getTitle()) - \(radio.getArtist())"
                
                var imageRect = CGRect(x: 0, y: 0, width: 100, height: 100)
                tmpImage = blurImage(image: NSImage(cgImage: (NSImage(contentsOf: radio.getAlbumImageURL() as URL)?.cgImage(forProposedRect: &imageRect ,context: nil, hints: nil))!, size: NSSize(width: 100, height: 100)))
                image.image = NSImage(cgImage: (tmpImage.cgImage(forProposedRect: &imageRect ,context: nil, hints: nil))!, size: NSSize(width: window.frame.width, height: window.frame.height))
                
                prevTitle = title
            }
        }
        else if prevNumOfLyric != numOflyric {
            prevNumOfLyric = numOflyric
            
            if !beLyrics {
                let noLyrics = Lyrics()
                noLyrics.append("")
                noLyrics.append("가사가 없습니다.")
                
                textView.set(noLyrics)
            }
            
            /* 가사를 갱신한다. */
            /*현재 재생중인 가사의 줄수를 설정한다. */
            textView.setNowPlayingLyric(now: numOflyric)
            
            /* 받아온 가사로 AttributedString를 만든다.(줄수를 반영한다.) */
            textView.makeLyric2AttributedString()
            
            /* TextStroage를 비운다. */
            textView.removeTextStorage()
            
            /*.새로운 AttributedString을 TextStorage에 넣는다. */
            textView.addAttributedString2TextStorage()
            
            /* 현재 재생중인 가사가 중앙에오게 스크롤을 이동시킨다. */
            textView.scrollToNowPlayingLyric(window.frame.height/2)
        }
    }
    
    func showTitle() {
        self.window.standardWindowButton(NSWindowButton.closeButton)!.isHidden = false
    }
    
    func hideTitle() {
        self.window.standardWindowButton(NSWindowButton.closeButton)!.isHidden = true
    }
    
    func resizeView() {
        if isOpen {
            //image.frame = window.frame
            scrollView.frame = view.frame
            textView.frame = NSRect(x: 0, y: 0, width: view.frame.width, height: textView.frame.height)
            textContainer.size = NSSize(width: view.frame.width, height: textContainer.size.height)
            titleView.frame = NSRect(x: 0, y: window.frame.height-20, width: window.frame.width, height: 20)
            view.frame = NSRect(x: 0, y: 0, width: window.frame.width, height: window.frame.height-25)
            var imageRect = CGRect(x: 0, y: 0, width: 100, height: 100)
            if tmpImage != nil {
                image.image = NSImage(cgImage: (image.image?.cgImage(forProposedRect: &imageRect ,context: nil, hints: nil))!, size: NSSize(width: window.frame.width, height: window.frame.height))
            }
            image.addSubview(view)
        }
    }
    
    func windowWillClose(_ notification: Notification) {
        closeWindow()
        
        if timer != nil {
            timer.invalidate()
        }
    }
}
