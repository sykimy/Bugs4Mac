//
//  SideListController.swift
//  Music
//
//  Created by sykimy on 2016. 8. 2..
//  Copyright © 2016년 sykimy. All rights reserved.
//

import Cocoa
import WebKit

class SideListController:NSObject, WKNavigationDelegate, WKUIDelegate {
    /* 사이드리스트 뷰 */
    @IBOutlet var sideList: NSOutlineView!
    
    /* 텝 뷰 */
    @IBOutlet var tabView: NSTabView!
    
    @IBOutlet var webPlayerWindow: NSWindow!
    
    /* processPool공유를 위한 링크 */
    @IBOutlet var webPlayer: WebPlayerController!
    
    @IBOutlet var player: PlayerController!
    /* 내 앨범 리스트를 받아올 웹뷰가 로드될때까지 대기시키기 위한 변수 */
    var loadComplete = false
    
    /* 사이드리스트에서 선택이 되었을때 보일 웹뷰 */
    @IBOutlet var mainWebViewController: MainWebViewController!
    
    /* 내 앨범을 불러올 웹 뷰 */
    var webView:WKWebView!
    
    /* 웹뷰를 올릴 윈도우 */
    var window:NSWindow!
    
    /* sideList에 띄울 아이템들 */
    /* 2차 배열 구조이다. */
    var items = [ParentItem]()
    
    /* 내 앨범의 로딩 딜레이를 해결하기 위한 타이머 */
    var myAlbumTimer:Timer!
    
    var changed = false
    
    /* 사이드 리스트 뷰를 열고 윈도우에 등록 */
    func initSideListWebView() {
        /* 윈도우를 만든다. 타입은 상관없다. */
        window = NSWindow(contentRect: NSMakeRect(10, NSScreen.main()!.visibleFrame.size.height-95, 370, 615),
                          styleMask: [NSWindowStyleMask.closable, NSWindowStyleMask.titled],
                          backing: NSBackingStoreType.buffered, defer: true)
        
        /* 웹뷰에 입력될 설정값을 설정한다. */
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true    //자바스크립트를 허용한다.
        preferences.javaEnabled = true      //자바를 허용한다.
        preferences.javaScriptCanOpenWindowsAutomatically = true    //자바스크립트 팝업을 허용한다.
        preferences.plugInsEnabled = true   //플러그인을 허용한다.
        
        /* 웹뷰의 환경 설정 값을 입력한다. */
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences     //위에서의 설정값을 웹뷰에 입력
        configuration.processPool = webPlayer.processPool   //processPool을 공유하기위헤 login에 연결한다.
        
        /* 웹 뷰를 초기화한다. */
        webView = WKWebView(frame: window.contentLayoutRect, configuration: configuration)  //웹뷰 생성
        webView.navigationDelegate = self   //로드와 관련된 Delegate를 설정
        //webView.uiDelegate = self       //
        
        /* 윈도우의 컨텐츠뷰와 웹뷰를 연결 */
        window.contentView = webView
        
        /* NMP페이지를 로드 */
        webView.load(URLRequest(url: URL(string: "http://www.bugs.co.kr/")!))
    }
    
    func deinitSideListView() {
        webView = nil
        window = nil
    }
    
    func syncSideList() {
        if webView == nil {
            player.nameTextField.stringValue = "initSideListWebView"
            initSideListWebView()   //사이드리스트의 웹뷰를 초기화한다.(웹뷰를 생성하고 설정한다.)
        }
    }
    
    func getSideList() {
        /* 리스트의 배열을 초기화한다. */
        for i in 0..<items.count {
            items[i].children.removeAll()
        }
        items.removeAll()
        
        player.nameTextField.stringValue = "add Header"
        /* 헤더를 추가해준다. */
        items.append(ParentItem(name:"지금 재생 목록", isHeader: true))
        items.append(ParentItem(name:"벅스 뮤직", isHeader: true))
        
        /* 웹에서 받아오는 것으로 하려했지만 속도를 위해 직접입력한다. */
        items.append(ParentItem(name: "벅스차트", isHeader: false))
        items.append(ParentItem(name: "최신음악", isHeader: false))
        items.append(ParentItem(name: "뮤직4U", isHeader: false))
        items.append(ParentItem(name: "장르", isHeader: false))
        items.append(ParentItem(name: "뮤직포스트", isHeader: false))
        
        /* 테마의 자식들을 등록한다. */
        items.append(ParentItem(name: "테마", isHeader: false))
        items[items.count-1].appendChild("뮤직PD 앨범", num: 0, parent: items[items.count-1].name)
        items[items.count-1].appendChild("추천앨범 리뷰", num: 1, parent: items[items.count-1].name)
        items[items.count-1].appendChild("연도별", num: 2, parent: items[items.count-1].name)
        items[items.count-1].appendChild("매니아", num: 3, parent: items[items.count-1].name)
        
        items.append(ParentItem(name: "라디오", isHeader: false))
        items.append(ParentItem(name: "FLAC전용관", isHeader: false))
        items.append(ParentItem(name: "벅스 on TV", isHeader: false))
        
        
        player.nameTextField.stringValue = "get Bugs TV"
        /* 벅스TV의 목록을 받아온다. */
        /* 웹뷰에서 완전 로드 될때까지 대기한다. */
        if webView == nil {
            return
        }

        for _ in 0..<50 {
            if getNumOfBugsOnTV() != -1 {
                break
            }
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        player.nameTextField.stringValue = "get NumOfButgsTV"
        /* 벅스TV의 자식들의 수를 받아온다. */
        let numOfBugsOnTVElements = getNumOfBugsOnTV()
        
        /* 0개가 아니면(때때로 0개가 받아져 충돌이 일어난다.) */
        if numOfBugsOnTVElements != 0 {
            /* 자식들의 값을 받아와 리스트에 추가한다. */
            for i in 0 ..< numOfBugsOnTVElements {
                while ( getHrefOfBugsOnTVElement(i) == "" ) {
                    RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
                }
                items[items.count-1].appendChild(getTitleOfBugsOnTVElement(i), href: getHrefOfBugsOnTVElement(i), num: i, parent: items[items.count-1].name)
            }
        }
        
        items.append(ParentItem(name: "내 음악", isHeader: false))
        items[items.count-1].appendChild("최근 들은 곡", num: 0, parent: items[items.count-1].name)
        items[items.count-1].appendChild("가장 많이 들은 곡", num: 1, parent: items[items.count-1].name)
        items[items.count-1].appendChild("구매한 음악", num: 2, parent: items[items.count-1].name)
        items[items.count-1].appendChild("좋아한 음악", num: 3, parent: items[items.count-1].name)
        
        items.append(ParentItem(name: "내 앨범", isHeader: false))
        
        
        player.nameTextField.stringValue = "get MyAlbum"
        if webView == nil {
            return
        }
        while( getNumOfMyAlbum() == -1 ) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
            if webView == nil {
                return
            }
        }
        
        player.nameTextField.stringValue = "get NumOFMYAlbum"
        /* 내 앨범의 자식들의 수를 받아온다. */
        for _ in 0..<50 {
            if getNumOfMyAlbum() > 0 {
                break
            }
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        let numOfMyAlbumElements = getNumOfMyAlbum()
        
        for i in 0..<numOfMyAlbumElements {
            while ( getHrefOfMyAlbumElement(i) == "" ) {
                RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: NSDate.distantFuture)
            }
            items[items.count-1].appendChild(getTitleOfMyAlbumElement(i), href: getHrefOfMyAlbumElement(i), num: i, parent: items[items.count-1].name)
        }
        
        player.nameTextField.stringValue = "end"
        sideList.reloadItem(items, reloadChildren: true)
        self.sideList.reloadData()
        
        deinitSideListView()
    }
    
    @IBAction func doubleAction(_ sender: NSOutlineView) {
        let item = sender.item(atRow: sender.clickedRow)
        
        if item is ParentItem {
            
            let node = item as! ParentItem
            
            if !node.isHeader {
                if sender.isItemExpanded(item) {
                    sender.collapseItem(item)
                } else {
                    sender.expandItem(item)
                }
            }
        }
    }
    
    func showWebPlayer() {
        //webPlayerWindow.alphaValue = 0   //윈도우를 투명하게 변경
        //webPlayerWindow.makeKeyAndOrderFront(self)    //윈도우를 연다.
    }
    
    func closeWebPlayer() {
        //webPlayerWindow.close()
    }
    
    /* 선택시 함수 */
    @IBAction func action(_ sender: NSOutlineView) {
        //let item = NSOutlineView
        
        let item = sender.item(atRow: sender.clickedRow)
        
        //print(sender.clickedRow)
        //print(item)
        
        /* 아이템이 부모항목이면 */
        if item is ParentItem {
            
            let node = item as! ParentItem
            
            if node.isHeader {
                if node.name == "지금 재생 목록" {
                    tabView.selectTabViewItem(at: 0)
                    mainWebViewController.deinitWebView()
                }
                else if node.name == "벅스 뮤직" {
                    showWebPlayer()
                    mainWebViewController.deinitWebView()
                    mainWebViewController.initWebView()
                    mainWebViewController.openHome()
                    tabView.selectTabViewItem(at: 1)
                    closeWebPlayer()
                }
            }
            else {
                showWebPlayer()
                mainWebViewController.deinitWebView()
                mainWebViewController.initWebView()
                if node.name == "벅스차트" {
                    mainWebViewController.openBugsChart()
                    tabView.selectTabViewItem(at: 2)
                }
                else if node.name == "최신음악" {
                    mainWebViewController.openNewest()
                    tabView.selectTabViewItem(at: 2)
                }
                else if node.name == "뮤직4U" {
                    mainWebViewController.openMusic4U()
                    tabView.selectTabViewItem(at: 2)
                }
                else if node.name == "장르" {
                    mainWebViewController.openGenre()
                    tabView.selectTabViewItem(at: 2)
                }
                else if node.name == "뮤직포스트" {
                    mainWebViewController.openMusicPost()
                    tabView.selectTabViewItem(at: 2)
                }
                else if node.name == "라디오" {
                    mainWebViewController.openRadio()
                    tabView.selectTabViewItem(at: 2)
                }
                else if node.name == "FLAC전용관" {
                    mainWebViewController.openFLAC()
                    tabView.selectTabViewItem(at: 2)
                }
                closeWebPlayer()
            }
        }
        else if item is ChildItem {
            let node = item as! ChildItem
            
            showWebPlayer()
            mainWebViewController.deinitWebView()
            mainWebViewController.initWebView()
            
            if node.parent == "테마" {
                if node.num == 0 {
                    mainWebViewController.openMusicPDAlbum()
                    tabView.selectTabViewItem(at: 2)
                }
                else if node.num == 1 {
                    mainWebViewController.openRecommendMusicReview()
                    tabView.selectTabViewItem(at: 2)
                }
                else if node.num == 2 {
                    mainWebViewController.openAnnual()
                    tabView.selectTabViewItem(at: 2)
                }
                else if node.num == 3 {
                    mainWebViewController.openMania()
                    tabView.selectTabViewItem(at: 2)
                }
            }
            else if node.parent == "벅스 on TV" {
                mainWebViewController.openHref(node.href)
                tabView.selectTabViewItem(at: 2)
            }
            else if node.parent == "내 음악" {
                if node.num == 0 {
                    mainWebViewController.openRecentListenedMusic()
                    tabView.selectTabViewItem(at: 2)
                }
                else if node.num == 1 {
                    mainWebViewController.openMostListenedMusic()
                    tabView.selectTabViewItem(at: 2)
                }
                else if node.num == 2 {
                    mainWebViewController.openBoughtMusic()
                    tabView.selectTabViewItem(at: 2)
                }
                else if node.num == 3 {
                    mainWebViewController.openLikedMusic()
                    tabView.selectTabViewItem(at: 2)
                }
            }
            else if node.parent == "내 앨범" {
                mainWebViewController.openHref(node.href)
                tabView.selectTabViewItem(at: 2)
            }
            
            closeWebPlayer()
        }
    }
    
    @IBAction func reload(_ sender: AnyObject) {
        syncSideList()
    }
    
    @IBAction func editMyAlbum(_ sender: AnyObject) {
        mainWebViewController.openEditMyAlbum()
        tabView.selectTabViewItem(at: 2)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        getSideList()
    }
}

extension SideListController {
    func getNumOfBugsOnTV()->Int {
        var isFinish = false
        var num = -1
        
        webView.evaluateJavaScript("document.getElementsByClassName('bugsonTV')[0].getElementsByTagName('li').length") { (result, error) in
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
    
    func getHrefOfBugsOnTVElement(_ i:Int)->String {
        /* 값을 받아올때까지 false를 유지하는 변수 */
        var isFinish = false
        
        /* 반환할 값을 저장할 변수 */
        var str:String! = nil
        
        /* 웹뷰에 script를 입력한다. */
        webView.evaluateJavaScript("document.getElementsByClassName('bugsonTV')[0].getElementsByTagName('li')[\(i)].getElementsByTagName('a')[0].getAttribute('href')") { (result, error) in
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
            return ""
        }
        
        return str
    }
    
    func getTitleOfBugsOnTVElement(_ i:Int)->String {
        /* 값을 받아올때까지 false를 유지하는 변수 */
        var isFinish = false
        
        /* 반환할 값을 저장할 변수 */
        var str:String! = nil
        
        /* 웹뷰에 script를 입력한다. */
        webView.evaluateJavaScript("document.getElementsByClassName('bugsonTV')[0].getElementsByTagName('li')[\(i)].getElementsByTagName('a')[0].innerHTML") { (result, error) in
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
            return ""
        }
        else {
            str.removeSubrange(str.index(str.endIndex, offsetBy: -13)..<str.endIndex)
        }
        
        return str
    }
    
    func getNumOfMyAlbum()->Int {
        var isFinish = false
        var num = -1
        
        webView.evaluateJavaScript("document.getElementById('gnbMyalbumListArea').getElementsByTagName('li').length") { (result, error) in
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
    
    func getNumOfMyAlbumFromPage()->Int {
        var isFinish = false
        var num = -1
        
        webView.evaluateJavaScript("document.getElementsByClassName('list trackList')[0].getElementsByTagName('tbody')[0].getElementsByTagName('tr').length") { (result, error) in
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
    
    
    func getHrefOfMyAlbumElement(_ i:Int)->String {
        /* 값을 받아올때까지 false를 유지하는 변수 */
        var isFinish = false
        
        /* 반환할 값을 저장할 변수 */
        var str:String! = nil
        
        /* 웹뷰에 script를 입력한다. */
        webView.evaluateJavaScript("document.getElementById('gnbMyalbumListArea').getElementsByTagName('li')[\(i)].getElementsByTagName('a')[0].getAttribute('href')") { (result, error) in
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
            return ""
        }
        
        return str
    }
    
    func getTitleOfMyAlbumElement(_ i:Int)->String {
        /* 값을 받아올때까지 false를 유지하는 변수 */
        var isFinish = false
        
        /* 반환할 값을 저장할 변수 */
        var str:String! = nil
        
        /* 웹뷰에 script를 입력한다. */
        webView.evaluateJavaScript("document.getElementById('gnbMyalbumListArea').getElementsByTagName('li')[\(i)].getElementsByTagName('a')[0].innerHTML") { (result, error) in
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
            return ""
        }
        else {
            str.removeSubrange(str.index(str.endIndex, offsetBy: -34)..<str.endIndex)
        }
        
        return str
    }
}

extension SideListController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {

        if let parentItem = item as? ParentItem {
            return parentItem.children.count
        }

        return self.items.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let parentItem = item as? ParentItem {
            if index >= (item as! ParentItem).children.count {
                return 0
            }
            
            return parentItem.children[index]
        }
        
        return self.items[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let parentItem = item as? ParentItem {
            return parentItem.children.count > 0
        }
        
        return false
    }
}

extension SideListController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var view: NSTableCellView?
        // More code here
        //1
        if let parentItem = item as? ParentItem {
            //2
            if parentItem.name == "지금 재생 목록" || parentItem.name == "벅스 뮤직" || parentItem.name == "마이 뮤직" {
                view = sideList.make(withIdentifier: "HeaderCell", owner: self) as? NSTableCellView
                if let textField = view?.textField {
                    //3
                    textField.stringValue = parentItem.name
                    textField.sizeToFit()
                    return view
                }
            }
            view = sideList.make(withIdentifier: "FeedCell", owner: self) as? NSTableCellView
            if let textField = view?.textField {
                //3
                textField.stringValue = parentItem.name
                textField.sizeToFit()
                return view
            }
        }
        else if let childItem = item as? ChildItem {
            view = outlineView.make(withIdentifier: "FeedCell", owner: self) as? NSTableCellView
            if let textField = view?.textField {
                textField.stringValue = childItem.title
                textField.sizeToFit()
                return view
            }
        }
        
        
        return view
    }
}
