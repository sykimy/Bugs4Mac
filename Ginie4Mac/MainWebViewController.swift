//
//  MainWebViewController.swift
//  Music
//
//  Created by sykimy on 2016. 9. 17..
//  Copyright © 2016년 sykimy. All rights reserved.
//


import Cocoa
import WebKit

class MainWebViewController: NSViewController {
    
    var webView:WKWebView!
    var radioWindow:NSWindow!
    
    @IBOutlet var mvPlayer: MoviePlayerController!
    @IBOutlet var radio: RadioController!
    @IBOutlet var playerController: PlayerController!
    @IBOutlet var lyricPlayer: LyricPlayer!
    @IBOutlet var sideList: SideListController!
    @IBOutlet var search: SearchController!
    @IBOutlet var appDelegate: AppDelegate!
    @IBOutlet var webPlayer: WebPlayerController!
    
    let nc = NotificationCenter.default
    
    @IBOutlet var tabView: NSTabView!
    
    var isMain = true
    
    var chartTimer:Timer!
    
    var timer = 0
    var count = false
    
    private var editMyAblumMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        /*
        /* Create our preferences on how the web page should be loaded */
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        preferences.plugInsEnabled = true
        
        /* Create a configuration for our preferences */
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.processPool = webPlayer.processPool
        
        /* Now instantiate the web view */
        webView = WKWebView(frame: view.bounds, configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        
        self.view.addSubview(webView)
        webView.load(URLRequest(url: URL(string: "http://www.bugs.co.kr/")!))*/
        
        nc.addObserver(self, selector: #selector(MainWebViewController.resizeWebView), name: NSNotification.Name(rawValue: "NSViewFrameDidChangeNotification"), object: nil)
    }
    
    func initWebView() {
        /* Create our preferences on how the web page should be loaded */
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        preferences.plugInsEnabled = true
        
        /* Create a configuration for our preferences */
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.processPool = webPlayer.processPool
        
        /* Now instantiate the web view */
        webView = WKWebView(frame: view.bounds, configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        
        self.view.addSubview(webView)
        //webView.load(URLRequest(url: URL(string: "http://www.bugs.co.kr/")!))
    }
    
    func deinitWebView() {
        for view in view.subviews {
            view.removeFromSuperview()
        }
        
        webView = nil
        
        if chartTimer != nil {
            chartTimer.invalidate()
        }
    }
    
    /* 검색창을 열고 검색을 시작한다. */
    func openSearch(_ str:String) {
        initWebView()
        openHome()
        
        webView.evaluateJavaScript("document.getElementById('headerSearchInput').value = ''", completionHandler: nil)
        
        while(!isLoadComplete()) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        webView.evaluateJavaScript("document.getElementById('headerSearchInput').click()", completionHandler: nil)
        webView.evaluateJavaScript("document.getElementById('headerSearchInput').value = '\(str)'", completionHandler: nil)
        webView.evaluateJavaScript("document.getElementById('hederSearchFormButton').click()", completionHandler: nil)
        
        isMain = false
    }
    
    /* 웹뷰의 사이즈를 화면 크기에 맞춘다. */
    func resizeWebView() {
        if webView != nil {
            webView.setFrameSize(NSSize(width: view.bounds.width, height: view.bounds.height))
        }
    }
    
    //-------------------------------------------------------------------------------------------------------------------------
    //  벅스 홈페이지의 각 사이드 리스트의 페이지들을 여는 함수 모음. SideListController에서 호출한다.
    //  isMain이 true이면 웹형식 그대로
    //  false이면 플레이어에 맞게 변환한다.
    
    func openHome() {
        isMain = true
        webView.load(URLRequest(url: URL(string: "http://www.bugs.co.kr/")!))
    }
    
    
    func openBugsChart() {
        webView.load(URLRequest(url: URL(string: "http://music.bugs.co.kr/chart?wl_ref=M_left_02_01")!))
        
        isMain = false
    }
    
    func openNewest() {
        webView.load(URLRequest(url: URL(string: "http://music.bugs.co.kr/newest?wl_ref=M_left_02_03")!))
        
        isMain = false
    }
    
    func openMusic4U() {
        webView.load(URLRequest(url: URL(string: "http://music.bugs.co.kr/music4u?wl_ref=M_left_02_02")!))
        
        isMain = false
    }
    
    func openGenre() {
        webView.load(URLRequest(url: URL(string: "http://music.bugs.co.kr/genre/home?wl_ref=M_left_02_06")!))
        
        isMain = false
    }
    
    func openMusicPost() {
        webView.load(URLRequest(url: URL(string: "http://music.bugs.co.kr/special?wl_ref=M_left_02_08")!))
        
        isMain = false
    }
    
    func openBside() {
        webView.load(URLRequest(url: URL(string: "http://music.bugs.co.kr/bside?wl_ref=M_left_02_13")!))
        
        isMain = false
    }
    
    func openRadio() {
        webView.load(URLRequest(url: URL(string: "http://music.bugs.co.kr/radio?wl_ref=M_left_02_10")!))
        
        isMain = false
    }
    
    func openFLAC() {
        webView.load(URLRequest(url: URL(string: "http://music.bugs.co.kr/flactheater/home?wl_ref=M_left_02_11")!))
        
        isMain = false
    }
    
    func openMusicPDAlbum() {
        webView.load(URLRequest(url: URL(string: "http://music.bugs.co.kr/musicpd?wl_ref=M_left_02_04")!))
        
        isMain = false
    }
    
    func openRecommendMusicReview() {
        webView.load(URLRequest(url: URL(string: "http://music.bugs.co.kr/recomreview?wl_ref=M_left_02_05")!))
        
        isMain = false
    }
    
    func openAnnual() {
        webView.load(URLRequest(url: URL(string: "http://music.bugs.co.kr/years?wl_ref=M_left_02_07")!))
        
        isMain = false
    }
    
    func openMania() {
        webView.load(URLRequest(url: URL(string: "http://music.bugs.co.kr/maniachart/kpop?wl_ref=M_left_02_09")!))
        
        isMain = false
    }
    
    func openHref(_ url: String) {
        webView.load(URLRequest(url: URL(string: url)!))
        
        isMain = false
    }
    
    func openRecentListenedMusic() {
        webView.load(URLRequest(url: URL(string: "http://www.bugs.co.kr/user/library/listen?wl_ref=M_left_03_05")!))
        
        isMain = false
    }
    
    func openMostListenedMusic() {
        webView.load(URLRequest(url: URL(string: "http://www.bugs.co.kr/user/library/listen?sort=LISTEN_COUNT&wl_ref=M_left_03_06")!))
        
        isMain = false
    }
    
    func openBoughtMusic() {
        webView.load(URLRequest(url: URL(string: "http://www.bugs.co.kr/user/library/purchased/track?wl_ref=M_left_03_01")!))
        
        isMain = false
    }
    
    func openLikedMusic() {
        webView.load(URLRequest(url: URL(string: "http://www.bugs.co.kr/user/library/like/track?wl_ref=M_left_03_02")!))
        
        isMain = false
    }
    
    func openEditMyAlbum() {
        webView.load(URLRequest(url: URL(string: "http://www.bugs.co.kr/user/library/myalbum/list?wl_ref=M_left_03_07")!))
        editMyAblumMode = true
        
        isMain = false
    }
    
    //-------------------------------------------------------------------------------------------------------------------------

    /* 로드가 다됐나 확인한다. */
    //로드라기보다는 벅스 사이트를 보면 검색창에 추천검색어?가 들어가있다.
    //이값을 지워주고 지워졌는지 확인하는 함수이다.
    func isLoadComplete()->Bool {
        var isFinish = false
        var isLoad = false
        self.webView.evaluateJavaScript("document.getElementById('headerSearchInput').value") { (result, error) in
            if error == nil {
                if result as! String != "" {
                    isLoad = true
                }
            }
            isFinish = true
        }
        
        while (!isFinish) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        return isLoad
    }
    
    //플레이어에 맞게끔 웹사이트의 형식을 조절한다.
    func editCSS4Player() {
        webView.evaluateJavaScript("document.getElementById('header').outerHTML = ''", completionHandler: nil)
        webView.evaluateJavaScript("document.getElementById('gnb').outerHTML = ''", completionHandler: nil)
        webView.evaluateJavaScript("document.getElementById('hyrendContentBody').setAttribute('style','')", completionHandler: nil)
        webView.evaluateJavaScript("document.getElementById('footer').outerHTML = ''", completionHandler: nil)
        webView.evaluateJavaScript("document.getElementById('wrap').setAttribute('style','padding-top:0')", completionHandler: nil)
        //webView.evaluateJavaScript("document.getElementsByClassName('listControls floatSubMenu over')[0].setAttribute('style',top:0')", completionHandler: nil)
        
        while( !isEditComplete() ) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        tabView.selectTabViewItem(at: 1)
    }
    
    //사이트 형식의 편집이 완료됐나 체크한다.
    func isEditComplete()->Bool {
        var isFinish = false
        var isLoad = false
        self.webView.evaluateJavaScript("document.getElementById('gnb').outerHTML") { (result, error) in
            if error != nil {
                isLoad = true
            }
            isFinish = true
        }
        
        while (!isFinish) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        return isLoad
    }
    
    //isChartPage()로 차트페이지임이 확인되면
    //스크롤을 내릴시차트의 모양을 잡아준다.
    func editChart() {
        if !isChartEdited() {
            webView.evaluateJavaScript("document.getElementsByClassName('listControls floatSubMenu over')[0].setAttribute('style','top: 0px; position: fixed; margin-left: 0px; width: 940px;')", completionHandler: nil)
        }
        
        if count {
            timer += 1
            if timer > 1 {
                count = false
                timer = 0
            }
        }
    }
    
    //차트가 포함된 페이지인지 확인
    func isChartPage()->Bool {
        var isFinish = false
        var isLoad = false
        self.webView.evaluateJavaScript("document.getElementsByClassName('list trackList')[0].innerHTML") { (result, error) in
            if error == nil {
                isLoad = true
            }
            isFinish = true
        }
        
        while (!isFinish) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        return isLoad
    }
    
    //차트가 수정되었나 확인
    func isChartEdited()->Bool {
        var isFinish = false
        var isLoad = false
        self.webView.evaluateJavaScript("document.getElementsByClassName('listControls floatSubMenu over')[0].getAttribute('style')") { (result, error) in
            if error == nil {
                if String(describing: result).range(of: "top") != nil {
                    isLoad = true
                }
            }
            isFinish = true
        }
        
        while (!isFinish) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        return isLoad
    }
    
    //검색항목이 있나 확인
    func isSearchBe()->Bool {
        var isFinish = false
        var isLoad = false
        self.webView.evaluateJavaScript("document.getElementsByTagName('tbody')[1].getElementsByTagName('tr')[0].getAttribute('albumid')") { (result, error) in
            if error == nil {
                if !(result is NSNull) {
                    isLoad = true
                }
            }
            isFinish = true
        }
        
        while (!isFinish) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        return isLoad
    }
    
    //플레이버튼 함수를 받아온다.
    func getPlayFunction()->String {
        var isFinish = false
        var str = ""
        self.webView.evaluateJavaScript("document.getElementsByTagName('tbody')[1].getElementsByTagName('tr')[0].getElementsByClassName('btn play')[0].getAttribute('onclick')") { (result, error) in
            if error == nil {
                if !(result is NSNull) {
                    str = result as! String
                }
            }
            isFinish = true
        }
        
        while (!isFinish) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        return str
    }
    
    /* WKWebView에 스크립트를 입력하고, string값을 리턴한다. */
    func injectScript(_ script:String)->AnyObject {
        /* 값을 받아올때까지 false를 유지하는 변수 */
        var isFinish = false
        
        /* 반환할 값을 저장할 변수 */
        var str:String! = nil
        
        /* 웹뷰에 script를 입력한다. */
        webView.evaluateJavaScript(script) { (result, error) in
            if error == nil {
                /* 값을 받아온다. */
                if result is NSNull {
                    str = ""
                }
                else {
                    str = result as! String
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
        
        if str == nil {
            return "" as AnyObject
        }
        
        return str as AnyObject
    }
    
}

/* WKWebView Delegate 함수 모음 */
extension MainWebViewController: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if !isMain {
            tabView.selectTabViewItem(at: 2)
        }
    }
    
    /* 페이지 로드가 끝나면 호출하는 함수 */
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if !isMain {
            //사이트를 수정해서 뜨게해도 되는지 몰라 주석처리 하였습니다.
            editCSS4Player()
            if isChartPage() {
                if chartTimer != nil { chartTimer.invalidate() }
                chartTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(editChart), userInfo: nil, repeats: true)
            }
            else {
                if chartTimer != nil { chartTimer.invalidate() }
            }
            
            //URL이 검색 URL일시,
            if webView.url!.absoluteString.range(of: "http://search.bugs.co.kr/track?q=") != nil {
                //곡이있는지 찾은후
                if isSearchBe() && search.playNow {
                    searchNPlay()   //곡이있다면 재생
                }
            }
            
            if webView.url!.absoluteString == "http://www.bugs.co.kr/user/library/myalbum/list?wl_ref=M_left_03_07" {
                sideList.getSideList()
            }
            
        }
    }
    
    func searchNPlay() {
        //바로 재생을 하면 재생이 되지 않는다. 따라서 약간의 딜레이를 준다. (0.3초)
        count = true
        
        var visible = true
        
        //윈도우가 보이는 상태가 아니면
        if !appDelegate.window.isVisible {
            visible = false //윈도우를 띄우기전 보이지 않던 상태라는걸 저장.
            appDelegate.window.alphaValue = 0   //윈도우를 투명하게 변경
            appDelegate.reopen(self)    //윈도우를 연다.
        }
        
        //딜레이
        while (count) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        //
        self.webView.evaluateJavaScript(getPlayFunction(), completionHandler: nil)
        
        //보이지 않던 상태였다면
        if !visible {
            //다시 창을 보이게하고, 닫는다.
            appDelegate.window.alphaValue = 1.0
            appDelegate.close()
        }
    }
    
    /* 팝업창이 뜰때의 delegate */
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            let url = navigationAction.request.url
            
            if String(describing: url).range(of: "newRadio") != nil {
                if playerController.isLogin {
                    radio.initRadio()
                    radio.load(url!)
                    lyricPlayer.mode = .Radio
                    playerController.mode = .Radio
                }
            }
            else if String(describing: url).range(of: "mvPlayer") != nil {
                mvPlayer.initMoviePlayer()
                mvPlayer.load(url!)
            }
            else if String(describing: url).range(of: "payco") != nil || String(describing: url).range(of: "facebook") != nil {
                let alert = NSAlert()
                alert.messageText = "잘못된 로그인 시도입니다."
                alert.informativeText = "우측 상단의 초록색 문버튼을 눌러 로그인해주세요."
                alert.alertStyle = .warning
                alert.addButton(withTitle: "확인")
                alert.runModal()
            }
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage: String, initiatedByFrame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(true)
        sideList.syncSideList()
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage: String, initiatedByFrame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        completionHandler()
        sideList.syncSideList()
    }
    
}

