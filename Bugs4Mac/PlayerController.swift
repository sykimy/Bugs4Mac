//
//  PlayerContorller.swift
//  Music
//
//  Created by sykimy on 2016. 8. 2..
//  Copyright © 2016년 sykimy. All rights reserved.
//

import Foundation
import Cocoa

enum PlayerState {
    case WebPlayer
    case Radio
}

class PlayerController:NSViewController, NSApplicationDelegate, NSWindowDelegate {
    let nc = NotificationCenter.default
    
    @IBOutlet var appDelegate: AppDelegate! //main
    @IBOutlet var nowPlayingListController: NowPlayingListController!   //재생목록
    @IBOutlet var webPlayer: WebPlayerController!   //웹플레이어
    @IBOutlet var sideListController: SideListController!   //사이드 리스트
    @IBOutlet var loginController: LoginWebViewController!  //로그인
    @IBOutlet var lyricPlayer: LyricPlayer! //가사플레이어
    @IBOutlet var wallPaperPlayer: WallpaperPlayer! //배경화면플레이어
    @IBOutlet var playerView: PlayerView!   //플레이어 뷰
    @IBOutlet var window: NSWindow!    //메인 창
    @IBOutlet var radio: RadioController!   //라디오 플레이어
    @IBOutlet var search: SearchController! //검색창
    
    @IBOutlet var toggle: NSMenu!
    
    var fullScreenMode = false
    
    var statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    /* DockAndMenuBarPreference에서 조작 */
    var cover2Icon = true
    var menuBarOption = 0
    var menuBarImageOption = 0
    var menuBar = false
    var dock = true
    
    /* AlarmCenterPreference에서 조작 */
    var funcKey = true
    var alarmCenter = true
    
    /* 라디오인지 웹플레이어인지 */
    var mode = PlayerState.WebPlayer
    
    var lyricTimer:Timer!
    
    var prevRadioTitle = ""
    
    let defaults = UserDefaults.standard
    
    let sharedUserDefaults = UserDefaults.init(suiteName: "group.bugs4mac.sykimy")
    
    /* 마우스 In/Out여부에 따라 투명도가 바뀌는 버튼 */
    @IBOutlet var prevButton: ButtonController!
    @IBOutlet var playButton: ButtonController!
    @IBOutlet var nextButton: ButtonController!
    @IBOutlet var loginButton: ButtonController!
    @IBOutlet var similarButton: ButtonController!
    
    /* 버튼 */
    @IBOutlet var likeButton: NSButton!
    @IBOutlet var randomButton: NSButton!
    @IBOutlet var repeatButton: NSButton!
    @IBOutlet var streamingTypeButton: NSButton!
    
    /* TextField */
    @IBOutlet var nameTextField: NSTextField!
    @IBOutlet var albumTextField: NSTextField!
    @IBOutlet var artistTextField: NSTextField!
    @IBOutlet var albumImageField: NSImageView!
    @IBOutlet var nowTime: NSTextField!
    @IBOutlet var totalTime: NSTextField!
    
    /* 볼륨바와 진행바 */
    @IBOutlet var volumeBar: NSSlider!
    @IBOutlet var progressBar: ProgressBarView!
    
    /* 로그인 팝업창 */
    @IBOutlet var loginpop: NSPopover!
    
    /* 노래가 변경되었는지 확인하기 위해 존재하는 변수 */
    //var songID = 0  //현재 재생중인 곡의 ID
    //var prevSongID = 0  //이전에 재생중인 곡의 ID
    
    /* ID가 더빠르게 변경됨 */
    var songName = ""
    var prevSongName = ""
    
    /* 재생목록이 변경되었는지 확인하기 위해 존재하는 변수 */
    var numOfSong = 0
    var prevNumOfSong = 0
    
    /* 로그인 여부를 저장하는 변수 */
    var isLogin = false
    
    /* 버튼의 투명화와 관련된 변수 */
    var isMouseInPlayer = false
    var isMouseInButton = false
    var trans = 1.0
    var buttonTrans = 0.0
    
    var syncTimer:Timer!
    var mouseInTimer:Timer!
    var mouseOutTimer:Timer!
    var listTimer:Timer!
    
    var nowLogin = false
    
    var prevNumOfLyrics = -1
    
    /* 버튼이 사라지고 생기는데 걸리는 시간 */
    var fadeValue: Double = 0.1
    var fadeTiming: Double = 0.01
    var fadeTime: Double = 0.1
    private var syncTiming = 0.5
    
    /* 화면이 꺼졌을 때 */
    func windowWillClose(_ notification: Notification) {
        /* 버튼 보이기를 해제한다. */
        hideTitleButton()
        self.window.titlebarAppearsTransparent = true
        
        nameTextField.textColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: CGFloat(1.0))
        albumTextField.textColor = NSColor(calibratedRed: 0.5, green: 0.5, blue: 0.5, alpha: CGFloat(1.0))
        artistTextField.textColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: CGFloat(1.0))
        albumImageField.alphaValue = CGFloat(1.0)
        
        prevButton.alphaValue = CGFloat(0)
        playButton.alphaValue = CGFloat(0)
        nextButton.alphaValue = CGFloat(0)
        volumeBar.alphaValue = CGFloat(0)
        loginButton.alphaValue = CGFloat(0)
        similarButton.alphaValue = CGFloat(0)
        search.alphaValue(value: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        /* GetMediaKey로부터 오는 notification */
        nc.addObserver(self, selector: #selector(PlayerController.fnPlay), name: NSNotification.Name(rawValue: "play"), object: nil)
        nc.addObserver(self, selector: #selector(PlayerController.fnNext), name: NSNotification.Name(rawValue: "next"), object: nil)
        nc.addObserver(self, selector: #selector(PlayerController.fnPrev), name: NSNotification.Name(rawValue: "prev"), object: nil)
        
        nc.addObserver(self, selector: #selector(PlayerController.enterFullScreen), name: NSNotification.Name.NSWindowDidEnterFullScreen, object: nil)
        nc.addObserver(self, selector: #selector(PlayerController.exitFullScreen), name: NSNotification.Name.NSWindowDidExitFullScreen, object: nil)
        
        /* 이미지 버튼의 이미지 파일을 불러온다. */
        //loginButton.image = NSImage(named: "login.png")
        loginButton.title = "로그인"
        prevButton.image = NSImage(named: "prev.png")
        playButton.image = NSImage(named: "play.png")
        nextButton.image = NSImage(named: "next.png")
        repeatButton.image = NSImage(named: "repeat.png")
        randomButton.image = NSImage(named: "random.png")
        likeButton.image = NSImage(named: "like.png")
        
        /* 투명화 되는 버튼들의 투명도를 설정한다. */
        repeatButton.alphaValue = CGFloat(0.3)
        randomButton.alphaValue = CGFloat(0.3)
        likeButton.alphaValue = CGFloat(0.3)
        prevButton.alphaValue = CGFloat(buttonTrans)
        playButton.alphaValue = CGFloat(buttonTrans)
        nextButton.alphaValue = CGFloat(buttonTrans)
        loginButton.alphaValue = CGFloat(buttonTrans)
        volumeBar.alphaValue = CGFloat(buttonTrans)
        similarButton.alphaValue = CGFloat(buttonTrans)
        search.alphaValue(value: CGFloat(buttonTrans))
        
        /* Widget으로 부터 받는 정보 */
        sharedUserDefaults?.addObserver(self, forKeyPath: "progressInfo", options: NSKeyValueObservingOptions.new, context: nil)
        sharedUserDefaults?.addObserver(self, forKeyPath: "play", options: NSKeyValueObservingOptions.new, context: nil)
        sharedUserDefaults?.addObserver(self, forKeyPath: "next", options: NSKeyValueObservingOptions.new, context: nil)
        sharedUserDefaults?.addObserver(self, forKeyPath: "prev", options: NSKeyValueObservingOptions.new, context: nil)
        sharedUserDefaults?.addObserver(self, forKeyPath: "open", options: NSKeyValueObservingOptions.new, context: nil)
        sharedUserDefaults?.addObserver(self, forKeyPath: "like", options: NSKeyValueObservingOptions.new, context: nil)
        sharedUserDefaults?.addObserver(self, forKeyPath: "checkPlay", options: NSKeyValueObservingOptions.new, context: nil)
        sharedUserDefaults?.addObserver(self, forKeyPath: "checkLike", options: NSKeyValueObservingOptions.new, context: nil)
        
        self.progressBar.delegate = self
        self.playerView.delegate = self
    }
    
    func hideTitleButton() {
        if !fullScreenMode {
            self.window.standardWindowButton(NSWindowButton.closeButton)!.isHidden = true
            self.window.standardWindowButton(NSWindowButton.zoomButton)!.isHidden = true
            self.window.standardWindowButton(NSWindowButton.miniaturizeButton)!.isHidden = true
        }
    }
    
    func showTitleButton() {
        self.window.standardWindowButton(NSWindowButton.closeButton)!.isHidden = false
        self.window.standardWindowButton(NSWindowButton.zoomButton)!.isHidden = false
        self.window.standardWindowButton(NSWindowButton.miniaturizeButton)!.isHidden = false
    }
    
    //-------------------------------------------------------------------------------------------------------------------------
    /* WebPlayer와 Player를 연동시킬 Timer를 작동시킨다. */
    func startSyncWithWebPlayer() {
        /* 사이드리스트를 불러온다. */
        sideListController.syncSideList()
        
        /* 볼륨값을 받아온다. */
        webPlayer.volume(getDefaultVolume())
    }
    
    func getDefaultVolume()->Int {
        if defaults.object(forKey: "volume") != nil {
            return defaults.integer(forKey: "volume")
        }
        
        return 354
    }
    
    //-------------------------------------------------------------------------------------------------------------------------
    //  SyncPreference 에서 호출하는 함수들
    //  웹플레이어와 플레이어의 동기화 타이밍, 버튼 Fade In/Out 타이밍 조절 등의 함수가 있다.
    
    /* 웹플레이어와 플레이어의 동기화 타이밍을 조절한다. */
    func setSyncTiming(_ t:Double) {
        /* 웹플레이어가 시작될때까지 대기한다. */
        
        var count = 0
        while(!webPlayer.isSync) {
            count += 1
            if count > 50 {
                break
            }
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        syncTiming = t
        
        switch mode {
        case .WebPlayer: startPlayer()
        case .Radio: startRadio()
        }
    }
    
    /* 얼마나 자주 화면을 갱신할지 조절한다. */
    func setFadeInOutTiming(_ t:Double) {
        fadeTiming = t
        if fadeTime == 0 {
            fadeValue = 0;
            return;
        }
        fadeValue = fadeTiming / fadeTime
    }
    
    /* 몇초동안 사라지게 할지 조절한다. */
    func setFadeInOutTime(_ t:Double) {
        fadeTime = t
        if fadeTime == 0 {
            fadeValue = 0;
            return;
        }
        fadeValue = fadeTiming / fadeTime
    }
    
    //-------------------------------------------------------------------------------------------------------------------------
    //  로그인과 관련된 함수 모음
    
    /* 로그인View를 Popup창으로 띄우는 함수 */
    var isLoginViewOpen = false
    @IBAction func login(_ sender: AnyObject) {
        /* 로그아웃 상태이면 */
        if !isLogin {
            /* 로그인뷰가 켜지있으면 로그인 뷰를 끈다. */
            if isLoginViewOpen {
                loginpop.close()
                loginController.deinitLogin()
                isLoginViewOpen = false
            }
                /* 로그인뷰가 꺼져있으면 로그인 뷰를 킨다. */
            else {
                loginController.initLoginView()
                loginpop.show(relativeTo: loginButton.bounds, of: loginButton, preferredEdge: NSRectEdge.maxY)
                isLoginViewOpen = true
            }
        }
            /* 로그인 상태이면 로그아웃을 진행한다. */
        else {
            webPlayer.logout()
            isLogin = false
        }
    }
    
    /* 로그인 상태로 변환하는 함수 */
    func loginComplete() {
        loginpop.close()
        isLogin = true
        //loginButton.image = NSImage(named: "logout.png")
        loginButton.title = "로그아웃"
    }
    
    /* 로그아웃 상태로 변환하는 함수 */
    func logoutComplete() {
        webPlayer.logout()
        //loginButton.image = NSImage(named: "login.png")
        loginButton.title  = "로그인"
        isLogin = false
    }
    
    //-------------------------------------------------------------------------------------------------------------------------
    //  사용자로부터 받는 각종 조작 함수 모음
    
    /* 재생 */
    func play() {
        switch mode {
        case .WebPlayer :
            if webPlayer.checkPlay() {
                playButton.image = NSImage(named: "play.png")
                webPlayer.pause()
            }
            else {
                playButton.image = NSImage(named: "pause.png")
                webPlayer.play()
            }
        case .Radio :
            if radio.checkPlay() {
                playButton.image = NSImage(named: "play.png")   //버튼이미지를 바꾼다.
                radio.pause()
            }
            else {
                playButton.image = NSImage(named: "pause.png")
                radio.play()
            }
        }
    }
    
    func next() {
        switch mode {
        case .WebPlayer :
            webPlayer.next()
        case .Radio :
            radio.next()
        }
    }
    
    /* 펑션키를 통한 이전곡 */
    /* 라디오에선 이전곡 버튼이 없다. */
    /* funKey 변수는 AlarmCenterPreference로부터 변한다. */
    func fnPrev() {
        if funcKey {
            webPlayer.prev()
        }
    }
    
    /* 펑션키를 통한 재생 */
    func fnPlay() {
        if funcKey {
            play()
        }
    }
    
    func fnNext() {
        if funcKey {
            next()
        }
    }
    
    //-------------------------------------------------------------------------------------------------------------------------
    //  사용자로부터 받는 각종 조작 버튼 액션 모음.
    
    /* 이전곡 버튼 */
    @IBAction func prev(_ sender: AnyObject) {
        webPlayer.prev()
    }
    
    /* 다음곡 버튼 */
    @IBAction func next(_ sender: AnyObject) {
        next()
    }
    
    /* 재생 버튼 */
    @IBAction func play(_ sender: AnyObject) {
        play()
    }
    
    /* 유사한 음악 추가 */
    @IBAction func addSimilar(_ sender: AnyObject) {
        webPlayer.addSimilarSong()
    }
    
    /* 볼륨 버튼 */
    @IBAction func volume(_ sender: AnyObject) {
        //0~40
        switch mode {
        case .WebPlayer :
            webPlayer.volume(Int(volumeBar.intValue)+334)
            defaults.set(Int(volumeBar.intValue)+334, forKey: "volume")
        case .Radio :
            let volume = Double(volumeBar.intValue)/40*58
            radio.volume(Int(volume)+100)
        }
    }
    
    /* 랜덤재생 버튼 */
    @IBAction func random(_ sender: AnyObject) {
        webPlayer.random()
        syncRandom()
    }
    
    /* 반복재생 버튼 */
    @IBAction func repeatList(_ sender: AnyObject) {
        switch mode {
        case .WebPlayer :
            webPlayer.repeatList()
            syncRepeat()
        case .Radio :
            radio.unlike()
            repeatButton.alphaValue = CGFloat(1.0)
            likeButton.isEnabled = false
        }
    }
    
    /* 좋아요 버튼 */
    @IBAction func like(_ sender: AnyObject) {
        switch mode {
        case .WebPlayer :
            let state = webPlayer.stateOfLike()
            
            webPlayer.like()
            if state {
                likeButton.alphaValue = CGFloat(0.3)
            }
            else {
                likeButton.alphaValue = CGFloat(1.0)
            }
        case .Radio :
            radio.like()
            likeButton.alphaValue = CGFloat(1.0)
            repeatButton.isEnabled = false
        }
    }
    
    /* 음질 선택 버튼 */
    @IBAction func streamingType(_ sender: AnyObject) {
        webPlayer.changeStreamingType()
        if webPlayer.getStreamingType() == 0 {
            streamingTypeButton.title = "AAC->320kbps"
        }
        else {
            streamingTypeButton.title = "320kbps->AAC"
            
        }
    }
    
    //-------------------------------------------------------------------------------------------------------------------------
    //  웹플레이어와 라디오의 연동을 시작해주는 함수 모음
    
    /* 라디오를 실행한다. */
    func startRadio() {
        /* 모든 연동 타이머를 초기화한다. */
        if syncTimer != nil { syncTimer.invalidate() }
        
        /* 라디오 타이머를 실행한다. */
        syncTimer = Timer.scheduledTimer(timeInterval: syncTiming, target: self, selector: #selector(syncWithRadio), userInfo: nil, repeats: true)
        
        /* 라디오 실행상태 변수 반영 */
        mode = .Radio
        
        /* 수정될 부분 */
        lyricPlayer.mode = .Radio
        
        /* 플레이어의 정보창을 라디오에 맞게 수정한다. */
        initRadioInfoScreen()
        
        /* 재생중인 곡은 정지시킨다. */
        webPlayer.pause()
        
        sendMode2Widget(mode:.Radio)
    }
    
    /* 웹플레이어를 실행한다. */
    func startPlayer() {
        /* 모든 타이머를 초기화한다. */
        if syncTimer != nil {
            syncTimer.invalidate()
        }
        
        /* 웹플레이어 타이머를 실행한다. */
        syncTimer = Timer.scheduledTimer(timeInterval: syncTiming, target: self, selector: #selector(syncWithWebPlayer), userInfo: nil, repeats: true)
        
        /* 수정될 부분 */
        lyricPlayer.mode = .WebPlayer
        
        /* 라디오 실행상태 변수 반영 */
        mode = .WebPlayer
        
        /* 플레이어의 정보창을 웹플레이어에 맞게 수정한다. */
        initWebPlayerInfoScreen()
        
        sendMode2Widget(mode:.WebPlayer)
    }
    
    func initRadioInfoScreen() {
        totalTime.stringValue = "--:--"
        nowTime.stringValue = "--:--"
        randomButton.isEnabled = false
        randomButton.isHidden = true
        repeatButton.image = NSImage(named: "unlike.png")
        prevButton.isHidden = true
        similarButton.isHidden = true
        streamingTypeButton.isEnabled = false
        streamingTypeButton.title = "Radio"
    }
    
    func initWebPlayerInfoScreen() {
        randomButton.isEnabled = true
        randomButton.isHidden = false
        repeatButton.isEnabled = true
        lyricPlayer.mode = .WebPlayer
        repeatButton.image = NSImage(named: "repeat.png")
        prevButton.isHidden = false
        similarButton.isHidden = false
        streamingTypeButton.isEnabled = true
        albumTextField.textColor = NSColor.gray
    }
    
    func sendMode2Widget(mode:PlayerState) {
        switch mode {
        case .WebPlayer:
            sharedUserDefaults?.set(false, forKey: "isRadio")
        case .Radio:
            sharedUserDefaults?.set(true, forKey: "isRadio")
        }
        sharedUserDefaults?.synchronize()
    }
    
    //-------------------------------------------------------------------------------------------------------------------------
    //  라디오 동기화 함수 관려 모음.
    
    /* 라디오 타이머의 함수(정해진 시간마다 라디오플레이어에서 곡 정보를 받아온다.) */
    func syncWithRadio() {
        
        /* 곡의 타이틀이 변경되면 함수를 실행한다. */
        if prevRadioTitle != radio.getTitle() {
            //이전곡을 현재 곡으로 다시 설정한다.
            prevRadioTitle = radio.getTitle()
            
            resetRadioLikeButton()  //좋아요, 싫어요 버튼을 리셋한다.
            
            /* 곡 정보를 반영한다. */
            nameTextField.stringValue = radio.getTitle()
            albumTextField.stringValue = radio.getArtist()
            artistTextField.stringValue = ""
            
            /* 라디오플레이어로부터 엘범 이미지를 받아온다. */
            var imageRect = CGRect(x: 0, y: 0, width: 150, height: 150)
            let albumImage = NSImage(cgImage: (NSImage(contentsOf: radio.getAlbumImageURL())?.cgImage(forProposedRect: &imageRect ,context: nil, hints: nil))!, size: NSSize(width: 150, height: 150))
            albumImageField.image = albumImage
            
            /* Dock Icon에 엘범 이미지 반영 */
            if cover2Icon {
                NSApp.applicationIconImage = albumImage
            }
            else {
                NSApp.applicationIconImage = NSImage(named: "AppIcon")
            }
            
            /* 앨범 커버의 색을 받아온다. */
            let (r, g, b) = getAverageRGB(albumImage)
            
            /* 위젯에 곡 정보를 보낸다. */
            sendSongInfo2Widget(title: nameTextField.stringValue, artist: albumTextField.stringValue, album: "", r: r, g: g, b: b)
            
            /* 진행바의 색을 변경한다. */
            progressBar.changeBarColor(r, g: g, b: b)
            
            //가사가 없을시 갱신하지 가사가 없음을 반영한다.
            var lyrics:Lyrics? = nil
            if radio.beLyrics() {
                lyrics = radio.getLyrics()
            }
            else {
                let noLyric = Lyrics()
                noLyric.append("")
                lyrics = noLyric
            }
            
            /* 배경화면 플레이어에 곡정보를 전달한다. */
            /* 배경화면 플레이어가 꺼져있다면 작동되지 않는다. wallPaperPlayer.set() 참조 */
            wallPaperPlayer.set(title: nameTextField.stringValue, artist: artistTextField.stringValue, album: albumTextField.stringValue, image: albumImage, lyric: lyrics!, color: NSColor(calibratedRed: r, green: g, blue: b, alpha: 1.0))
            
            /* 진행바의 상태를 반영한다.(라디오 상태에선 뜨지 않는다.) */
            progressBar.sync(totalTime: 1, playTime: 1)
            
            if menuBar {
                /* 아이콘 제어 */
                switch menuBarImageOption {
                case 0:
                    showMenuBarIconImage()
                case 1:
                    showMenuBarAlbumImage(image: albumImage)
                default:
                    hideMenuBarImage()
                }
                /* 텍스트 제어 */
                switch menuBarOption {
                case 0:
                    setMenuBarTextWithTitle()
                case 1:
                    setMenuBarTextWithTitleAndAlbum()
                case 2:
                    setMenuBarTextWithTitleAndAlbum()
                case 3:
                    setMenuBarTextWithLyric()
                default:
                    hideMenuBarText()
                }
            }
            else {
                hideMenuBarTextAndImage()
            }
        }
        
        /* 웹플레이어가 시작되면 라디오를 종료하고 다시 웹플레이어와 동기화한다. */
        if webPlayer.checkPlay() {
            startPlayer()
            /* 라디오 객체를 해제한다. */
            radio.deinitRadio()
        }
    }
    
    func resetRadioLikeButton() {
        /* 좋아요, 싫어요 버튼을 활성화한다. */
        likeButton.isEnabled = true
        repeatButton.isEnabled = true
        likeButton.alphaValue = CGFloat(0.3)
        repeatButton.alphaValue = CGFloat(0.3)
    }
    
    func syncLyricWithWebPlayer() {
        let numOfLyrics = webPlayer.getNumOfNowPlayingLyric()
        
        if prevNumOfLyrics != numOfLyrics {
            wallPaperPlayer.refreshLyric(numOfLyrics)
            prevNumOfLyrics = numOfLyrics
        }
    }
    
    /* WebPlayer로부터 값을 받아와 반영한다. */
    func syncWithWebPlayer() {
        /* WebPlayer로부터 시간 정보를 받아온다. */
        syncTimeWithWebPlayer()
        
        /* 실시간 가사를 갱신한다. */
        syncLyricWithWebPlayer()
        
        /* 플레이리스트가 없으면 갱신하지 않는다. */
        if !webPlayer.checkPlayList() {
            alertNoList()   //재생목록에 곡이 없다고 알린다.
            if nowPlayingListController.dataArray.count != 0 {
                _ = nowPlayingListController.getPlayList()
            }
        }
        else {
            songName = webPlayer.getTitle() //현재 재생곡의 타이틀을 받아온다.
            
            /* 노래가 변경되었으면 ID와 노래정보를 갱신한다. */
            if songName != prevSongName {
                nowLogin = false
                
                syncInfoWithWebPlayer()   //웹플레이어로부터 정보를 받아온다.
                syncLike()  //좋아요 정보를 받아온다.
                
                prevSongName = songName //현재 재생곡의 타이틀을 저장한다.

                _ = nowPlayingListController.getPlayList()  //플레이리스트를 불러온다.
           }
            
            /* 현재 플레이리스트의 음악수를 받아온다. */
            numOfSong = webPlayer.getNumOfSong()
            
            /* 플레이리스트의 음악 수가 변경되면 플레이리스트를 갱신한다. */
            if numOfSong != prevNumOfSong {
                prevNumOfSong = numOfSong
                
                //리스트가 바뀜을 알린다.
                listChanged(num: nowPlayingListController.getPlayList())
                
                sideListController.changed = true
            }
        }
    }
    
    //리스트가 바뀜을 앨범명을 통하여 알린다.
    func listChanged(num:Int) {
        
        if num < 0 {
            albumTextField.textColor = NSColor.orange.blended(withFraction: 0.3, of: NSColor.black)
            albumTextField.stringValue = "\(-num)개의 곡이 추가되었습니다."
        }
        else if num > 0 {
            albumTextField.textColor = NSColor.orange.blended(withFraction: 0.3, of: NSColor.black)
            albumTextField.stringValue = "\(num)개의 곡이 삭제되었습니다."
        }
        
        //1초후 다시 원래대로 되돌린다.
        if listTimer != nil {
            listTimer.invalidate()
        }
        listTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(showInfoAgain), userInfo: nil, repeats: true)
    }
    
    func showInfoAgain() {
        albumTextField.textColor = NSColor.darkGray
        albumTextField.stringValue = webPlayer.getAlbum()
        listTimer.invalidate()
    }
    
    /* WebPlayer로부터 시간정보를 받아와 반영한다. */
    func syncTimeWithWebPlayer() {
        let totalTimeString = webPlayer.getTotalTime()
        let playTimeString = webPlayer.getPlayTime()
        
        totalTime.stringValue = totalTimeString
        nowTime.stringValue = playTimeString

        /* String(00:00) -> Int 형으로 변환한다. */
        let totalTimeInt = timeStringToInt(totalTimeString)
        let playTimeInt = timeStringToInt(playTimeString)
        
        /* 진행바에 시간을 반영한다. */
        progressBar.sync(totalTime: totalTimeInt, playTime: playTimeInt)
        
        /* 시간 정보를 widget에 전송한다. */
        sendTimeInfo2Widget(total:totalTimeInt, play:playTimeInt, totalString: totalTimeString, playString:playTimeString)

    }
    
    func sendTimeInfo2Widget(total:Int, play:Int, totalString:String, playString:String) {
        var timeInfo = [AnyHashable: Any]()  //Notification을 이용해 데이터 전송을 위한 딕셔너리
        timeInfo["totalTimeInt"] = total
        timeInfo["playTimeInt"] = play
        timeInfo["totalTimeString"] = totalString
        timeInfo["playTimeString"] = playString
        
        //시간 정보를 widget에 전송한다.
        sharedUserDefaults?.set(timeInfo, forKey: "timeInfo")
    }
    
    func timeStringToInt(_ string:String)->Int {
        var time = 0
        var tmp = string
        
        tmp.removeSubrange(tmp.index(tmp.endIndex, offsetBy: -3)..<tmp.endIndex)
        if Int(tmp) == nil {
            return 1
        }
        time += Int(tmp)!*60
        
        tmp = string
        tmp.removeSubrange(tmp.startIndex ..< tmp.characters.index(tmp.startIndex, offsetBy: 3))
        time += Int(tmp)!
        
        return time
    }
    
    /* WebPlayer로부터 곡의 정보를 받아와 반영한다. */
    func syncInfoWithWebPlayer() {
        if !webPlayer.isSync {
            return
        }
        
        /* 엘범 이미지 화면에 반영 */
        /* 이미지 사이즈 변환 */
        var imageRect = CGRect(x: 0, y: 0, width: 150, height: 150)

        let albumImage = NSImage(cgImage: (NSImage(contentsOf: webPlayer.getAlbumImageURL())?.cgImage(forProposedRect: &imageRect ,context: nil, hints: nil))!, size: NSSize(width: 150, height: 150))
        
        albumImageField.image = albumImage
        
        /* Dock Icon에 엘범 이미지 반영 */
        if cover2Icon {
            NSApp.applicationIconImage = albumImage
        }
        else {
            NSApp.applicationIconImage = NSImage(named: "AppIcon")
        }
        
        let title = webPlayer.getTitle()
        let artist = webPlayer.getArtist()
        let album = webPlayer.getAlbum()
        
        /* 이름, 아티스트, 앨범명을 반영 */
        nameTextField.stringValue = title
        artistTextField.stringValue = artist
        albumTextField.stringValue = album
        
        /* 알림센터에 정보를 보낸다. */
        if alarmCenter {
            setAlarmCenter(title: nameTextField.stringValue, artist: artistTextField.stringValue, album: "- \(albumTextField.stringValue)", image: albumImage)
        }
        
        /* Progress Bar 색상 반영 */
        let (r, g, b) = getAverageRGB(albumImage)
        
        /* 위젯으로 곡의 정보를 보낸다. */
        sendSongInfo2Widget(title: title, artist: artist, album: album, r: r, g: g, b: b)
        
        /* 진행바의 색을 변경한다. */
        progressBar.changeBarColor(r, g: g, b: b)
        
        /* 앨범명의 색을 회색으로 설정 */
        albumTextField.textColor = NSColor.darkGray
        
        //가사가 없을시 갱신하지 가사가 없음을 반영한다.
        var lyrics:Lyrics? = nil
        if webPlayer.beLyrics() {
            lyrics = webPlayer.getLyrics()
        }
        else {
            let noLyric = Lyrics()
            noLyric.append("")
            lyrics = noLyric
        }
        
        /* 월페이퍼의 정보를 갱신한다. */
        wallPaperPlayer.set(title: webPlayer.getTitle(), artist: artistTextField.stringValue, album: albumTextField.stringValue, image: albumImage, lyric: lyrics!, color: NSColor(calibratedRed: r, green: g, blue: b, alpha: 1.0))
        
        /* 현재 재생중인 곡의 스트리밍 타입을 반영한다. */
        if webPlayer.getStreamingType() == 0 {
            streamingTypeButton.title = "AAC"
        }
        else {
            streamingTypeButton.title = "320kbps"
        }
        
        if menuBar {
            /* 아이콘 제어 */
            switch menuBarImageOption {
            case 0:
                showMenuBarIconImage()
            case 1:
                showMenuBarAlbumImage(image: albumImage)
            default:
                hideMenuBarImage()
            }
            /* 텍스트 제어 */
            switch menuBarOption {
            case 0:
                setMenuBarTextWithTitle()
            case 1:
                setMenuBarTextWithTitleAndArtist()
            case 2:
                setMenuBarTextWithTitleArtistAndAlbum()
            case 3:
                setMenuBarTextWithLyric()
            default:
                hideMenuBarText()
            }
        }
        else {
            hideMenuBarTextAndImage()
        }
    }
    
    func sendSongInfo2Widget(title:String, artist:String, album:String, r:CGFloat, g:CGFloat, b:CGFloat) {
        var info = [AnyHashable: Any]()  //Notification을 이용해 데이터 전송을 위한 딕셔너리
        info["title"] = title
        info["artist"] = artist
        info["album"] = album
        info["r"] = r
        info["g"] = g
        info["b"] = b
        
        sharedUserDefaults?.set(info, forKey: "songInfo")
        sharedUserDefaults?.synchronize()
    }
    
    func setAlarmCenter(title:String, artist:String, album:String, image:NSImage) {
        let notification = NSUserNotification()
        
        notification.title = title
        notification.informativeText = "\(artist) \(album)"
        notification.setValue(NSImage(data : (image.tiffRepresentation!)), forKey: "_identityImage")
        
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    func offDock() {
        if menuBarOption == -1 && menuBarImageOption == -1 {
            statusItem.image = NSImage(named: "menuBarIcon")
            statusItem.title = ""
        }
    }
    
    func getLyric() {
        statusItem.title = webPlayer.getLyricsNow()
    }
    
    func getRadioLyric() {
        if mode == .WebPlayer {
            return
        }
        statusItem.title = radio.getLyricsNow()
    }
    
    /* 받은 이미지의 평균색을 구하는 함수 */
    func getAverageRGB(_ image:NSImage)->(CGFloat, CGFloat, CGFloat) {
        /* 이미지의 raw를 구한다. */
        let rawImg = NSBitmapImageRep.init(data: (image.tiffRepresentation)!)
        
        /* 이미지의 가로 세로 크기를 구한다. */
        let x = Int(image.size.width) - 1
        let y = Int(image.size.height) - 1
        
        /* rgb변수 */
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        
        /* 각 픽셀마다의 모든 rgb값을 더한다. */
        for i in 0...x {
            for j in 0...y {
                if rawImg?.colorSpace == NSColorSpace.sRGB {
                    if rawImg?.colorAt(x: i, y: j)?.redComponent != nil { r += (rawImg?.colorAt(x: i, y: j)?.redComponent)! }
                    if rawImg?.colorAt(x: i, y: j)?.greenComponent != nil { g += (rawImg?.colorAt(x: i, y: j)?.greenComponent)! }
                    if rawImg?.colorAt(x: i, y: j)?.blueComponent != nil { b += (rawImg?.colorAt(x: i, y: j)?.blueComponent)! }
                }
            }
        }
        
        /* 평균을 낸다. */
        r = r/(CGFloat(x)*CGFloat(y))
        g = g/(CGFloat(x)*CGFloat(y))
        b = b/(CGFloat(x)*CGFloat(y))
        
        /* 색이 너무 밝을시 검정색으로 초기화한다. */
        if (r+g+b > 2.8) {
            r = 0.0
            g = 0.0
            b = 0.0
        }
        
        return (r, g, b)
    }
    
    func alertNoList() {
        albumImageField.image = nil
        nameTextField.stringValue = "재생목록에 음악이 없습니다."
        artistTextField.stringValue = "음악을 추가해주세요."
        albumTextField.stringValue = ""
    }
    
    func syncRepeat() {
        let state = webPlayer.stateOfRepeat()
            
        if state == 0 {
            repeatButton.image = NSImage(named: "repeat.png")
            repeatButton.alphaValue = CGFloat(0.3)
        }
        else if state == 1 {
            repeatButton.image = NSImage(named: "repeat.png")
            repeatButton.alphaValue = CGFloat(1.0)
        }
        else {
            repeatButton.image = NSImage(named: "repeatonce.png")
            repeatButton.alphaValue = CGFloat(1.0)
        }
    }
    
    func syncRandom() {
        let state = webPlayer.stateOfRandom()
        
        if state {
            randomButton.alphaValue = CGFloat(1.0)
        }
        else {
            randomButton.alphaValue = CGFloat(0.3)
        }
    }
    
    func syncLike() {
        let state = webPlayer.stateOfLike()
        if state {
            likeButton.alphaValue = CGFloat(1.0)
        }
        else {
            likeButton.alphaValue = CGFloat(0.3)
        }
    }
    
    //-------------------------------------------------------------------------------------------------------------------------
    //  상단 메뉴바에서 보이기/숨기기 함수 (DockAndMenuBarPreference에서 호출한다.)
    func showMenuBar() {
        statusItem.button?.isHidden = false
        statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        
        statusItem.button?.image = NSImage(named: "menuBarIcon")
        statusItem.button?.title = "    "
        statusItem.menu = toggle
        statusItem.button!.target = self
        statusItem.button!.appearsDisabled = false
    }
    
    func hideMenuBar() {
        statusItem.button?.isHidden = true
        NSStatusBar.system().removeStatusItem(statusItem)
    }
    
    //-------------------------------------------------------------------------------------------------------------------------
    //  위젯과 동기화하는 함수 모음.
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath! {
        case "progressInfo" :
            let info = sharedUserDefaults?.object(forKey: "progressInfo") as! NSDictionary
            nc.post(name: Notification.Name(rawValue: "progressBar"), object: self, userInfo: info as? [AnyHashable : Any])
        case "play" :
            play()
        case "next" :
            next()
        case "prev" :
            if mode == .WebPlayer {
                webPlayer.prev()
            }
        case "like" :
            switch mode {
            case .WebPlayer :
                let state = webPlayer.stateOfLike()
                
                webPlayer.like()
                if state {
                    likeButton.alphaValue = CGFloat(0.3)
                }
                else {
                    likeButton.alphaValue = CGFloat(1.0)
                }
            case .Radio :
                radio.like()
                likeButton.alphaValue = CGFloat(1.0)
                repeatButton.isEnabled = false
                
            }
        case "open" :
            appDelegate.reopen(self)
        case "checkPlay" :
            /* 재생여부 갱신 */
            switch mode {
            case .WebPlayer :
                if webPlayer.checkPlay() {
                    sendPlayState2Widget(set: true)
                }
                else {
                    sendPlayState2Widget(set: false)
                }
            case .Radio :
                if radio.checkPlay() {
                    sendPlayState2Widget(set: true)
                }
                else {
                    sendPlayState2Widget(set: false)
                }
            }
        case "checkLike" :
            if mode == .WebPlayer {
                sendLikeState2Widget(set: webPlayer.stateOfLike())
            }
        default : break
        }
    }
    
    func sendLikeState2Widget(set:Bool) {
        var state = false
        
        if set {
            if sharedUserDefaults?.object(forKey: "isLike") != nil {
                state = sharedUserDefaults?.object(forKey: "isLike") as! Bool
            }
            
            sharedUserDefaults?.set(!state, forKey: "isLike")
            sharedUserDefaults?.synchronize()
        }
        else {
            if sharedUserDefaults?.object(forKey: "isUnLike") != nil {
                state = sharedUserDefaults?.object(forKey: "isUnLike") as! Bool
            }
            
            sharedUserDefaults?.set(!state, forKey: "isUnLike")
            sharedUserDefaults?.synchronize()
        }
    }
    
    func sendPlayState2Widget(set:Bool) {
        var state = false
        
        if set {
            if sharedUserDefaults?.object(forKey: "isPlay") != nil {
                state = sharedUserDefaults?.object(forKey: "isPlay") as! Bool
            }
            
            sharedUserDefaults?.set(!state, forKey: "isPlay")
            sharedUserDefaults?.synchronize()
        }
        else {
            if sharedUserDefaults?.object(forKey: "isPause") != nil {
                state = sharedUserDefaults?.object(forKey: "isPause") as! Bool
            }
            
            sharedUserDefaults?.set(!state, forKey: "isPause")
            sharedUserDefaults?.synchronize()
        }
    }
}

extension PlayerController {
    //--------------------------------------------------------------------------------------------
    //  메뉴바 이미지와 관련된 함수 모음.
    func showMenuBarIconImage() {
        statusItem.image = NSImage(named: "menuBarIcon")
        statusItem.title = ""
    }
    
    func showMenuBarAlbumImage(image:NSImage) {
        var imageRect = CGRect(x: 0, y: 0, width: 18, height: 18)
        let imageRef = image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
        let menuBarImage = NSImage(cgImage: imageRef!, size: NSSize(width: 18, height: 18))
        
        statusItem.image = menuBarImage
        statusItem.title = ""
    }
    
    func hideMenuBarImage() {
        statusItem.button?.image = nil
    }
    
    //--------------------------------------------------------------------------------------------
    //  메뉴바 텍스트와 관련된 함수 모음.
    
    func setMenuBarTextWithTitle() {
        statusItem.title = nameTextField.stringValue
    }
    
    func setMenuBarTextWithTitleAndAlbum() {
        statusItem.title = "\(nameTextField.stringValue) - \(albumTextField.stringValue)"
    }
    
    func setMenuBarTextWithTitleAndArtist() {
        statusItem.title = "\(nameTextField.stringValue) - \(artistTextField.stringValue)"
    }
    
    func setMenuBarTextWithTitleArtistAndAlbum() {
        statusItem.title = "\(nameTextField.stringValue) - \(artistTextField.stringValue) - \(albumTextField.stringValue)"
    }
    
    func setMenuBarTextWithLyric() {
        if lyricTimer != nil {
            lyricTimer.invalidate()
        }
        
        switch mode {
        case .WebPlayer:
            if !webPlayer.beLyrics() || webPlayer.getLyricsNow() == "" {
                self.statusItem.title = "\(nameTextField.stringValue) - \(artistTextField.stringValue)"
            }
            else {
                lyricTimer = Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(getLyric), userInfo: nil, repeats: true)
            }
        case .Radio:
            if !radio.beLyrics() || radio.getLyricsNow() == "" {
                self.statusItem.title = "\(nameTextField.stringValue) - \(albumTextField.stringValue)"
            }
            else {
                lyricTimer = Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(getRadioLyric), userInfo: nil, repeats: true)
            }
        }
    }
    
    func hideMenuBarText() {
        if lyricTimer != nil {
            lyricTimer.invalidate()
        }
        statusItem.button?.title = ""
    }
    
    func hideMenuBarTextAndImage() {
        if lyricTimer != nil {
            lyricTimer.invalidate()
        }
        statusItem.button?.title = ""
        statusItem.button?.image = nil
    }
}

//-------------------------------------------------------------------------------------------------------------------------
//  플레이어창 안에 마우스의 존재여부에 따라 버튼을 보이고 숨기는 함수 모음
extension PlayerController:PlayerViewDelegate {
    func playerView(isIn:Bool) {
        if isIn {
            mouseIn()
            search.mouseIn()
        }
        else {
            mouseOut()
            search.mouseOut()
        }
    }
    
    /* 마우스가 플레이어 안에 들어왔을때 */
    func mouseIn() {
        /* 타이틀바의 아이콘을 보인다.. */
        showTitleButton()
        
        if mouseOutTimer != nil { mouseOutTimer.invalidate() }
        
        /* 로그인 여부를 체크 */
        if !nowLogin {
            if webPlayer.checkLogin() {
                loginComplete()
            }
            else {
                logoutComplete()
            }
        }
        
        /* 재생여부 갱신 */
        applyPlayState()
        
        if mode == .WebPlayer {
            syncRepeat()
        }
        syncRandom()
        
        switch mode {
        case .WebPlayer :
            volumeBar.intValue = Int32(webPlayer.getVolume())
        case .Radio :
            volumeBar.intValue = Int32(radio.getVolume())
        }
        
        if fadeValue == 0 {
            showButton()
        }
        else {
            mouseInTimer = Timer.scheduledTimer(timeInterval: fadeTiming, target: self, selector: #selector(blurObject), userInfo: nil, repeats: true)
        }
        isMouseInPlayer = true
    }
    
    /* 마우스가 플레이어 밖으로 나갔을때 */
    /* PlayerView로부터 Notification을 받아 실행된다. */
    func mouseOut() {
        /* 타이틀바의 아이콘을 숨긴다. */
        hideTitleButton()
        
        if mouseInTimer != nil { mouseInTimer.invalidate() }
        
        if fadeValue == 0 {
            hideButton()    //바로 버튼을 사라지게 한다.
        }
        else {
            mouseOutTimer = Timer.scheduledTimer(timeInterval: fadeTiming, target: self, selector: #selector(sharpObject), userInfo: nil, repeats: true)
        }
        isMouseInPlayer = false
    }
    
    func applyPlayState() {
        switch mode {
        case .WebPlayer :
            if webPlayer.checkPlay() {
                playButton.image = NSImage(named: "pause.png")
            }
            else {
                playButton.image = NSImage(named: "play.png")
            }
        case .Radio :
            if radio.checkPlay() {
                playButton.image = NSImage(named: "pause.png")
            }
            else {
                playButton.image = NSImage(named: "play.png")
            }
        }
    }
    
    func showButton() {
        nameTextField.textColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: CGFloat(0.1))
        albumTextField.textColor = NSColor(calibratedRed: 0.5, green: 0.5, blue: 0.5, alpha: CGFloat(0.1))
        artistTextField.textColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: CGFloat(0.1))
        albumImageField.alphaValue = CGFloat(0.1)
        
        prevButton.alphaValue = CGFloat(1)
        playButton.alphaValue = CGFloat(1)
        nextButton.alphaValue = CGFloat(1)
        volumeBar.alphaValue = CGFloat(1)
        loginButton.alphaValue = CGFloat(1)
        similarButton.alphaValue = CGFloat(1)
        search.alphaValue(value: 1)
    }
    
    func hideButton() {
        nameTextField.textColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: CGFloat(1))
        albumTextField.textColor = NSColor(calibratedRed: 0.5, green: 0.5, blue: 0.5, alpha: CGFloat(1))
        artistTextField.textColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: CGFloat(1))
        albumImageField.alphaValue = CGFloat(1)
        
        prevButton.alphaValue = CGFloat(0)
        playButton.alphaValue = CGFloat(0)
        nextButton.alphaValue = CGFloat(0)
        volumeBar.alphaValue = CGFloat(0)
        loginButton.alphaValue = CGFloat(0)
        similarButton.alphaValue = CGFloat(0)
        search.alphaValue(value: 0)
    }
    
    func blurObject() {
        if trans <= 0.11 {
            return
        }
        else if isMouseInPlayer {
            trans -= fadeValue
            if buttonTrans <= 0.9 {
                buttonTrans += fadeValue
            }
        }
        nameTextField.textColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: CGFloat(trans))
        albumTextField.textColor = NSColor(calibratedRed: 0.5, green: 0.5, blue: 0.5, alpha: CGFloat(trans))
        artistTextField.textColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: CGFloat(trans))
        albumImageField.alphaValue = CGFloat(trans)
        
        prevButton.alphaValue = CGFloat(buttonTrans)
        playButton.alphaValue = CGFloat(buttonTrans)
        nextButton.alphaValue = CGFloat(buttonTrans)
        volumeBar.alphaValue = CGFloat(buttonTrans)
        loginButton.alphaValue = CGFloat(buttonTrans)
        similarButton.alphaValue = CGFloat(buttonTrans)
        search.alphaValue(value: CGFloat(buttonTrans))
    }
    
    func sharpObject() {
        if trans >= 1 {
            return
        }
        else if !isMouseInPlayer {
            trans += fadeValue
            if buttonTrans >= 0 {
                buttonTrans -= fadeValue
            }
        }
        nameTextField.textColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: CGFloat(trans))
        albumTextField.textColor = NSColor(calibratedRed: 0.5, green: 0.5, blue: 0.5, alpha: CGFloat(trans))
        artistTextField.textColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: CGFloat(trans))
        albumImageField.alphaValue = CGFloat(trans)
        
        prevButton.alphaValue = CGFloat(buttonTrans)
        playButton.alphaValue = CGFloat(buttonTrans)
        nextButton.alphaValue = CGFloat(buttonTrans)
        volumeBar.alphaValue = CGFloat(buttonTrans)
        loginButton.alphaValue = CGFloat(buttonTrans)
        similarButton.alphaValue = CGFloat(buttonTrans)
        search.alphaValue(value: CGFloat(buttonTrans))
    }
    
    func enterFullScreen() {
        fullScreenMode = true
        mouseOut()
    }
    
    func exitFullScreen() {
        fullScreenMode = false
    }
}


extension PlayerController:ProgressBarDelegate {
    func progressBar(percent: CGFloat) {
        webPlayer.jump(to:percent)
    }
}
