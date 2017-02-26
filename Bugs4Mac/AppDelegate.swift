//
//  AppDelegate.swift
//  Music
//
//  Created by sykimy on 2016. 8. 2..
//  Copyright © 2016년 sykimy. All rights reserved.
//

import Cocoa
import NotificationCenter
import AVFoundation
import MediaPlayer
import IOKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
    
    @IBOutlet var window: NSWindow!     //주 윈도우
    @IBOutlet var icon: NSImageView!    //about 벅스의 icon

    
    //메인 플레이어 컨트롤러
    @IBOutlet var player: PlayerController!
    
    //프로그램 실행 시 펑션키의 아이튠즈로의 현결을 해제하기 위해 task를 생성.
    let startTask = Process()
    let endTask = Process()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setWindow() //윈도우의 상태(창모양, 버튼유무 등)를 설정한다.
        
        /* 시작시 펑션키의 아이튠즈로의 연결을 해제한다. */
        startTask.arguments = ["launchctl", "unload", "-w", "/System/Library/LaunchAgents/com.apple.rcd.plist"]
        startTask.launchPath = "/usr/bin/env"
        startTask.launch()
        
        /* 알림센터의 배너를 뜨게끔 delegate를 설정해준다. */
        NSUserNotificationCenter.default.delegate = self
        
        /* about bugs의 아이콘을 설정한다. */
        icon.image = NSImage(named: "load.png")

    }
    
    func setWindow() {
        self.window.titleVisibility = NSWindowTitleVisibility.hidden    //타이틀바를 숨긴다.
        self.window.titlebarAppearsTransparent = true   //타이틀바를 숨긴다.
        self.window.styleMask = [NSWindowStyleMask.fullSizeContentView, NSWindowStyleMask.titled, NSWindowStyleMask.closable, NSWindowStyleMask.resizable, NSWindowStyleMask.miniaturizable]    //스타일을 설정한다.
        /* 종료, 최대, 최소 버튼을 숨긴다. */
        self.window.standardWindowButton(NSWindowButton.closeButton)!.isHidden = true
        self.window.standardWindowButton(NSWindowButton.zoomButton)!.isHidden = true
        self.window.standardWindowButton(NSWindowButton.miniaturizeButton)!.isHidden = true
    }
    
    //독에서 숨기기를 했을때, taskBar의 아이콘으로부터 창을 여는 버튼의 함수
    @IBAction func reopen(_ sender: AnyObject) {
        self.window.makeKeyAndOrderFront(self)  //창을 연다.
    }
    
    /* 윈도우를 닫는 함수. */
    func close() {
        self.window.close()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        /* 종료시 펑션키를 다시 아이튠즈로 연결한다. */
        endTask.arguments = ["launchctl", "load", "-w", "/System/Library/LaunchAgents/com.apple.rcd.plist"]
        endTask.launchPath = "/usr/bin/env"
        endTask.launch()
    }
    
    /* 아이콘의 클릭으로 창을 다시 불러온다. */
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        /* 독 아이콘의 클릭으로 창을 다시 불러온다. */
        self.window.makeKeyAndOrderFront(self)
        
        return true
    }
    
}

