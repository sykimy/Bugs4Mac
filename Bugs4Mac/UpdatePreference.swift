//
//  CheckUpdate.swift
//  Bugs
//
//  Created by sykimy on 2016. 10. 1..
//  Copyright © 2016년 sykimy. All rights reserved.
//

//더이상 쓰지 않는다.
/*
import Cocoa
import WebKit

class CheckUpdate:NSObject, WKNavigationDelegate, WKUIDelegate {
    let nowVersion = "1.0.5.1"
    
    var webView:WKWebView!
    
    var updateWindow:NSWindow!
    
    let defaults = UserDefaults.standard
    
    @IBOutlet var checkAtStartButton: NSButton!
    
    @IBAction func checkNow(_ sender: AnyObject) {
        initUpdate()
    }
    
    @IBAction func checkAtStart(_ sender: AnyObject) {
        if checkAtStartButton.state == 1 {
            defaults.set(true, forKey: "checkUpdate")
        }
        else {
            defaults.set(false, forKey: "checkUpdate")
        }
    }
    
    override func awakeFromNib() {
        if defaults.object(forKey: "checkUpdate") != nil {
            if defaults.bool(forKey: "checkUpdate") {
                checkAtStartButton.state = 1
                initUpdate()
            }
            else {
                checkAtStartButton.state = 0
            }
        }
        else {
            checkAtStartButton.state = 1
            initUpdate()
        }
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
    
    func initUpdate() {
        
        updateWindow = NSWindow(contentRect: NSMakeRect(10, NSScreen.main()!.visibleFrame.size.height-95, 630, 560),
                                styleMask: [NSWindowStyleMask.closable, NSWindowStyleMask.titled],
                                backing: NSBackingStoreType.buffered, defer: true)
        
        /* Create our preferences on how the web page should be loaded */
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        preferences.plugInsEnabled = true
        
        /* Create a configuration for our preferences */
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        
        /* 새로운 WKWebView를 만든다. */
        webView = WKWebView(frame: updateWindow.contentLayoutRect, configuration: configuration)
        
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        /* 새창을 만든다. */
        updateWindow.contentView = webView
        
        webView.load(URLRequest(url: URL(string: "http://sykimy.woobi.co.kr/")!))
    }
    
    func checkUpdate() {
        let href = injectScript("document.getElementsByTagName('div')[1].getAttribute('a')") as! String
        let version = injectScript("document.getElementsByTagName('div')[1].getAttribute('version')") as! String
        let sentence = injectScript("document.getElementsByTagName('div')[1].getAttribute('sentence')") as! String
        
        if version == "" {
            let myPopup: NSAlert = NSAlert()
            myPopup.messageText = "앗! 업데이트 정보를 불러오지 못했습니다."
            myPopup.informativeText = "서버상태가 불안전해 접속하지 못하고 있습니다..ㅠㅠ"
            myPopup.alertStyle = NSAlertStyle.warning
            myPopup.addButton(withTitle: "네")
            myPopup.runModal()
        }
        else if nowVersion != version {
            let answer = dialogOKCancel(question: "새로운 업데이트가 있습니다. (v.\(nowVersion)->v.\(version))", text: "지금 개발자의 블로그로 이동하시겠습니까?\n\(sentence)")
            if answer {
                NSWorkspace.shared().open(URL(string: href)!)
                deinitUpdate()
            }
            else {
                deinitUpdate()
            }
        }
        else {
            deinitUpdate()
        }
    }
    
    func dialogOKCancel(question: String, text: String) -> Bool {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = question
        myPopup.informativeText = text
        myPopup.alertStyle = NSAlertStyle.warning
        myPopup.addButton(withTitle: "네")
        myPopup.addButton(withTitle: "아니오")
        return myPopup.runModal() == NSAlertFirstButtonReturn
    }
    
    func deinitUpdate() {
        webView = nil
        updateWindow = nil
    }
    
    /* 페이지 로드가 끝나면 호출하는 함수 */
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        checkUpdate()
    }
}*/
