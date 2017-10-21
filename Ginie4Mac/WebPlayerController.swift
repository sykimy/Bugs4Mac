//
//  WebPlayerController.swift
//  Music
//
//  Created by sykimy on 2016. 8. 2..
//  Copyright © 2016년 sykimy. All rights reserved.
//

import Cocoa
import WebKit

class WebPlayerController: NSViewController {
    
    /* 웹플레이어를 구동할 WebView */
    var webView:WKWebView!
    
    /* 플레이어컨트롤러(UI 제어) */
    @IBOutlet var playerController: PlayerController!
    
    var processPool = WKProcessPool()
    
    //웹플레이어가 동기화를 시작했나 저장하는 변수.
    var isSync = false
    
    var timer:Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        /* WKWebView 설정값 생성 */
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        preferences.plugInsEnabled = true
        
        /* Create a configuration for our preferences */
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.processPool = processPool
        
        /* WKWebView 생성 */
        webView = WKWebView(frame: view.bounds, configuration: configuration)
        webView.navigationDelegate = self
        
        /* 뷰와 연동 */
        self.view.addSubview(webView)
        
        /* 웹플레이어 페이지 로드 */
        webView.load(URLRequest(url: URL(string: "http://www.genie.co.kr/player/fPlayer")!))
        
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(loadPlayer), userInfo: nil, repeats: true)
    }
    
    func loadPlayer() {
        if isSync {
            timer.invalidate()
            return
        }

        webView.load(URLRequest(url: URL(string: "http://music.bugs.co.kr/newPlayer?autoplay=false")!))
    }
    
    /* WKWebView에 스크립트를 입력하고, string값을 리턴한다. */
    func injectScript(_ script:String)->Any? {
        /* 값을 받아올때까지 false를 유지하는 변수 */
        var isFinish = false
        
        /* 반환할 값을 저장할 변수 */
        var value:Any?
        
        /* 웹뷰에 script를 입력한다. */
        webView.evaluateJavaScript(script) { (result, error) in
            if error == nil {
                /* 값을 받아온다. */
                value = result as AnyObject?
            }
            /* 값을 받아옴을 반영 */
            isFinish = true
        }
        
        /* 값을 받아올때까지 대기한다. */
        while (!isFinish) {
            /* while문을 도는 동안 다른 일을 진행하도록 한다. */
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        return value as AnyObject
    }
    
    /*
     * 플레이 리스트를 불러오는 함수
     * 불러올 곡정보의 번호 i를 입력받고
     * 곡정보(Song)을 반환한다
     */
    func getPlayListSong(_ i:Int)->Song {
        var str = injectScript("document.getElementsByClassName('playTrackList')[1].getElementsByTagName('li')[\(i)].getElementsByClassName('tracktitle')[0].innerHTML") as! String
        let name = str.replacingOccurrences(of: "&amp;", with: "&").replacingOccurrences(of: "&nbsp;", with: " ")
        
        str = injectScript("document.getElementsByClassName('playTrackList')[1].getElementsByTagName('li')[\(i)].getElementsByClassName('artistname')[0].getAttribute('title')") as! String
        let artist = str.replacingOccurrences(of: "&nbsp;", with: " ").replacingOccurrences(of: "&amp;", with: "&").replacingOccurrences(of: "&lt;", with: "<").replacingOccurrences(of: "&gt;", with: ">")
        
        return Song(num: i+1, name: name, artist: artist, now: isNowPlaying(i))
    }
    
    /*
     * 현재 웹플레이어에서 음악이 재생중인지 확인하는 함수
     * Bool값을 반환한다.
     */
    func isNowPlaying(_ i:Int)->Bool {
        var isFinish = false
        var state = false
        webView.evaluateJavaScript("document.getElementsByClassName('playTrackList')[1].getElementsByTagName('li')[\(i)].getAttribute('class')") { (result, error) in
            if error == nil {
                if String(describing: result).range(of: "nowPlaying") != nil {
                    state = true
                }
            }
            isFinish = true
        }
        
        while (!isFinish) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        return state
    }
}

/* WKWebView Delegate 함수 모음 */
extension WebPlayerController: WKNavigationDelegate {
    /* 페이지 로드가 끝나면 자동으로 호출되는 함수 */
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        /* 페이지의 로그가 끝나면 simulate()라는 javascript함수를 입력한다. */
        injectSimulateFunc()
        
        /* 플레이어가 네이버웹플레이어와의 동기화 시작. */
        playerController.startSyncWithWebPlayer()
        isSync = true
    }
}

/* 플레이어로부터 곡의 정보를 받아와 반환하는 함수 모음 */
extension WebPlayerController {
    /* 곡의 총 시간을 String타입으로 반환한다.(00:00) */
    func getTotalTime()->String {
        let string = injectScript("document.getElementsByClassName('time')[0].getElementsByClassName('finish')[0].innerHTML") as? String
        if string == nil {
            return "--:--"
        }
        return string!
    }
    
    /* 곡의 진행 시간을 String타입으로 반환한다.(00:00) */
    func getPlayTime()->String {
        let string = injectScript("document.getElementsByClassName('time')[0].getElementsByClassName('start')[0].innerHTML") as? String
        if string == nil {
            return "--:--"
        }
        return string!
    }
    
    /* 곡 고유의 아이디를 Int타입으로 반환한다. */
    func getSongID()->Int {
        var isFinish = false
        var id = 0
        webView.evaluateJavaScript("bugs.player.getCurrentTrackInfo().track_id") { (result, error) in
            if error == nil {
                if !(result is NSNull) {
                    id = result as! Int
                }
            }
            isFinish = true
        }
        
        while (!isFinish) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        return id
    }
    
    /* 앨범명을 String으로 반환한다. */
    func getAlbum()->String {
        let value = injectScript("document.getElementsByClassName('trackInfo')[0].getElementsByClassName('albumtitle')[0].innerHTML")
        
        if value is String {
            let str = value as! String
            
            return str.replacingOccurrences(of: "&nbsp;", with: " ").replacingOccurrences(of: "&amp;", with: "&").replacingOccurrences(of: "&lt;", with: "<").replacingOccurrences(of: "&gt;", with: ">")
        }
        else {
            return "앨범명을 불러올 수 없습니다."
        }
    }
    
    /* 곡명을 String으로 반환한다. */
    func getTitle()->String {
        let value = injectScript("document.getElementsByClassName('trackInfo')[0].getElementsByClassName('tracktitle')[0].innerHTML")
        
        if value is String {
            var str = value as! String

            //끝이 " " 이면 이를 제거.
            if str[str.index(str.endIndex, offsetBy: -1)] == " " {
                str = str.substring(to: str.index(str.endIndex, offsetBy: -1))
            }
            
            return str.replacingOccurrences(of: "&nbsp;", with: " ").replacingOccurrences(of: "&amp;", with: "&").replacingOccurrences(of: "&lt;", with: "<").replacingOccurrences(of: "&gt;", with: ">")
        }
        else {
            return "타이틀을 불러올 수 없습니다."
        }
    }
    
    /* 아티스트를 String으로 반환한다. */
    func getArtist()->String {
        let value = injectScript("document.getElementsByClassName('trackInfo')[0].getElementsByClassName('artistname')[0].innerHTML")
        
        if value is String {
            let str = value as! String
            
            return str.replacingOccurrences(of: "&nbsp;", with: " ").replacingOccurrences(of: "&amp;", with: "&").replacingOccurrences(of: "&lt;", with: "<").replacingOccurrences(of: "&gt;", with: ">")
        }
        else {
            return "아티스트를 불러올 수 없습니다."
        }
    }
    
    /* 엘범이미지의 URL을 NSURL로 반환한다. */
    func getAlbumImageURL()->URL {
        let value = injectScript("document.getElementsByClassName('thumbnail')[0].getElementsByTagName('img')[0].src")

        if value is NSNull {
            return URL(fileURLWithPath: "")
        }
        return URL(string:(value as! String).replacingOccurrences(of: "/100/", with: "/368/"))!
    }
    
    /* 곡의 좋아요 정보를 Bool로 반환한다. */
    func stateOfLike()->Bool {
        var isFinish = false
        var state = false
        webView.evaluateJavaScript("document.getElementsByClassName('btnLikeTrackCancel')[0].getAttribute('style')") { (result, error) in
            if error == nil {
                if String(describing: result).range(of: "none") == nil {
                    state = true
                }
            }
            isFinish = true
        }
        
        while (!isFinish) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        return state
    }
    
    /* 가사 유무를 Bool로 반환한다. */
    func beLyrics()->Bool {
        webView.evaluateJavaScript("bugs.player.tabClickHandler(this,'playlist');", completionHandler: nil)
        webView.evaluateJavaScript("bugs.player.tabClickHandler(this,'lyrics');", completionHandler: nil)
        
        var isFinish = false
        var state = false
        
        webView.evaluateJavaScript("document.getElementsByClassName('lyricsNone')[0].getAttribute('style')") { (result, error) in
            if error == nil {
                if String(describing: result).range(of: "none") != nil {
                    state = true
                }
            }
            isFinish = true
        }
        
        while (!isFinish) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        return state
    }
    
    /* 곡의 가사를 String으로 반환한다. */
    func getLyrics()->Lyrics {
        var str:String = ""
        var isFinish = false
        let lyrics = Lyrics()
        
        webView.evaluateJavaScript("document.getElementById('lyricsContent').innerHTML") { (result, error) in
            if error == nil {
                str = result as! String
            }
            isFinish = true
        }
        
        while (!isFinish) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        var front = str.startIndex
        
        let lyric = str.replacingOccurrences(of: "&nbsp;", with: " ").replacingOccurrences(of: "&amp;", with: "&").replacingOccurrences(of: "&lt;", with: "<").replacingOccurrences(of: "&gt;", with: ">")
        
        for i in lyric.characters.indices {
            if lyric[i] == "<" {
                if lyric[lyric.index(i, offsetBy: 1)] == "b" {
                    lyrics.append(lyric.substring(with: (front..<lyric.index(i, offsetBy: 0)))+"\n")
                    front = lyric.index(i, offsetBy: 4)
                }
            }
        }

        return lyrics
    }
    
    /* 현재 재생중인 가사의 줄수를 반환한다. */
    func getNumOfNowPlayingLyric()->Int {
        var str:String = ""
        var isFinish = false
        
        webView.evaluateJavaScript("document.getElementById('lyricsContent').innerHTML") { (result, error) in
            if error == nil {
                str = result as! String
            }
            isFinish = true
        }
        
        while (!isFinish) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        var count = 0
        for i in str.characters.indices {
            if str[i] == "<" {
                if str[str.index(i, offsetBy: 1)] == "s" {
                    break
                }
                count += 1
            }
        }
        
        return count
    }
    
    /* 현재 재생중인 가사를 String으로 반환한다.*/
    func getLyricsNow()->String {
        var str:NSString = ""
        var isFinish = false
        
        webView.evaluateJavaScript("document.getElementById('lyricsContent').getElementsByTagName('strong')[0].innerHTML") { (result, error) in
            if error == nil {
                str = result as! NSString
            }
            isFinish = true
        }
        
        while (!isFinish) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        let lyric = str.replacingOccurrences(of: "&nbsp;", with: " ").replacingOccurrences(of: "&amp;", with: "&").replacingOccurrences(of: "&lt;", with: "<").replacingOccurrences(of: "&gt;", with: ">")
        
        return lyric
    }
    
    /* 지금 재생 목록에 있는 곡의 수를 Int로 반환한다.*/
    func getNumOfSong()->Int {
        var isFinish = false
        var num = 0
        
        if checkPlayList() {
            webView.evaluateJavaScript("document.getElementsByClassName('playTrackList')[1].getElementsByTagName('li').length") { (result, error) in
                if error == nil {
                    if !(result is NSNull) {
                        num = result as! Int
                    }
                }
                isFinish = true
            }
            
            while (!isFinish) {
                RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
            }
        }
        
        return num
    }
    
    /* 반복듣기, 한곡재생등의 상태를 Int로 반환한다. 0:일반 1:반복듣기 2:한곡재생 */
    func stateOfRepeat()->Int {
        var isFinish = false
        var state = 0
        webView.evaluateJavaScript("document.getElementsByClassName('repeat')[0].getElementsByTagName('span')[0].getAttribute('title')") { (result, error) in
            if error == nil {
                if String(describing: result).range(of: "반복안함") != nil {
                    state = 0
                }
                else if String(describing: result).range(of: "전체반복") != nil {
                    state = 1
                }
                else {
                    state = 2
                }
            }
            isFinish = true
        }
        
        while (!isFinish) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        return state
    }
    
    /* 랜덤재생 여부를 Bool로반환한다. */
    func stateOfRandom()->Bool {
        var isFinish = false
        var state = false
        webView.evaluateJavaScript("document.getElementsByClassName('shuffle')[0].getElementsByTagName('span')[0].getAttribute('title')") { (result, error) in
            if error == nil {
                if String(describing: result).range(of: "셔플듣기중") != nil {
                    state = true
                }
            }
            isFinish = true
        }
        
        while (!isFinish) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        return state
    }
    
    /* 벅스웹플레이어의 볼륨값을 받아와 0~40사이의 Int로 반환한다. */
    func getVolume()->Int {
        var isFinish = false
        var volume = 0
        
        webView.evaluateJavaScript("document.getElementsByClassName('volume on')[0].getElementsByClassName('bar')[0].getAttribute('style')") { (result, error) in
            if error == nil {
                var str = result as! String
                if str != "width:0;" {
                    str.removeSubrange(str.startIndex ..< str.characters.index(str.startIndex, offsetBy: 7))
                    str.removeSubrange(str.characters.index(str.endIndex, offsetBy: -3) ..< str.endIndex)
                    volume = Int(Double(str)!)
                }
            }
            isFinish = true
        }
        
        while (!isFinish) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        return volume
    }
    
    /* 곡의 재생여부를 Bool로 반환한다. */
    func checkPlay()->Bool {
        var isFinish = false
        var isPlay = false
        webView.evaluateJavaScript("document.getElementsByClassName('btnCtl')[0].getElementsByTagName('span')[1].getElementsByTagName('button')[0].innerHTML") { (result, error) in
            if error == nil {
                if String(describing: result).range(of: "재생") == nil {
                    isPlay = true
                }
            }
            isFinish = true
        }
        
        while (!isFinish) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        return isPlay
    }
    
    /* 재생중인 음질을 받아온다. */
    /* AAC : 0, 320kbps : 1 */
    func getStreamingType()->Int {
        var isFinish = false
        var isPlay = -1
        webView.evaluateJavaScript("document.getElementsByClassName('progress')[0].getElementsByTagName('button')[0].innerHTML") { (result, error) in
            if error == nil {
                if String(describing: result).range(of: "AAC") != nil {
                    isPlay = 0
                }
                else {
                    isPlay = 1
                }
            }
            isFinish = true
        }
        
        while (!isFinish) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        return isPlay
    }
    
    func changeStreamingType() {
        if getStreamingType() == 0 {
            webView.evaluateJavaScript("document.getElementById('mp3Quality320').click()", completionHandler: nil)
        }
        else {
            webView.evaluateJavaScript("document.getElementById('aacQuality128').click()", completionHandler: nil)
        }
        webView.evaluateJavaScript("document.getElementById('holdBackTrackPlayOption').getElementsByClassName('btnNormal')[0].click()", completionHandler: nil)
    }
    
    /* 지금 재생중인 노래의 리스트상 순서를 반환한다. */
    func getNumOfSelectedSong()->Int {
        var isFinish = false
        var num = 0
        
        webView.evaluateJavaScript("document.getElementsByClassName('playTrackList')[2].getElementsByTagName('li').length") { (result, error) in
            if error == nil {
                if !(result is NSNull) {
                    num = result as! Int
                }
            }
            isFinish = true
        }
        
        while (!isFinish) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        return num
    }
}


/* 플레이어 초기화 함수 모음 */
extension WebPlayerController {
    /* 로그인 여부를 Bool로 반환한다. */
    func checkLogin()->Bool {
        var isFinish = false
        var isLogin = true
        webView.evaluateJavaScript("document.getElementsByClassName('btnLogin')[0].getElementsByTagName('button')[0].innerHTML") { (result, error) in
            if error == nil {
                if String(describing: result).range(of: "로그인") != nil {
                    isLogin = false
                }
            }
            isFinish = true
        }
        
        while (!isFinish) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        return isLogin
    }
    
    /* simulate함수를 inject한다. */
    func injectSimulateFunc() {
        webView.evaluateJavaScript("function simulate(element, eventName) { var options = extend(defaultOptions, arguments[2] || {}); var oEvent, eventType = null; for (var name in eventMatchers) { if (eventMatchers[name].test(eventName)) { eventType = name; break; } } if (!eventType) throw new SyntaxError('Only HTMLEvents and MouseEvents interfaces are supported'); if (document.createEvent) { oEvent = document.createEvent(eventType); if (eventType == 'HTMLEvents') { oEvent.initEvent(eventName, options.bubbles, options.cancelable); } else { oEvent.initMouseEvent(eventName, options.bubbles, options.cancelable, document.defaultView, options.button, options.pointerX, options.pointerY, options.pointerX, options.pointerY, options.ctrlKey, options.altKey, options.shiftKey, options.metaKey, options.button, element); } element.dispatchEvent(oEvent); } else { options.clientX = options.pointerX; options.clientY = options.pointerY; var evt = document.createEventObject(); oEvent = extend(evt, options); element.fireEvent('on' + eventName, oEvent); } return element; } function extend(destination, source) { for (var property in source) destination[property] = source[property]; return destination; } ", completionHandler: nil)
        webView.evaluateJavaScript("var eventMatchers = { 'HTMLEvents': /^(?:load|unload|abort|error|select|change|submit|reset|focus|blur|resize|scroll)$/, 'MouseEvents': /^(?:click|dblclick|mouse(?:down|up|over|move|out))$/ }", completionHandler: nil)
        webView.evaluateJavaScript("var defaultOptions = { pointerX: 0, pointerY: 0, button: 0, ctrlKey: false, altKey: false, shiftKey: false, metaKey: false, bubbles: true, cancelable: true }", completionHandler: nil)
    }
    
    /* 플레이리스트의 존재 여부를 확인하는 함수 */
    func checkPlayList()->Bool {
        var isFinish = false
        var isLogin = true
        webView.evaluateJavaScript("document.getElementsByClassName('playTrackList')[0].getAttribute('style')") { (result, error) in
            if error == nil {
                if String(describing: result).range(of: "none") == nil {
                    isLogin = false
                }
            }
            isFinish = true
        }
        
        while (!isFinish) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        return isLogin
    }
    
    
}

/* 플레이어 제어 함수 모음 */
extension WebPlayerController {
    /* 재생 for Bugs */
    func play() {
        /* 초기 재생할때의 script와 그 후의 script가 달라 두개다 호출한다. */
        webView.evaluateJavaScript("document.getElementsByClassName('btnPlay')[0].getElementsByTagName('button')[0].click()", completionHandler: nil)
    }
    
    /* 일시정지 for Bugs */
    func pause() {
        webView.evaluateJavaScript("document.getElementsByClassName('btnStop')[0].getElementsByTagName('button')[0].click()", completionHandler: nil)
    }
    
    /* 이전곡 for Bugs */
    func prev() {
        webView.evaluateJavaScript("document.getElementsByClassName('btnPrev')[0].getElementsByTagName('button')[0].click()", completionHandler: nil)
    }
    
    /* 다음곡 for Bugs */
    func next() {
        webView.evaluateJavaScript("document.getElementsByClassName('btnNext')[0].getElementsByTagName('button')[0].click()", completionHandler: nil)
    }
    
    /* 순차재생, 반복재생, 한곡재생 for Bugs */
    func repeatList() {
        webView.evaluateJavaScript("document.getElementsByClassName('repeat')[0].getElementsByTagName('Button')[0].click()", completionHandler: nil)
    }
    
    /* 랜덤재생 for Bugs */
    func random() {
        webView.evaluateJavaScript("document.getElementsByClassName('shuffle')[0].getElementsByTagName('Button')[0].click()", completionHandler: nil)
    }
    
    /* 좋아요 for Bugs */
    func like() {
        if stateOfLike() { webView.evaluateJavaScript("document.getElementsByClassName('btnLikeTrackCancel')[0].click()", completionHandler: nil) }
        else { webView.evaluateJavaScript("document.getElementsByClassName('btnLikeTrack')[0].click()", completionHandler: nil) }
    }
    
    /* 선택된 곡 재생 for Bugs */
    func playSelectedSong(i:Int) {
        webView.evaluateJavaScript("document.getElementsByClassName('playTrackList')[1].getElementsByTagName('li')[\(i)].getElementsByClassName('tracktitle')[0].click()", completionHandler: nil)
    }
    
    /* 유사한 음악 추가 for Bugs */
    func addSimilarSong() {
        webView.evaluateJavaScript("document.getElementsByClassName('btnRecommendTrack')[0].getElementsByTagName('button')[0].click()", completionHandler: nil)
    }
    
    /* 지금 재생 목록 초기화 for Bugs */
    func deletePlayList() {
        selectAllSong() //모든노래선택
        deleteSelectSong()  //선택된 곡 삭제
    }

    /* Top100을 플레이어로 가져온다. for Bugs */
    func getTop100() {
        webView.evaluateJavaScript("document.getElementsByClassName('tabPlayer')[0].getElementsByClassName('top50')[0].getElementsByTagName('a')[0].click()", completionHandler: nil)
        
        while ( getNumOfSelectedSong() == 0 ) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        webView.evaluateJavaScript("document.getElementsByClassName('listWrap top50List')[0].getElementsByClassName('checkbox')[0].click()", completionHandler: nil)
        webView.evaluateJavaScript("document.getElementsByClassName('listWrap top50List')[0].getElementsByClassName('btns')[0].getElementsByTagName('button')[0].click()", completionHandler: nil)
        webView.evaluateJavaScript("bugs.player.tabClickHandler(this,'playlist');", completionHandler: nil)
    }
    
    /* 현재의 모든 곡을 지우고 Top100을 불러온다. for Bugs */
    func deleteNGetTop100() {
        deletePlayList()
        getTop100()
    }
    
    /* 선택된 곡을 지운다. for Bugs */
    func deleteSelectSong() {
        webView.evaluateJavaScript("document.getElementsByClassName('listBtns')[0].getElementsByClassName('btnDel')[0].getElementsByTagName('button')[0].click()", completionHandler: nil)
    }
    
    /* 곡의 번호를 받아와 해당 곡을 선택한다. for Bugs */
    func selectSong(_ i:Int) {
        webView.evaluateJavaScript("document.getElementsByClassName('playTrackList')[1].getElementsByTagName('li')[\(i)].getElementsByClassName('checkbox')[0].click()", completionHandler: nil)
    }
    
    /* 모든 곡을 선택한다. for Bugs */
    func selectAllSong() {
        webView.evaluateJavaScript("document.getElementsByClassName('listBtns')[0].getElementsByClassName('checkbox')[0].click()", completionHandler: nil)
    }
    
    /* 진행바를 컨트롤하는 함수 for Bugs */
    func jump(to percent:CGFloat) {
        let progress = Int(percent*348)+28
        
        webView.evaluateJavaScript("simulate(document.getElementsByClassName('progress')[0].getElementsByClassName('bar')[0], 'click', {pointerX: \(progress), pointerY: 175 })", completionHandler: nil)
    }

    
    /* 볼륨바를 컨트롤하는 함수 for Bugs */
    func volume(_ volume:Int) {
        webView.evaluateJavaScript("simulate(document.getElementsByClassName('volume on')[0].getElementsByClassName('bar')[0], 'click', {pointerX: \(volume), pointerY: 138 })", completionHandler: nil)
    }
    
    /* 로그아웃한다. for Bugs */
    func logout() {
        webView.evaluateJavaScript("document.getElementsByClassName('btnLogout')[0].getElementsByTagName('button')[0].click()", completionHandler: nil)
    }
    
    /* 선택된 곡을 한칸 위로 이동시킨다. for Bugs */
    func moveUp() {
        webView.evaluateJavaScript("document.getElementsByClassName('btnMoveUp')[0].getElementsByTagName('button')[0].click()", completionHandler: nil)
    }
    
    /* 선택된 곡을 한칸 아래로 이동시킨다. for Bugs */
    func moveDown() {
        webView.evaluateJavaScript("document.getElementsByClassName('btnMoveDown')[0].getElementsByTagName('button')[0].click()", completionHandler: nil)
        
    }
}

/* 쓰이지 않는 함수 모음 */
extension WebPlayerController {
    /* 가사의 줄 수를 Int로반환 (지금은 쓰이지 않는다.) */
    func numOfLyricSentences()->Int {
        var num = 0
        var isFinish = false
        
        webView.evaluateJavaScript("document.getElementsByClassName('lyric_w _lyric_list')[0].getElementsByTagName('p')[0].getElementsByTagName('br').length") { (result, error) in
            if error == nil {
                if result is Int {
                    num = result as! Int
                }
            }
            isFinish = true
        }
        
        while (!isFinish) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        return num
    }
}
