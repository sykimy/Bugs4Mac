//
//  LoginWebViewController.swift
//  Music
//
//  Created by sykimy on 2016. 8. 2..
//  Copyright © 2016년 sykimy. All rights reserved.
//


import Cocoa
import WebKit

class LoginWebViewController: NSViewController, WKNavigationDelegate, WKUIDelegate{
    
    var popupWindow:NSWindow!
    var popupController:NSWindowController!
    
    var webView:WKWebView!
    var popupView:WKWebView!
    
    @IBOutlet var webPlayer: WebPlayerController!
    
    @IBOutlet var sideListController: SideListController!
    
    @IBOutlet var idTextField: NSTextField!
    @IBOutlet var pwTextField: NSSecureTextField!
    @IBOutlet var alwaysLoginButton: NSButton!
    @IBOutlet var loginButton: NSButton!
    @IBOutlet var state: NSTextField!
    
    @IBOutlet var playerController: PlayerController!
    
    @IBOutlet var pwField: NSTextField!
    @IBOutlet var idField: NSTextField!
    
    var id, pw:String!
    var al:Int!
    
    var tryLogin = false
    
    var loginPayco = false
    var loginFacebook = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        /* TextField색상 흰색으로 변경 */
        state.backgroundColor = NSColor.white
        pwField.backgroundColor = NSColor.white
        idField.backgroundColor = NSColor.white
    }
    
    func initLoginView() {
        tryLogin = false
        state.stringValue = ""
        idTextField.stringValue = ""
        pwTextField.stringValue = ""
        
        initLogin()
        
        webView.load(URLRequest(url: URL(string: "http://www.bugs.co.kr/")!))
    }
    
    func initLogin() {
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
        
        /* 뷰와 연동 */
        self.view.addSubview(webView)
        
        /* NMP페이지를 로드 */
        webView.load(URLRequest(url: URL(string: "http://www.bugs.co.kr/")!))
    }
    
    func deinitLogin() {
        deinitPayco()
        webView = nil
    }
    
    @IBAction func login(_ sender: AnyObject) {
        /* 벅스로 로그인키기 */
        webView.evaluateJavaScript("document.getElementById('to_bugs_login').click()", completionHandler: nil)
        
        /* 항상 로그인 값 활성화 */
        webView.evaluateJavaScript("document.getElementById('longLoginYn').click()", completionHandler: nil)
        webView.evaluateJavaScript("document.getElementById('longLoginYn').click()", completionHandler: nil)
        
        id = String(idTextField.stringValue)
        pw = String(pwTextField.stringValue)
        
        state.stringValue = "로그인을 시도합니다."
        
        /* id 와 pw 입력 */
        webView.evaluateJavaScript("document.getElementById('user_id').value = '\(id as String)'", completionHandler: nil)
        webView.evaluateJavaScript("document.getElementById('passwd').value = '\(pw as String)'", completionHandler: nil)
        
        /* alwaysLoginButton이 눌려있으면 항상 로그인 적용 */
        if Int(alwaysLoginButton.intValue) == 1 && !isAlwaysLoginOn() {
            webView.evaluateJavaScript("document.getElementById('longLoginYn').click()", completionHandler: nil)
        }
        else if Int(alwaysLoginButton.intValue) == 0 && isAlwaysLoginOn() {
            webView.evaluateJavaScript("document.getElementById('longLoginYn').click()", completionHandler: nil)
        }
        
        
        /* 로그인 시도 */
        tryLogin = true
        
        /* 로그인 양식 제출 */
        webView.evaluateJavaScript("document.getElementsByClassName('submit')[0].click()", completionHandler: nil)
        
    }
    
    func initPayco() {
        //print("initPayco")
        popupWindow = NSWindow(contentRect: NSMakeRect(10, NSScreen.main()!.visibleFrame.size.height-95, 630, 560),
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
        configuration.processPool = webPlayer.processPool
        
        /* 새로운 WKWebView를 만든다. */
        popupView = WKWebView(frame: popupWindow.contentLayoutRect, configuration: configuration)
        
        popupView.navigationDelegate = self
        popupView.uiDelegate = self
        
        /* 새창을 만든다. */
        popupWindow.contentView = popupView
        
        popupController = NSWindowController(window: popupWindow)
        popupController.showWindow(self)
    }
    
    func deinitPayco() {
        popupController = nil
        popupView = nil
        popupWindow = nil
        
    }
    
    func initFacebook() {
        popupWindow = NSWindow(contentRect: NSMakeRect(10, NSScreen.main()!.visibleFrame.size.height-95, 500, 300),
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
        configuration.processPool = webPlayer.processPool
        
        /* 새로운 WKWebView를 만든다. */
        popupView = WKWebView(frame: popupWindow.contentLayoutRect, configuration: configuration)
        
        popupView.navigationDelegate = self
        popupView.uiDelegate = self
        
        /* 새창을 만든다. */
        popupWindow.contentView = popupView
        
        popupController = NSWindowController(window: popupWindow)
        popupController.showWindow(self)
    }
    
    func deinitFacebook() {
        popupController = nil
        popupView = nil
        popupWindow = nil
    }
    
    @IBAction func loginWithPAYCO(_ sender: AnyObject) {
        loginPayco = true
        /* alwaysLoginButton이 눌려있으면 항상 로그인 적용 */
        if Int(alwaysLoginButton.intValue) == 1 && !isAlwaysLoginOn() {
            webView.evaluateJavaScript("document.getElementById('longLoginYn').click()", completionHandler: nil)
        }
        else if Int(alwaysLoginButton.intValue) == 0 && isAlwaysLoginOn() {
            webView.evaluateJavaScript("document.getElementById('longLoginYn').click()", completionHandler: nil)
        }
        
        webView.evaluateJavaScript("document.getElementById('payco-auth-popup').click()", completionHandler: nil)
    }
    
    @IBAction func loginWithFacebook(_ sender: AnyObject) {
        loginFacebook = true
        /* alwaysLoginButton이 눌려있으면 항상 로그인 적용 */
        if Int(alwaysLoginButton.intValue) == 1 && !isAlwaysLoginOn() {
            webView.evaluateJavaScript("document.getElementById('longLoginYn').click()", completionHandler: nil)
        }
        else if Int(alwaysLoginButton.intValue) == 0 && isAlwaysLoginOn() {
            webView.evaluateJavaScript("document.getElementById('longLoginYn').click()", completionHandler: nil)
        }
        
        webView.evaluateJavaScript("document.getElementById('fb-auth-layer').click()", completionHandler: nil)
    }
    
    /* 팝업창이 뜰때의 delegate */
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            let url = navigationAction.request.url
            
            /* PAYCO로그인이 시도중일때 */
            if loginPayco {
                /* 새창을 만든다. */
                initPayco()
                
                popupView.load(URLRequest(url: url!))
            }
            else if loginFacebook {
                initFacebook()
                
                popupView.load(URLRequest(url: url!))
            }
        }
        return nil
    }
    
    var isFacebookLoginSucess = false
    var count = 0
    /* 창이 로드될때마다 호출되는 delegate */
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        webView.evaluateJavaScript("javascript:bugs.ui.showLoginLayerForHeader({caller:this});bugs.wiselog.area('M_header_03_05');", completionHandler: nil)
        /* 새로 고침된 창이 벅스 홈페이지라면 */
        if webView == self.webView {
            webView.evaluateJavaScript("document.getElementById('longLoginYn').click()", completionHandler: nil)
            webView.evaluateJavaScript("document.getElementById('longLoginYn').click()", completionHandler: nil)
            
            if tryLogin {
                if isLoginSucess() {
                    playerController.nowLogin = true
                    state.stringValue = "로그인 성공"
                    playerController.loginComplete()
                    sideListController.syncSideList()
                    deinitLogin()
                }
                else {
                    state.stringValue = "ID 또는 PW가 틀립니다."
                }
                tryLogin = false
            }

            else if loginFacebook {
                if isLoginSucess() {
                    playerController.nowLogin = true
                    popupController.close()
                    deinitFacebook()
                    state.stringValue = "로그인 성공"
                    loginFacebook = false
                    playerController.loginComplete()
                    sideListController.syncSideList()
                    deinitLogin()
                }
                else if count < 10 {
                    count += 1
                    self.webView.reload()
                }
            }
        }
        else if loginPayco {
            if popupLoginSucess() {
                playerController.nowLogin = true
                popupController.close()
                deinitPayco()
                state.stringValue = "로그인 성공"
                loginPayco = false
                playerController.loginComplete()
                sideListController.syncSideList()
                deinitLogin()
            }
        }
        else if loginFacebook {
            self.webView.reload()
        }
    }
    
    func isAlwaysLoginOn()->Bool {
        var isFinish = false
        var isLoginPage = false
        webView.evaluateJavaScript("document.getElementsByClassName('messagePersist msgPrivacy')[0].getAttribute('style')") { (result, error) in
            if error == nil {
                print(result as! String)
                if String(describing: result).range(of: "none") == nil {
                    isLoginPage = true
                }
            }
            isFinish = true
        }
        
        while (!isFinish) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        return isLoginPage
    }
    
    func isLoginSucess()->Bool {
        var isFinish = false
        var isLoginPage = false
        webView.evaluateJavaScript("document.getElementById('loginHeader').getElementsByTagName('a')[0].innerHTML") { (result, error) in
            if error == nil {
                if String(describing: result).range(of: "로그인 / 회원가입") == nil {
                    isLoginPage = true
                }
            }
            isFinish = true
        }
        
        while (!isFinish) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        return isLoginPage
    }
    
    func popupLoginSucess()->Bool {
        var isFinish = false
        var isLoginPage = false
        popupView.evaluateJavaScript("document.getElementById('loginHeader').getElementsByTagName('a')[0].innerHTML") { (result, error) in
            if error == nil {
                if String(describing: result).range(of: "로그인 / 회원가입") == nil {
                    isLoginPage = true
                }
            }
            isFinish = true
        }
        
        while (!isFinish) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        return isLoginPage
    }
}



