//
//  LoginWebViewController.swift
//  Music
//
//  Created by sykimy on 2016. 8. 2..
//  Copyright © 2016년 sykimy. All rights reserved.
//


import Cocoa
import WebKit

class LoginWebViewController: NSViewController, WKNavigationDelegate, WKUIDelegate {
    
    var popupWindow:NSWindow!
    var popupController:NSWindowController!
    
    var webView:WKWebView!
    
    @IBOutlet var loginView: NSView!
    
    @IBOutlet var webPlayer: WebPlayerController!
    
    @IBOutlet var sideListController: SideListController!
    @IBOutlet var mainWebViewController: MainWebViewController!
    
    
    
    @IBOutlet var playerController: PlayerController!
    
    
    var id, pw:String!
    var al:Int!
    
    var tryLogin = false
    
    var loginPayco = false
    var loginFacebook = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
  
    func deinitPopUp() {
        popupController = nil
        popupWindow = nil
    }
    
    func initLoginWebView(configuration: WKWebViewConfiguration, windowSize: NSRect)->WKWebView {
        popupWindow = NSWindow(contentRect: windowSize,
                               styleMask: [NSWindowStyleMask.closable, NSWindowStyleMask.titled],
                               backing: NSBackingStoreType.buffered, defer: true)
        
        /* 새로운 WKWebView를 만든다. */
        let popupView = WKWebView(frame: popupWindow.contentLayoutRect, configuration: configuration)
        
        popupView.uiDelegate = mainWebViewController
        
        /* 새창을 만든다. */
        popupWindow.contentView = popupView
        
        popupController = NSWindowController(window: popupWindow)
        popupController.showWindow(self)
        
        return popupView
    }
}

