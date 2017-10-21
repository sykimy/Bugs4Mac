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
    @IBOutlet var mainWebViewController: MainWebViewController!
    
    var processPool = WKProcessPool()
    
    //웹플레이어가 동기화를 시작했나 저장하는 변수.
    var isSync = false
    
    var timer:Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        //playerController.startSyncWithWebPlayer()
        //timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(loadPlayer), userInfo: nil, repeats: true)
    }
    
    func initWebPlayer(configuration: WKWebViewConfiguration)->WKWebView {
        webView = WKWebView(frame: self.view.frame, configuration: configuration)
        webView.uiDelegate = mainWebViewController
        webView.navigationDelegate = mainWebViewController
        self.view.addSubview(webView)
        
        return webView
    }
    
    /* WKWebView에 스크립트를 입력하고, string값을 리턴한다. */
    func injectScript(_ script:String)->Any? {
        /* 값을 받아올때까지 false를 유지하는 변수 */
        var isFinish = false
        
        /* 반환할 값을 저장할 변수 */
        var value:Any?
        
        if webView == nil {
            return value
        }
        
        /* 웹뷰에 script를 입력한다. */
        webView.evaluateJavaScript(script) { (result, error) in
            if error == nil {
                /* 값을 받아온다. */
                if !(result is NSNull) {
                    value = result as AnyObject?
                }
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
     * 곡정보(Song)을 반환한다 for Genie2
     */
    func getPlayListSong(_ i:Int)->Song {
        /* 타이틀 */
        let title = injectScript("document.getElementsByClassName('ui-sortable')[0].getElementsByClassName('list')[\(2*i)].getElementsByClassName('title')[0].innerHTML") as! String
        
        //let title = str.replacingOccurrences(of: "&nbsp;", with: " ").replacingOccurrences(of: "&amp;", with: "&").replacingOccurrences(of: "&lt;", with: "<").replacingOccurrences(of: "&gt;", with: ">")
        
        /* 아티스트 */
        let artist = injectScript("document.getElementsByClassName('ui-sortable')[0].getElementsByClassName('list')[\(2*i)].getElementsByClassName('artist')[0].innerHTML") as! String
        
        //let artist = str.replacingOccurrences(of: "&nbsp;", with: " ").replacingOccurrences(of: "&amp;", with: "&").replacingOccurrences(of: "&lt;", with: "<").replacingOccurrences(of: "&gt;", with: ">")
        
        return Song(num: i+1, name: title, artist: artist, now: isNowPlaying(i))
    }
    
    /*
     * 현재 웹플레이어에서 음악이 재생중인지 확인하는 함수
     * Bool값을 반환한다. for Genie2
     */
    func isNowPlaying(_ i:Int)->Bool {
        var isFinish = false
        var state = false
        webView.evaluateJavaScript("document.getElementsByClassName('ui-sortable')[0].getElementsByClassName('list')[\(2*i)].getAttribute('class')") { (result, error) in
            if error == nil {
                if String(describing: result).range(of: "list this-play") != nil {
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

/* 플레이어로부터 곡의 정보를 받아와 반환하는 함수 모음 */
extension WebPlayerController {
    /* 곡의 총 시간을 String타입으로 반환한다.(00:00) for Genie2 */
    func getTotalTime()->String {
        let string = injectScript("document.getElementsByClassName('fp-duration')[0].innerHTML") as? String
        if string == nil {
            return "--:--"
        }
        else if string == "" {
            return "--:--"
        }
        return string!
    }
    
    /* 곡의 진행 시간을 String타입으로 반환한다.(00:00) for Genie2 */
    func getPlayTime()->String {
        let string = injectScript("document.getElementsByClassName('fp-elapsed')[0].innerHTML") as? String
        if string == nil {
            return "--:--"
        }
        return string!
    }
    
    /* 곡 고유의 아이디를 Int타입으로 반환한다. for Genie2 */
    func getSongID()->Int {
        var isFinish = false
        var id = 0
        webView.evaluateJavaScript("document.getElementsByClassName('list this-play')[0].getAttribute('music-id')") { (result, error) in
            if error == nil {
                if !(result is NSNull) {
                    id = Int(result as! String)!;
                }
            }

            isFinish = true
        }
        
        while (!isFinish) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        return id
    }
    
    /* 앨범명을 String으로 반환한다. for Genie2 */
    func getAlbum()->String {
        let value = injectScript("document.getElementsByClassName('cover_bg')[0].getElementsByTagName('img')[0].alt")
        
        if value is String {
            let str = value as! String
            
            return str;
            return str.replacingOccurrences(of: "&nbsp;", with: " ").replacingOccurrences(of: "&amp;", with: "&").replacingOccurrences(of: "&lt;", with: "<").replacingOccurrences(of: "&gt;", with: ">")
        }
        else {
            return "앨범명을 불러올 수 없습니다."
        }
    }
    
    /* 곡명을 String으로 반환한다. for Genie 2 */
    func getTitle()->String {
        let value = injectScript("document.getElementById('SongTitleArea').innerHTML")
        
        if value is String {
            var str = value as! String

            return str;
            //끝이 " " 이면 이를 제거.
            if str[str.index(str.endIndex, offsetBy: -1)] == " " {
                str = str.substring(to: str.index(str.endIndex, offsetBy: -1))
            }
            
            return str.replacingOccurrences(of: "&nbsp;", with: " ").replacingOccurrences(of: "&amp;", with: "&").replacingOccurrences(of: "&lt;", with: "<").replacingOccurrences(of: "&gt;", with: ">")
        }
        else {
            return "재생할 곡을 선택 해주세요."
        }
    }
    
    /* 아티스트를 String으로 반환한다. for Genie2 */
    func getArtist()->String {
        let value = injectScript("document.getElementById('ArtistNameArea').innerHTML")
        
        if value is String {
            let str = value as! String
            
            return str;
            
            return str.replacingOccurrences(of: "&nbsp;", with: " ").replacingOccurrences(of: "&amp;", with: "&").replacingOccurrences(of: "&lt;", with: "<").replacingOccurrences(of: "&gt;", with: ">")
        }
        else {
            return "아티스트를 불러올 수 없습니다."
        }
    }
    
    /* 엘범이미지의 URL을 반환한다. for Genie2 */
    func getAlbumImageURL()->URL {
        let value = injectScript("document.getElementById('AlbumImgArea').getElementsByTagName('img')[0].src")

        if value is String {
            return URL(string: value as! String)!
        }
        
        return URL(string: "http://image.genie.co.kr/imageg/web/common/blank_artist_200.gif")!
    }
    
    /* 곡의 좋아요 정보를 Bool로 반환한다. for Genie2 */
    func stateOfLike()->Bool {
        var isFinish = false
        var state = false
        if webView == nil {
            return false
        }
        webView.evaluateJavaScript("document.getElementsByClassName('btn-like')[0].getAttribute('class')") { (result, error) in
            if error == nil {
                if String(describing: result).range(of: "active") != nil {
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
    
    /* 가사 유무를 Bool로 반환한다. for Genie2 */
    func beLyrics()->Bool {
        var isFinish = false
        var state = false
        
        webView.evaluateJavaScript("document.getElementsByClassName('lyrics-inner')[0].children.length") { (result, error) in
            if error == nil {
                if result as! Int > 0{
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
    
    func getNumOfLyrics()->Int {
        var numOfChild:Int = 0
        var isFinish = false
        
        webView.evaluateJavaScript("document.getElementsByClassName('lyrics-inner')[0].children.length") { (result, error) in
            if error == nil {
                numOfChild = result as! Int
            }
            isFinish = true
        }
        
        while (!isFinish) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        return numOfChild
    }
    
    func getLyricsIsRealTime()->Bool {
        var isSync = false
        var isFinish = false
        
        webView.evaluateJavaScript("document.getElementsByClassName('lyrics-inner')[0].getElementsByTagName('p')[0].getAttribute('time-id')") { (result, error) in
            if error != nil {
                isSync = false
            }
            else {
                isSync = true
            }
            isFinish = true
        }
        
        while (!isFinish) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        return isSync
    }
    
    /* 곡의 가사를 String으로 반환한다. for Genie */
    func getLyrics()->Lyrics {
        let lyrics = Lyrics()
        
        let numOfChild = getNumOfLyrics()
        let isRealTime = getLyricsIsRealTime()
        
        if isRealTime {
            lyrics.sync = true
            for i in 0..<numOfChild {
                lyrics.append(getLyricTime(i: i), getLyricContent(i: i))
            }
        }
        else {
            let str = getFullLyrics()
            var front = str.startIndex
            
            for i in str.characters.indices {
                if str[i] == "<" {
                    if str[str.index(i, offsetBy: 1)] == "p" {
                        lyrics.append(9999, str.substring(with: (front..<str.index(i, offsetBy: 0)))+"\n")
                        front = str.index(i, offsetBy: 4)
                    }
                }
            }
            
        }
        
        return lyrics
    }
    
    
    /* 지정된 가사를 반환. for Genie2 */
    func getLyricContent(i:Int)->String {
        var str:String = ""
        var isFinish = false
        
        webView.evaluateJavaScript("document.getElementsByClassName('lyrics-inner')[0].getElementsByTagName('p')[\(i)].innerHTML") { (result, error) in
            if error == nil {
                str = result as! String
            }
            isFinish = true
        }
        
        while (!isFinish) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        return str
    }
    
    /* 지정된 숫자 반환 for Genie2 */
    func getLyricTime(i:Int)->Int {
        var time:String = "0"
        var isFinish = false
        
        webView.evaluateJavaScript("document.getElementsByClassName('lyrics-inner')[0].getElementsByTagName('p')[\(i)].getAttribute('time-id')") { (result, error) in
            if error == nil {
                time = result as! String
            }
            isFinish = true
        }
        
        while (!isFinish) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        return Int(time)!
    }
    
    /* 전체 가사를 String으로 반환한다. for Genie2 */
    func getFullLyrics()->String {
        var str:NSString = ""
        var isFinish = false
        
        webView.evaluateJavaScript("document.getElementsByClassName('lyrics-inner')[0].innerHTML") { (result, error) in
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
    
    /* 지금 재생 목록에 있는 곡의 수를 Int로 반환한다. for Genie2 */
    func getNumOfSong()->Int {
        var isFinish = false
        var num = 0
        
        if checkPlayList() {
            webView.evaluateJavaScript("document.getElementsByClassName('ui-sortable')[0].children.length") { (result, error) in
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
    
    /* 반복듣기, 한곡재생등의 상태를 Int로 반환한다. 0:일반 1:반복듣기 2:한곡재생 for Genie2 */
    func stateOfRepeat()->Int {
        var isFinish = false
        var state = 0
        webView.evaluateJavaScript("document.getElementsByClassName('fp-icon fp-repeat')[0].innerHTML") { (result, error) in
            if error == nil {
                if String(describing: result).range(of: "해제") != nil {
                    state = 0
                }
                else if String(describing: result).range(of: "전체") != nil {
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
    
    /* 랜덤재생 여부를 Bool로반환한다. for Genie2 */
    func stateOfRandom()->Bool {
        var isFinish = false
        var state = false
        webView.evaluateJavaScript("document.getElementsByClassName('fp-icon fp-random').innerHTML") { (result, error) in
            if error == nil {
                if String(describing: result).range(of: "교차") != nil {
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
    
    /* 곡의 재생여부를 Bool로 반환한다. for Genie2 */
    func checkPlay()->Bool {
        var isFinish = false
        var isPlay = false
        if webView == nil {
            return false
        }
        webView.evaluateJavaScript("document.getElementsByClassName('fp-icon fp-playbtn').innerHTML") { (result, error) in
            if error == nil {
                if String(describing: result).range(of: "일") == nil {
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
    
    /* 재생중인 음질을 받아온다. Genie2 */
    /* 320kbps : 0, 192kbps : 1 */
    func getStreamingType()->Int {
        var isFinish = false
        var isPlay = -1
        webView.evaluateJavaScript("document.getElementsByClassName('toggle-button-box select-quality')[0].getElementsByClassName('btn')[0].innerHTML") { (result, error) in
            if error == nil {
                if String(describing: result).range(of: "320") != nil {
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
    
    /* Genie2 */
    func changeStreamingType() {
        if getStreamingType() == 0 {
            webView.evaluateJavaScript("fnSetStreamBit('192');", completionHandler: nil)
        }
        else {
            webView.evaluateJavaScript("fnSetStreamBit('320');", completionHandler: nil)
        }
    }
    
    /* 지금 재생중인 노래의 리스트상 순서를 반환한다. for Genie2 */
    func getNumOfSelectedSong()->Int {
        var isFinish = false
        var num = 0
        
        webView.evaluateJavaScript("$('li').index(document.getElementsByClassName('list this-play')[0])") { (result, error) in
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
        return (num-17)/4
    }
}


/* 플레이어 초기화 함수 모음 */
extension WebPlayerController {
    
    
    /* simulate함수를 inject한다. */
    func injectSimulateFunc() {
        webView.evaluateJavaScript("function simulate(element, eventName) { var options = extend(defaultOptions, arguments[2] || {}); var oEvent, eventType = null; for (var name in eventMatchers) { if (eventMatchers[name].test(eventName)) { eventType = name; break; } } if (!eventType) throw new SyntaxError('Only HTMLEvents and MouseEvents interfaces are supported'); if (document.createEvent) { oEvent = document.createEvent(eventType); if (eventType == 'HTMLEvents') { oEvent.initEvent(eventName, options.bubbles, options.cancelable); } else { oEvent.initMouseEvent(eventName, options.bubbles, options.cancelable, document.defaultView, options.button, options.pointerX, options.pointerY, options.pointerX, options.pointerY, options.ctrlKey, options.altKey, options.shiftKey, options.metaKey, options.button, element); } element.dispatchEvent(oEvent); } else { options.clientX = options.pointerX; options.clientY = options.pointerY; var evt = document.createEventObject(); oEvent = extend(evt, options); element.fireEvent('on' + eventName, oEvent); } return element; } function extend(destination, source) { for (var property in source) destination[property] = source[property]; return destination; } ", completionHandler: nil)
        webView.evaluateJavaScript("var eventMatchers = { 'HTMLEvents': /^(?:load|unload|abort|error|select|change|submit|reset|focus|blur|resize|scroll)$/, 'MouseEvents': /^(?:click|dblclick|mouse(?:down|up|over|move|out))$/ }", completionHandler: nil)
        webView.evaluateJavaScript("var defaultOptions = { pointerX: 0, pointerY: 0, button: 0, ctrlKey: false, altKey: false, shiftKey: false, metaKey: false, bubbles: true, cancelable: true }", completionHandler: nil)
    }
    
    /* 플레이리스트의 존재 여부를 확인하는 함수 for Genie2 */
    func checkPlayList()->Bool {
        var isFinish = false
        var isLogin = false
        if webView == nil {
            return false
        }
        webView.evaluateJavaScript("document.getElementsByClassName('no-result')[0]") { (result, error) in
            if result == nil {
                isLogin = true
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
    /* 재생 for Genie2 */
    func play() {
        /* 초기 재생할때의 script와 그 후의 script가 달라 두개다 호출한다. */
        webView.evaluateJavaScript("document.getElementsByClassName('fp-icon fp-playbtn')[0].click()", completionHandler: nil)
    }
    
    /* 일시정지 for Genie2 */
    func pause() {
        webView.evaluateJavaScript("document.getElementsByClassName('fp-icon fp-playbtn')[0].click()", completionHandler: nil)
    }
    
    /* 이전곡 for Genie2 */
    func prev() {
        webView.evaluateJavaScript("document.getElementsByClassName('fp-icon fp-prev')[0].click()", completionHandler: nil)
    }
    
    /* 다음곡 for Genie2 */
    func next() {
        webView.evaluateJavaScript("document.getElementsByClassName('fp-icon fp-next')[0].click()", completionHandler: nil)
    }
    
    /* 순차재생, 반복재생, 한곡재생 for Genie2 */
    func repeatList() {
        webView.evaluateJavaScript("document.getElementsByClassName('fp-icon fp-repeat')[0].click()", completionHandler: nil)
    }
    
    /* 랜덤재생 for Genie2 */
    func random() {
        webView.evaluateJavaScript("document.getElementsByClassName('fp-icon fp-random')[0].click()", completionHandler: nil)
    }
    
    /* 좋아요 for Genie2 */
    func like() {
        if stateOfLike() { webView.evaluateJavaScript("document.getElementsByClassName('btn-like')[0].click()", completionHandler: nil) }
        else { webView.evaluateJavaScript("document.getElementsByClassName('btn-like')[0].click()", completionHandler: nil) }
    }
    
    /* 선택된 곡 재생 for Genie2 */
    func playSelectedSong(i:Int) {
        webView.evaluateJavaScript("document.getElementsByClassName('ui-sortable')[0].getElementsByClassName('list')[\(i*2)].getElementsByClassName('btn-basic btn-listen')[0].click()", completionHandler: nil)
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
    
    /* 선택된 곡을 지운다. for Genie2 */
    func deleteSelectSong() {
        webView.evaluateJavaScript("document.getElementsByClassName('btn btn-del')[0].click()", completionHandler: nil)
    }
    
    /* 곡의 번호를 받아와 해당 곡을 선택한다. for Genie2 */
    func selectSong(_ i:Int) {
        webView.evaluateJavaScript("document.getElementsByClassName('ui-sortable')[0].getElementsByClassName('list')[\(i*2)].getElementsByClassName('select-check')[0].click()", completionHandler: nil)
    }
    
    /* 모든 곡을 선택한다. for Genie2 */
    func selectAllSong() {
        webView.evaluateJavaScript("document.getElementsByClassName('all-check')[0].click()", completionHandler: nil)
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
    
    /* 선택된 곡을 한칸 위로 이동시킨다. for Genie2 */
    func moveUp() {
        webView.evaluateJavaScript("document.getElementsByClassName('btn up')[0].click()", completionHandler: nil)
    }
    
    /* 선택된 곡을 한칸 아래로 이동시킨다. for Genie2 */
    func moveDown() {
        webView.evaluateJavaScript("document.getElementsByClassName('btn down')[0].click()", completionHandler: nil)
        
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
