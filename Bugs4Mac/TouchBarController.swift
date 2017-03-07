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
    @IBOutlet var randomButton: NSButton!
    @IBOutlet var addSimilarButton: NSButton!
    @IBOutlet var searchButton: NSButton!
    @IBOutlet var lyricButton: NSButton!
    @IBOutlet var preferenceButton: NSButton!
    @IBOutlet var volumeSlider: NSSlider!
    @IBOutlet var scrubberLikeButton: NSButton!
    @IBOutlet var scrubberAlbumImageButton: NSButton!
    @IBOutlet var scrubber: NSScrubber!
    @IBOutlet var othersButton: NSButton!
    @IBOutlet var scrubberOthersButton: NSButton!
    @IBOutlet var othersOthersButton: NSButton!
    @IBOutlet var repeatButton: NSButton!
    
    @IBOutlet var scrubberPlayButton: NSButton!
    @IBOutlet var scrubberNextButton: NSButton!
    @IBOutlet var scrubberPrevButton: NSButton!
    @IBOutlet var nextButton: NSButton!
    @IBOutlet var playButton: NSButton!
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
    
    var isLyrics = false
    
    var mode = PlayerState.WebPlayer
    
    override func awakeFromNib() {
        nc.addObserver(self, selector: #selector(TouchBarController.changeImage), name: NSNotification.Name(rawValue: "touchBarImage"), object: nil)
        nc.addObserver(self, selector: #selector(TouchBarController.changeRepeat), name: NSNotification.Name(rawValue: "touchBarRepeat"), object: nil)
        nc.addObserver(self, selector: #selector(TouchBarController.changeRandom), name: NSNotification.Name(rawValue: "touchBarRandom"), object: nil)
        nc.addObserver(self, selector: #selector(TouchBarController.changeLike), name: NSNotification.Name(rawValue: "touchBarLike"), object: nil)
        nc.addObserver(self, selector: #selector(TouchBarController.changeProgress), name: NSNotification.Name(rawValue: "touchBarTimeInfo"), object: nil)
        nc.addObserver(self, selector: #selector(TouchBarController.changeStreamingType), name: NSNotification.Name(rawValue: "touchBarStreamingType"), object: nil)
        nc.addObserver(self, selector: #selector(TouchBarController.changeVolume), name: NSNotification.Name(rawValue: "touchBarVolume"), object: nil)
        nc.addObserver(self, selector: #selector(TouchBarController.changePlayState), name: NSNotification.Name(rawValue: "touchBarPlayState"), object: nil)
        nc.addObserver(self, selector: #selector(TouchBarController.changePlayer), name: NSNotification.Name(rawValue: "touchBarPlayer"), object: nil)
        
        NSApplication.shared().touchBar = tb
        
        
        scrubber.register(NSScrubberTextItemView.self, forItemIdentifier: "RatingScrubberItemIdentifier")
        scrubber.isContinuous = true
        //scrubber.selectionBackgroundStyle = NSScrubberSelectionStyle.outlineOverlay
        scrubber.selectionOverlayStyle = NSScrubberSelectionStyle.roundedBackground
        scrubber.delegate = self
        scrubber.backgroundColor = NSColor.clear
        scrubber.dataSource = self
        
        lyricButton.image = NSImage(named: "tblyric.png")
        searchButton.image = NSImage(named: "tbsearch.png")
        prevButton.image = NSImage(named: "tblyric.png")
        addSimilarButton.image = NSImage(named: "tbadd.png")
        preferenceButton.image = NSImage(named: "tbsetting.png")
        playButton.image = NSImage(named: "tbplay.png")
        nextButton.image = NSImage(named: "tbnext.png")
        prevButton.image = NSImage(named: "tbprev.png")
        likeButton.image = NSImage(named: "tbunlike.png")
        scrubberPlayButton.image = NSImage(named: "tbplay.png")
        scrubberNextButton.image = NSImage(named: "tbnext.png")
        scrubberPrevButton.image = NSImage(named: "tbprev.png")
        scrubberLikeButton.image = NSImage(named: "tbunlike.png")
        randomButton.image = NSImage(named: "tbunrandom.png")
        repeatButton.image = NSImage(named: "tbunrepeat.png")
        
        othersButton.image = NSImage(named: "tbothers")
        scrubberOthersButton.image = NSImage(named: "tbothers")
        othersOthersButton.image = NSImage(named: "tbothers")
        
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
    
    var prevState:Bool? = nil
    func changePlayState(notification:NSNotification) {
        let info = notification.userInfo
        let state = info?["state"] as! Bool
        
        if prevState != state {
            prevState = state
            if state {
                switch mode {
                case .WebPlayer:
                    scrubber.isHidden = false
                    playButton.image = NSImage(named: "tbpause.png")
                    scrubberPlayButton.image = NSImage(named: "tbpause.png")
                    break
                case .Radio:
                    prevButton.image = NSImage(named: "tbpause.png")
                    scrubberPrevButton.image = NSImage(named: "tbpause.png")
                    break
                }
            }
            else {
                switch mode {
                case .WebPlayer:
                    scrubber.isHidden = true
                    playButton.image = NSImage(named: "tbplay.png")
                    scrubberPlayButton.image = NSImage(named: "tbplay.png")
                    break
                case .Radio:
                    prevButton.image = NSImage(named: "tbplay.png")
                    scrubberPrevButton.image = NSImage(named: "tbplay.png")
                    break
                }
            }
        }
    }
    
    func changePlayer(notification:NSNotification) {
        let info = notification.userInfo
        mode = info?["mode"] as! PlayerState
        
        if mode == .Radio {
            prevButton.image = NSImage(named: "tbplay.png")
            playButton.image = NSImage(named: "tbnext.png")
            nextButton.image = NSImage(named: "tbunlike.png")
            scrubberLikeButton.image = NSImage(named: "tbhate.png")
            scrubberPrevButton.image = NSImage(named: "tbplay.png")
            scrubberPlayButton.image = NSImage(named: "tbnext.png")
            scrubberNextButton.image = NSImage(named: "tbunlike.png")
            likeButton.image = NSImage(named: "tbunhate.png")
            scrubber.isHidden = true
            repeatButton.isHidden = true
            randomButton.isHidden = true
            addSimilarButton.isHidden = true
            streamingTypeButton.isEnabled = false
            
        }
        else {
            prevButton.image = NSImage(named: "tbprev.png")
            playButton.image = NSImage(named: "tbplay.png")
            nextButton.image = NSImage(named: "tbnext.png")
            scrubberLikeButton.image = NSImage(named: "tbunlike.png")
            scrubberPrevButton.image = NSImage(named: "tbprev.png")
            scrubberPlayButton.image = NSImage(named: "tbplay.png")
            scrubberNextButton.image = NSImage(named: "tbnext.png")
            likeButton.image = NSImage(named: "tbunlike.png")
            scrubber.isHidden = false
            repeatButton.isHidden = false
            randomButton.isHidden = false
            addSimilarButton.isHidden = false
            streamingTypeButton.isEnabled = true
        }
    }
    
    func didFinishInteracting(with scrubber: NSScrubber) {
        let now = Float(scrubber.selectedIndex)/Float(116)
        player.webPlayer.jump(to: CGFloat(now))
        scrubberChange = true
    }
    
    func changeStreamingType(notification:NSNotification) {
        let info = notification.userInfo
        let state = info?["type"] as! String
        if state.characters.count > 10 {
            streamingTypeButton.controlSize = .mini
        }
        else {
            streamingTypeButton.controlSize = .small
        }
    
        streamingTypeButton.title = state
    }
    
    func changeVolume(notification:NSNotification) {
        let info = notification.userInfo
        let volume = info?["volume"] as! Int
        
        volumeSlider.integerValue = volume
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
                if scrubber.selectedIndex-1 <= scrubberNow && scrubberNow <= scrubber.selectedIndex+1 {
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
        
        if playerState == 0 {
            label.stringValue = name + " - " + artist
        }
        
        if mode == .WebPlayer {
            isLyrics = player.webPlayer.beLyrics()
        }
        else {
            isLyrics = player.radio.beLyrics()
            likeButton.isHidden = false
            scrubberLikeButton.isHidden = false
            scrubberNextButton.isHidden = false
            nextButton.isHidden = false
            
            likeButton.image = NSImage(named: "tbunhate.png")
            scrubberLikeButton.image = NSImage(named: "tbunhate.png")
            nextButton.image = NSImage(named: "tbunlike.png")
            scrubberNextButton.image = NSImage(named: "tbunlike.png")
        }
    }
    
    func changeLyric() {
        switch mode {
        case .Radio:
            if isLyrics {
                label.stringValue = player.radio.getLyricsNow()
            }
            else {
                label.stringValue = name + " - " + artist
            }
            break
        case .WebPlayer:
            if isLyrics {
                label.stringValue = player.webPlayer.getLyricsNow()
            }
            else {
                label.stringValue = name + " - " + artist
            }
        }
    }
    
    func changeRepeat(notification:NSNotification) {
        let info = notification.userInfo
        let state = info?["repeat"] as! Int

        if state == 0 {//일반 재생
            repeatButton.image = NSImage(named: "tbunrepeat.png")
        }
        else if state == 1 {//전체 재생
            repeatButton.image = NSImage(named: "tbrepeat.png")
        }
        else {//한곡생생
            repeatButton.image = NSImage(named: "tbrepeatonce.png")
        }
    }
    
    func changeRandom(notification:NSNotification) {
        let info = notification.userInfo
        let state = info?["random"] as! Bool
        
        if state {
            randomButton.image = NSImage(named: "tbrandom.png")
        }
        else {
            randomButton.image = NSImage(named: "tbunrandom.png")
        }
    }
    
    func changeLike(notification:NSNotification) {
        let info = notification.userInfo
        let state = info?["like"] as! Bool

        if state {
            switch mode {
            case .WebPlayer:
                scrubberLikeButton.image = NSImage(named: "tblike.png")
                likeButton.image = NSImage(named: "tblike.png")
                break
            case .Radio:
                scrubberNextButton.image = NSImage(named: "tblike.png")
                nextButton.image = NSImage(named: "tblike.png")
                break
            }
        }
        else {
            switch mode {
            case .WebPlayer:
                scrubberLikeButton.image = NSImage(named: "tbunlike.png")
                likeButton.image = NSImage(named: "tbunlike.png")
                break
            case .Radio:
                scrubberLikeButton.image = NSImage(named: "tbhate.png")
                likeButton.image = NSImage(named: "tbhate.png")
            }
        }
    }
    
    //WebPlayer : Prev
    //Radio : Play
    @IBAction func prev(_ sender: Any) {
        switch mode {
        case .WebPlayer:
            player.fnPrev()
            break
        case .Radio:
            player.fnPlay()
            break
        }
    }
    
    //WebPlayer : Play
    //Radio : Next
    @IBAction func play(_ sender: Any) {
        switch mode {
        case .WebPlayer:
            player.fnPlay()
            break
        case .Radio:
            player.fnNext()
            break
        }
    }
    
    //WebPlayer : Next
    //Radio : Like
    @IBAction func next(_ sender: Any) {
        switch mode {
        case .WebPlayer:
            player.fnNext()
            break
        case .Radio:
            player.like(sender as AnyObject)
            likeButton.isHidden = true
            scrubberLikeButton.isHidden = true
            break
        }
    }
    
    //WebPlayer : Like
    //Radio : Hate
    @IBAction func like(_ sender: Any) {
        switch mode {
        case .WebPlayer:
            player.like(sender as AnyObject)
            break
        case .Radio:
            player.repeatList(sender as AnyObject)
            nextButton.isHidden = true
            scrubberNextButton.isHidden = true
            likeButton.image = NSImage(named: "tbhate.png")
            scrubberLikeButton.image = NSImage(named: "tbhate.png")
            break
        }
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
    
    @IBAction func volume(_ sender: Any) {
        let volume = volumeSlider.integerValue
        player.changeVolume(volume)
    }
    
    
}
