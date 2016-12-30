//
//  RadioController.swift
//  Bugs
//
//  Created by sykimy on 2016. 9. 29..
//  Copyright © 2016년 sykimy. All rights reserved.
//

import Cocoa
import WebKit

/* WKWebView Delegate 함수 모음 */
class RadioController: NSObject, WKNavigationDelegate, WKUIDelegate {

    
    var radioWindow:NSWindow!
    var radio:WKWebView!
    
    @IBOutlet var webPlayer: WebPlayerController!
    @IBOutlet var wallpaper: WallpaperPlayer!
    @IBOutlet var playerController: PlayerController!
    
    func initRadio() {
        
        radioWindow = NSWindow(contentRect: NSMakeRect(10, NSScreen.main()!.visibleFrame.size.height-95, 370, 615),
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
        radio = WKWebView(frame: radioWindow.contentLayoutRect, configuration: configuration)
        //radio = WKWebView(frame: paycoWindow.contentLayoutRect, configuration: configuration)
        
        radio.navigationDelegate = self
        radio.uiDelegate = self
        
        /* 새창을 만든다. */
        radioWindow.contentView = radio
        
        injectSimulateFunc()
    }
    
    /* 곡의 재생여부를 Bool로 반환한다. for Bugs */
    func checkPlay()->Bool {
        var isFinish = false
        var isPlay = false
        radio.evaluateJavaScript("document.getElementsByClassName('btnPlay')[0].getElementsByTagName('button')[0].innerHTML") { (result, error) in
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
    
    func load(_ url:URL) {
        radio.load(URLRequest(url: url))
    }
    
    func deinitRadio() {
        radio = nil
        radioWindow = nil
        wallpaper.isRadio = false
    }
    
    func getTitle()->String {
        let str = injectScript("document.getElementsByClassName('title')[0].getElementsByTagName('span')[0].getAttribute('title')") as! NSString
        let tmp = str.replacingOccurrences(of: "&amp;", with: "&")
        return tmp.replacingOccurrences(of: "&nbsp;", with: " ")
    }
    
    func getArtist()->String {
        let str = injectScript("document.getElementsByClassName('artist')[0].getElementsByTagName('a')[0].getAttribute('title')") as! NSString
        let tmp = str.replacingOccurrences(of: "&amp;", with: "&")
        return tmp.replacingOccurrences(of: "&nbsp;", with: " ")
    }
    
    /* 곡의 가사를 String으로 반환한다. for Bugs */
    func getLyrics()->Lyrics {
        radio.evaluateJavaScript("bugs.radio.showLyrics();", completionHandler: nil)
        
        var str:String = ""
        var isFinish = false
        let lyrics = Lyrics()
        
        radio.evaluateJavaScript("document.getElementById('scrollLyrics').innerHTML") { (result, error) in
            if error == nil {
                str = result as! String
            }
            isFinish = true
        }
        
        while (!isFinish) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        var front = str.startIndex
        
        let tmp = str.replacingOccurrences(of: "&amp;", with: "&")
        let lyric = tmp.replacingOccurrences(of: "&nbsp;", with: " ")
        
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
    
    func getNumOfNowPlayingLyric()->Int {
        radio.evaluateJavaScript("bugs.radio.showLyrics();", completionHandler: nil)
        
        var str:String = ""
        var isFinish = false
        
        radio.evaluateJavaScript("document.getElementById('scrollLyrics').innerHTML") { (result, error) in
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
    
    func getLyricsNow()->String {
        var str:NSString = ""
        var isFinish = false
        radio.evaluateJavaScript("bugs.radio.showLyrics();", completionHandler: nil)
        
        radio.evaluateJavaScript("document.getElementById('scrollLyrics').getElementsByTagName('strong')[0].innerHTML") { (result, error) in
            if error == nil {
                str = result as! NSString
            }
            isFinish = true
        }
        
        while (!isFinish) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        let lyric = str.replacingOccurrences(of: "&amp;", with: "&")
        
        return lyric
    }
    
    func beLyrics()-> Bool {
        var isFinish = false
        var state = true
        radio.evaluateJavaScript("document.getElementsByClassName('lyricsNone')[0].getAttribute('style')") { (result, error) in
            if error == nil {
                if String(describing: result).range(of: "block") != nil {
                    state = false
                }
            }
            isFinish = true
        }
        
        while (!isFinish) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        return state
    }
    
    func getAlbumImageURL()->URL {
        return URL(string: injectScript("document.getElementsByClassName('radioPlayer')[0].getElementsByClassName('thumbnail')[0].getElementsByTagName('img')[0].src") as! String)!
    }
    
    func getVolume()->Int {
        var isFinish = false
        var volume = 0
        
        radio.evaluateJavaScript("document.getElementsByClassName('volume on')[0].getElementsByClassName('bar')[0].getAttribute('style')") { (result, error) in
            if error == nil {
                if !(result is NSNull) {
                    var str = result as! String
                    if str != "width:0px;" {
                        str.removeSubrange(str.startIndex ..< str.characters.index(str.startIndex, offsetBy: 7))
                        str.removeSubrange(str.characters.index(str.endIndex, offsetBy: -3) ..< str.endIndex)
                        volume = Int(Double(str)!)
                    }
                }
            }
            isFinish = true
        }
        
        while (!isFinish) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
        }
        
        return volume
    }
    
    /* WKWebView에 스크립트를 입력하고, string값을 리턴한다. */
    func injectScript(_ script:String)->AnyObject {
        /* 값을 받아올때까지 false를 유지하는 변수 */
        var isFinish = false
        
        /* 반환할 값을 저장할 변수 */
        var str:String! = nil
        
        /* 웹뷰에 script를 입력한다. */
        radio.evaluateJavaScript(script) { (result, error) in
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
    
    func play() {
        radio.evaluateJavaScript("document.getElementsByClassName('btnPlay play')[0].getElementsByTagName('button')[0].click()", completionHandler: nil)
    }
    
    func pause() {
        radio.evaluateJavaScript("document.getElementsByClassName('btnPlay stop')[0].getElementsByTagName('button')[0].click()", completionHandler: nil)
    }
    
    func next() {
        radio.evaluateJavaScript("document.getElementsByClassName('btnNext')[0].getElementsByTagName('button')[0].click()", completionHandler: nil)
    }
    
    func like() {
        radio.evaluateJavaScript("document.getElementsByClassName('btnLike')[0].getElementsByTagName('button')[0].click()", completionHandler: nil)
    }
    
    func unlike() {
        radio.evaluateJavaScript("document.getElementsByClassName('btnHate')[0].getElementsByTagName('button')[0].click()", completionHandler: nil)
    }
    
    func volume(_ volume:Int) {
        //100~156
        radio.evaluateJavaScript("simulate(document.getElementsByClassName('volume on')[0].getElementsByClassName('btnSlider')[0], 'click', {pointerX: \(volume), pointerY: 136 })", completionHandler: nil)
        
    }
    
    /* simulate함수를 inject한다. */
    func injectSimulateFunc() {
        radio.evaluateJavaScript("function simulate(element, eventName) { var options = extend(defaultOptions, arguments[2] || {}); var oEvent, eventType = null; for (var name in eventMatchers) { if (eventMatchers[name].test(eventName)) { eventType = name; break; } } if (!eventType) throw new SyntaxError('Only HTMLEvents and MouseEvents interfaces are supported'); if (document.createEvent) { oEvent = document.createEvent(eventType); if (eventType == 'HTMLEvents') { oEvent.initEvent(eventName, options.bubbles, options.cancelable); } else { oEvent.initMouseEvent(eventName, options.bubbles, options.cancelable, document.defaultView, options.button, options.pointerX, options.pointerY, options.pointerX, options.pointerY, options.ctrlKey, options.altKey, options.shiftKey, options.metaKey, options.button, element); } element.dispatchEvent(oEvent); } else { options.clientX = options.pointerX; options.clientY = options.pointerY; var evt = document.createEventObject(); oEvent = extend(evt, options); element.fireEvent('on' + eventName, oEvent); } return element; } function extend(destination, source) { for (var property in source) destination[property] = source[property]; return destination; } ", completionHandler: nil)
        radio.evaluateJavaScript("var eventMatchers = { 'HTMLEvents': /^(?:load|unload|abort|error|select|change|submit|reset|focus|blur|resize|scroll)$/, 'MouseEvents': /^(?:click|dblclick|mouse(?:down|up|over|move|out))$/ }", completionHandler: nil)
        radio.evaluateJavaScript("var defaultOptions = { pointerX: 0, pointerY: 0, button: 0, ctrlKey: false, altKey: false, shiftKey: false, metaKey: false, bubbles: true, cancelable: true }", completionHandler: nil)
    }
    
    /* 페이지 로드가 끝나면 호출하는 함수 */
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        playerController.startRadio()
        wallpaper.isRadio = true
    }
}
