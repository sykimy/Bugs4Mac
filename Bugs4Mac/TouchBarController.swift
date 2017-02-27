//
//  TouchBarController.swift
//  Bugs4Mac
//
//  Created by 김세윤 on 2017. 2. 26..
//  Copyright © 2017년 sykimy. All rights reserved.
//

import Cocoa

@available(OSX 10.12.2, *)
class TouchBarController:NSViewController, NSTouchBarDelegate, NSScrubberDelegate, NSScrubberDataSource {
    public func numberOfItems(for scrubber: NSScrubber) -> Int {
        return 116
    }

    public func scrubber(_ scrubber: NSScrubber, viewForItemAt index: Int) -> NSScrubberItemView {
        let item = BSScrubberItemView(frame: NSRect(x: 0, y: 0, width: 3, height: 30))
        
        if index < scrubberNow {
            item.setColor(NSColor(red: r, green: g, blue: b, alpha: 1.0).cgColor)
        }
        else {
            item.setColor(CGColor(red: r, green: g, blue: b, alpha: 0.3))
        }
        
        return item
    }

    let nc = NotificationCenter.default
    
    @IBOutlet var player: PlayerController!
    @IBOutlet var preference: PreferenceViewController!
    @IBOutlet var prevButton: NSButton!
    @IBOutlet var likeButton: NSButton!
    @IBOutlet var streamingTypeButton: NSButton!
    @IBOutlet var repeatButton: NSButton!
    @IBOutlet var randomButton: NSButton!
    @IBOutlet var addSimilarButton: NSButton!
    @IBOutlet var searchButton: NSButton!
    @IBOutlet var lyricButton: NSButton!
    @IBOutlet var preferenceButton: NSButton!
    @IBOutlet var volumeSlider: NSSlider!
    @IBOutlet var scrubberLikeButton: NSButton!
    @IBOutlet var scrubberAlbumImageButton: NSButton!
    @IBOutlet var scrubber: NSScrubber!
    
    @IBOutlet var tb: NSTouchBar!
    @IBOutlet var othersTB: NSTouchBar!
    @IBOutlet var scrubberTouchBar: NSTouchBar!
    
    @IBOutlet var albumImageButton: NSButton!
    
    @IBOutlet var label: NSTextField!
    
    var artist = ""
    var name = ""
    
    var total = 0
    var now = 0
    
    var lyricTimer:Timer!
    
    var isScrubber = false
    
    var playerState = 0
    
    var scrubberNow = 0
    
    var r:CGFloat = 0
    var g:CGFloat = 0
    var b:CGFloat = 0
    
    var latedScrubberHighlight = 0
    var scrubberChange = false
    
    override func awakeFromNib() {
        nc.addObserver(self, selector: #selector(TouchBarController.changeImage), name: NSNotification.Name(rawValue: "touchBarImage"), object: nil)
        nc.addObserver(self, selector: #selector(TouchBarController.changeRepeat), name: NSNotification.Name(rawValue: "touchBarRepeat"), object: nil)
        nc.addObserver(self, selector: #selector(TouchBarController.changeRandom), name: NSNotification.Name(rawValue: "touchBarRandom"), object: nil)
        nc.addObserver(self, selector: #selector(TouchBarController.changeLike), name: NSNotification.Name(rawValue: "touchBarLike"), object: nil)
        nc.addObserver(self, selector: #selector(TouchBarController.changeLyric), name: NSNotification.Name(rawValue: "touchBarLyric"), object: nil)
        nc.addObserver(self, selector: #selector(TouchBarController.changeProgress), name: NSNotification.Name(rawValue: "touchBarTimeInfo"), object: nil)
        
        NSApplication.shared().touchBar = tb
        
        
        scrubber.register(NSScrubberTextItemView.self, forItemIdentifier: "RatingScrubberItemIdentifier")
        scrubber.isContinuous = true
        //scrubber.selectionBackgroundStyle = NSScrubberSelectionStyle.outlineOverlay
        scrubber.selectionOverlayStyle = NSScrubberSelectionStyle.roundedBackground
        scrubber.delegate = self
        scrubber.backgroundColor = NSColor.clear
        scrubber.dataSource = self
        
        
        //prevBar.view?.setFrameSize(NSSize(width: 50, height: 30))
        super.awakeFromNib()
    }
    
    func scrubber(_ scrubber: NSScrubber, didSelectItemAt selectedIndex: Int) {
    }
    
    func scrubber(_: NSScrubber, didHighlightItemAt highlightIndex: Int) {
        for i in 0..<116 {
            if i < scrubber.highlightedIndex {
                (scrubber.itemViewForItem(at: i) as! BSScrubberItemView).setColor(NSColor(red: r, green: g, blue: b, alpha: 1.0).cgColor)
            }
            else {
                (scrubber.itemViewForItem(at: i) as! BSScrubberItemView).setColor(NSColor(red: r, green: g, blue: b, alpha: 0.3).cgColor)
            }
        }
        
    }
    
    func didFinishInteracting(with scrubber: NSScrubber) {
        let now = Float(scrubber.selectedIndex)/Float(116)
        player.webPlayer.jump(to: CGFloat(now))
        scrubberChange = true
    }
    
    func changeProgress(notification:NSNotification) {
        let info = notification.userInfo
        total = info?["totalTimeInt"] as! Int
        now = info?["playTimeInt"] as! Int
        if total != 0 {
            scrubberNow = Int(Float(now)/Float(total) * 116)
        }

        if scrubber.highlightedIndex == -1 {
            if scrubberChange {
                if scrubber.selectedIndex-1 <= scrubberNow {
                    scrubberChange = false
                }
            }
            else {
                scrubber.reloadData()
            }
        }
    }
    
    func changeImage(notification:NSNotification) {
        let info = notification.userInfo
        let image = info?["image"] as! NSImage
        albumImageButton.image = image
        albumImageButton.imageScaling = NSImageScaling(rawValue: 2)!
        
        scrubberAlbumImageButton.image = image
        scrubberAlbumImageButton.imageScaling = NSImageScaling(rawValue: 2)!
        
        name = info?["title"] as! String
        artist = info?["artist"] as! String
        r = info?["r"] as! CGFloat
        g = info?["g"] as! CGFloat
        b = info?["b"] as! CGFloat
        
        print("\(r) \(g) \(b)")
        
        if playerState == 0 {
            label.stringValue = name + " - " + artist
        }
    }
    
    func changeLyric() {
        label.stringValue = player.webPlayer.getLyricsNow()
    }
    
    func changeRepeat(notification:NSNotification) {
        let info = notification.userInfo
        let state = info?["repeat"] as! Int
        
        if state == 0 {//일반 재생
            repeatButton.title = "N"
        }
        else if state == 1 {//전체 재생
            repeatButton.title = "A"
        }
        else {//한곡생생
            repeatButton.title = "O"
        }
    }
    
    func changeRandom(notification:NSNotification) {
        let info = notification.userInfo
        let state = info?["random"] as! Bool
        
        if state {
            randomButton.title = "R"
        }
        else {
            randomButton.title = "N"
        }
    }
    
    func changeLike(notification:NSNotification) {
        let info = notification.userInfo
        let state = info?["like"] as! Bool
        
        if state {
            likeButton.title = "L"
            scrubberLikeButton.title = "L"
        }
        else {
            likeButton.title = "l"
            scrubberLikeButton.title = "l"
        }
    }
    
    @IBAction func prev(_ sender: Any) {
        player.fnPrev()
    }
    
    @IBAction func play(_ sender: Any) {
        player.fnPlay()
    }
    
    @IBAction func next(_ sender: Any) {
        player.fnNext()
    }
    
    @IBAction func like(_ sender: Any) {
        player.like(sender as AnyObject)
    }
    
    @IBAction func album(_ sender: Any) {
        playerState += 1
        if playerState == 3 {
            NSApplication.shared().touchBar = tb
            isScrubber = false
            playerState = 0
        }
        
        if playerState == 0 {
            label.stringValue = name + " - " + artist
        }
        
        if playerState == 1 {
            if lyricTimer != nil {
                lyricTimer.invalidate()
            }
            lyricTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(changeLyric), userInfo: nil, repeats: true)
        }
        else {
            if lyricTimer != nil {
                lyricTimer.invalidate()
            }
        }
        
        if playerState == 2 {
            NSApplication.shared().touchBar = scrubberTouchBar
            isScrubber = true
        }
    }
    
    @IBAction func others(_ sender: Any) {
        NSApplication.shared().touchBar = othersTB
    }
    
    @IBAction func main(_ sender: Any) {
        if isScrubber {
            NSApplication.shared().touchBar = scrubberTouchBar
        }
        else {
            NSApplication.shared().touchBar = tb
        }
    }
    
    @IBAction func streamingType(_ sender: Any) {
        player.streamingType(sender as AnyObject)
    }
    
    @IBAction func repeatType(_ sender: Any) {
        player.repeatList(sender as AnyObject)
    }
    
    @IBAction func random(_ sender: Any) {
        player.random(sender as AnyObject)
    }
    
    @IBAction func addSimilar(_ sender: Any) {
        player.addSimilar(sender as AnyObject)
    }
    
    @IBAction func search(_ sender: Any) {
        player.search.keySearch(sender as AnyObject)
    }
    
    @IBAction func showLyric(_ sender: Any) {
        player.lyricPlayer.showLyric(sender as AnyObject)
    }
    
    @IBAction func openPreference(_ sender: Any) {
        preference.openPreferences(sender as AnyObject)
    }
    
    
}
