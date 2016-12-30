//
//  mvPlayer.swift
//  Bugs
//
//  Created by sykimy on 2016. 10. 3..
//  Copyright © 2016년 sykimy. All rights reserved.
//

import Cocoa
import WebKit

/* WKWebView Delegate 함수 모음 */
class MoviePlayerController: NSObject, WKNavigationDelegate, WKUIDelegate, NSWindowDelegate {
    @IBOutlet var webPlayer:WebPlayerController!
    
    var mvWindow:NSWindow!
    var webView:WKWebView!
    
    func initMoviePlayer() {
        
        mvWindow = NSWindow(contentRect: NSMakeRect(10, NSScreen.main()!.visibleFrame.size.height-95, 970, 670),
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
        configuration.processPool = webPlayer!.processPool
        
        /* 새로운 WKWebView를 만든다. */
        webView = WKWebView(frame: mvWindow.contentLayoutRect, configuration: configuration)
        
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        /* 새창을 만든다. */
        mvWindow.contentView = webView
        mvWindow.delegate = self
        
        let Controller = NSWindowController(window: mvWindow)
        
        Controller.showWindow(self)
        
    }
    
    func windowWillClose(_ notification: Notification) {
        webView = nil
        mvWindow = nil
    }
    
    func load(_ url:URL) {
        webView.load(URLRequest(url: url))
    }
    
    func deinitMoviePlayer() {
        webView = nil
        mvWindow = nil
    }
}
