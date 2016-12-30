//
//  TodayViewController.swift
//  BugsWidget
//
//  Created by 김세윤 on 2016. 12. 20..
//  Copyright © 2016년 sykimy. All rights reserved.
//

import Cocoa
import NotificationCenter


class TodayViewController: NSViewController, NCWidgetProviding {
    
    let nc = NotificationCenter.default
    let sharedUserDefaults = UserDefaults.init(suiteName: "group.bugs4mac.sykimy")
    
    //곡 정보 표시
    @IBOutlet var titleText: NSTextField!
    @IBOutlet var artistText: NSTextField!
    @IBOutlet var albumText: NSTextField!
    
    //진행바
    @IBOutlet var progressBar: WidgetProgressBarView!
    
    //메인뷰
    @IBOutlet var widgetView: WidgetView!
    
    //곡 시간 정보
    @IBOutlet var playTimeText: NSTextField!
    @IBOutlet var totalTimeString: NSTextField!
    @IBOutlet var slash: NSTextField!
    
    //버튼
    @IBOutlet var playButton: NSButton!
    @IBOutlet var nextButton: NSButton!
    @IBOutlet var prevButton: NSButton!
    @IBOutlet var likeButton: NSButton!
    @IBOutlet var bugsButton: NSButton!
    
    //검색창
    @IBOutlet var search: NSSearchField!
    
    //곡이 실행중인가
    var isPlay = false
    
    //곡이 좋아요 상탱인가
    var isLike = false
    
    override var nibName: String? {
        
        return "TodayViewController"
    }
    
    override func awakeFromNib() {
        //벅스 앱으로부터 받아온다.
        sharedUserDefaults?.addObserver(self, forKeyPath: "timeInfo", options: NSKeyValueObservingOptions.new, context: nil)
        sharedUserDefaults?.addObserver(self, forKeyPath: "songInfo", options: NSKeyValueObservingOptions.new, context: nil)
        sharedUserDefaults?.addObserver(self, forKeyPath: "isPlay", options: NSKeyValueObservingOptions.new, context: nil)
        sharedUserDefaults?.addObserver(self, forKeyPath: "isPause", options: NSKeyValueObservingOptions.new, context: nil)
        sharedUserDefaults?.addObserver(self, forKeyPath: "isLike", options: NSKeyValueObservingOptions.new, context: nil)
        sharedUserDefaults?.addObserver(self, forKeyPath: "isUnLike", options: NSKeyValueObservingOptions.new, context: nil)
        sharedUserDefaults?.addObserver(self, forKeyPath: "on", options: NSKeyValueObservingOptions.new, context: nil)
        sharedUserDefaults?.addObserver(self, forKeyPath: "isRadio", options: NSKeyValueObservingOptions.new, context: nil)
        
        self.widgetView.delegate = self
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Update your data and prepare for a snapshot. Call completion handler when you are done
        // with NoData if nothing has changed or NewData if there is new data since the last
        // time we called you
        
        self.widgetView.delegate = self
        
        //아티스트의 글자색을 회색으로
        artistText.textColor = NSColor.darkGray
        
        completionHandler(.noData)
    }
    
    override func viewWillAppear() {
        //사용자가 뷰를 요청할떄마다 (위젯을 킬때마다)
        //곡정보 반영
        let info = sharedUserDefaults?.object(forKey: "songInfo") as! NSDictionary
        
        titleText.stringValue = info.object(forKey: "title") as! String
        artistText.stringValue = info.object(forKey: "artist") as! String
        albumText.stringValue = info.object(forKey: "album") as! String
        
        /* 진행바 색 변경 */
        let r = info.object(forKey: "r") as! CGFloat
        let g = info.object(forKey: "g") as! CGFloat
        let b = info.object(forKey: "b") as! CGFloat
        
        progressBar.changeBarColor(r, g: g, b: b)
        
        //시간정보 반영
        refreshTimeInfo()
        sendTimeInfoNotification2ProgressBar()
        
        setButtonHide()
        playButton.image = NSImage(named: "widgetplay.png")
        nextButton.image = NSImage(named: "widgetnext.png")
        prevButton.image = NSImage(named: "widgetprev.png")
        likeButton.image = NSImage(named: "widgetlike.png")
        bugsButton.image = NSImage(named: "widgetload.png")
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "songInfo" {
            let info = sharedUserDefaults?.object(forKey: "songInfo") as! NSDictionary
            
            titleText.stringValue = info.object(forKey: "title") as! String
            artistText.stringValue = info.object(forKey: "artist") as! String
            albumText.stringValue = info.object(forKey: "album") as! String
            
            /* 진행바 색 변경 */
            let r = info.object(forKey: "r") as! CGFloat
            let g = info.object(forKey: "g") as! CGFloat
            let b = info.object(forKey: "b") as! CGFloat
            
            progressBar.changeBarColor(r, g: g, b: b)
        }
        else if keyPath == "timeInfo" {
            refreshTimeInfo()
            sendTimeInfoNotification2ProgressBar()
        }
        else if keyPath == "isPlay" {
            playButton.image = NSImage(named: "widgetpause.png")
            isPlay = false
        }
        else if keyPath == "isPause" {
            playButton.image = NSImage(named: "widgetplay.png")
            isPlay = true
        }
        else if keyPath == "isLike" {
            isLike = false
            likeButton.alphaValue = 1.0
        }
        else if keyPath == "isUnLike" {
            isLike = true
            likeButton.alphaValue = 0.3
        }
    }
    
    func refreshTimeInfo() {
        let timeInfo = sharedUserDefaults?.object(forKey: "timeInfo") as! NSDictionary!
        
        totalTimeString.stringValue = timeInfo?.object(forKey: "totalTimeString") as! String
        playTimeText.stringValue = timeInfo?.object(forKey: "playTimeString") as! String
    }
    
    func sendTimeInfoNotification2ProgressBar() {
        let timeInfo = sharedUserDefaults?.object(forKey: "timeInfo") as! NSDictionary!
        nc.post(name: Notification.Name(rawValue: "syncPlayerTime"), object: self, userInfo: timeInfo as! [AnyHashable : Any]?)
    }
    
    @IBAction func open(_ sender: Any) {
        var state = false
        if sharedUserDefaults?.object(forKey: "open") != nil {
            state = sharedUserDefaults?.object(forKey: "open") as! Bool
        }
        
        sharedUserDefaults?.set(!state, forKey: "open")
        sharedUserDefaults?.synchronize()
    }
    
    @IBAction func prev(_ sender: Any) {
        var state = false
        if sharedUserDefaults?.object(forKey: "prev") != nil {
            state = sharedUserDefaults?.object(forKey: "prev") as! Bool
        }
        
        sharedUserDefaults?.set(!state, forKey: "prev")
        sharedUserDefaults?.synchronize()
    }
    
    @IBAction func play(_ sender: Any) {
        if isPlay {
            isPlay = false
            playButton.image = NSImage(named: "widgetpause.png")
        }
        else {
            isPlay = true
            playButton.image = NSImage(named: "widgetplay.png")
        }
        
        var state = false
        if sharedUserDefaults?.object(forKey: "play") != nil {
            state = sharedUserDefaults?.object(forKey: "play") as! Bool
        }
        
        sharedUserDefaults?.set(!state, forKey: "play")
        sharedUserDefaults?.synchronize()
    }
    
    @IBAction func next(_ sender: Any) {
        var state = false
        if sharedUserDefaults?.object(forKey: "next") != nil {
            state = sharedUserDefaults?.object(forKey: "next") as! Bool
        }
        
        sharedUserDefaults?.set(!state, forKey: "next")
        sharedUserDefaults?.synchronize()
    }
    
    @IBAction func like(_ sender: Any) {
        if isLike {
            isLike = false
            likeButton.alphaValue = 1.0
        }
        else {
            isLike = true
            likeButton.alphaValue = 0.3
        }
        
        var state = false
        if sharedUserDefaults?.object(forKey: "like") != nil {
            state = sharedUserDefaults?.object(forKey: "like") as! Bool
        }
        
        sharedUserDefaults?.set(!state, forKey: "like")
        sharedUserDefaults?.synchronize()
    }
    
    @IBAction func search(_ sender: Any) {
        if search.stringValue != "" {
            sharedUserDefaults?.set(search.stringValue, forKey: "search")
            sharedUserDefaults?.synchronize()
            
            search.stringValue = ""
        }
    }
}

//마우스의 In/Out여부로 버튼을 보이고 가린다.
extension TodayViewController:WidgetViewDelegate {
    func widgetView(isIn:Bool) {
        if isIn { mouseIn() }
        else { mouseOut() }
    }
    
    func mouseIn() {
        checkPlayState()
        
        if sharedUserDefaults?.object(forKey: "isRadio") != nil && sharedUserDefaults?.object(forKey: "isRadio") as! Bool {
            playButton.isHidden = false
            nextButton.isHidden = false
            bugsButton.isHidden = false
            search.isHidden = false
            
            titleText.alphaValue = 0.1
            artistText.alphaValue = 0.1
            albumText.alphaValue = 0.1
            totalTimeString.alphaValue = 0.1
            playTimeText.alphaValue = 0.1
            slash.alphaValue = 0.1
        }
        else {
            checkLikeState()
            setButtonShow()
        }
    }
    
    func mouseOut() {
        setButtonHide()
    }
    
    //PlayerController에 실행중인지 물어본다.
    func checkPlayState() {
        var state = false
        if sharedUserDefaults?.object(forKey: "checkPlay") != nil {
            state = sharedUserDefaults?.object(forKey: "checkPlay") as! Bool
        }
        
        sharedUserDefaults?.set(!state, forKey: "checkPlay")
        sharedUserDefaults?.synchronize()
    }
    
    //좋아요가 되있는지 물어본다.
    func checkLikeState() {
        var state = false
        if sharedUserDefaults?.object(forKey: "checkLike") != nil {
            state = sharedUserDefaults?.object(forKey: "checkLike") as! Bool
        }
        
        sharedUserDefaults?.set(!state, forKey: "checkLike")
        sharedUserDefaults?.synchronize()
    }
    
    
    func setButtonHide() {
        playButton.isHidden = true
        nextButton.isHidden = true
        prevButton.isHidden = true
        likeButton.isHidden = true
        bugsButton.isHidden = true
        search.isHidden = true
        
        titleText.alphaValue = 1
        artistText.alphaValue = 1
        albumText.alphaValue = 1
        totalTimeString.alphaValue = 1
        playTimeText.alphaValue = 1
        slash.alphaValue = 1
    }
    
    func setButtonShow() {
        playButton.isHidden = false
        nextButton.isHidden = false
        prevButton.isHidden = false
        likeButton.isHidden = false
        bugsButton.isHidden = false
        search.isHidden = false
        
        titleText.alphaValue = 0.1
        artistText.alphaValue = 0.1
        albumText.alphaValue = 0.1
        totalTimeString.alphaValue = 0.1
        playTimeText.alphaValue = 0.1
        slash.alphaValue = 0.1
    }
}
