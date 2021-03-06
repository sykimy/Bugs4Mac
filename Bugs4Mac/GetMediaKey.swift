//
//  GetMediaKey.swift
//  Music
//
//  Created by sykimy on 2016. 8. 2..
//  Copyright © 2016년 sykimy. All rights reserved.
//

import Cocoa
import Carbon
import MediaPlayer

/* 미디어 키를 받아오는 함수 */
@available(OSX 10.12.2, *)
class GetMediaKey: NSApplication {
    let nc = NotificationCenter.default
    
    let rcc: MPRemoteCommandCenter! = MPRemoteCommandCenter.shared()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        rcc.pauseCommand.addTarget(self, action: #selector(play))
        rcc.stopCommand.addTarget(self, action: #selector(play))
        rcc.playCommand.addTarget(self, action: #selector(play))
        rcc.togglePlayPauseCommand.addTarget(self, action: #selector(play))
    }
    
    override func sendEvent(_ event: NSEvent) {
        if (event.type == .systemDefined && event.subtype.rawValue == 8) {
            let keyCode = ((event.data1 & 0xFFFF0000) >> 16)
            let keyFlags = (event.data1 & 0x0000FFFF)
            // Get the key state. 0xA is KeyDown, OxB is KeyUp
            let keyState = (((keyFlags & 0xFF00) >> 8)) == 0xA
            let keyRepeat = (keyFlags & 0x1)
            mediaKeyEvent(Int32(keyCode), state: keyState, keyRepeat: Bool(keyRepeat > 0))
        }
        
        super.sendEvent(event)
    }
    
    func play() {
        //print("play");
    }
    
    func mediaKeyEvent(_ key: Int32, state: Bool, keyRepeat: Bool) {
        // Only send events on KeyDown. Without this check, these events will happen twice
        if (state) {
            switch(key) {
            case NX_KEYTYPE_PLAY:
                nc.post(name: Notification.Name(rawValue: "play"), object: self)
                break
            case NX_KEYTYPE_FAST:
                nc.post(name: Notification.Name(rawValue: "next"), object: self)
                break
            case NX_KEYTYPE_REWIND:
                nc.post(name: Notification.Name(rawValue: "prev"), object: self)
                break
            case NX_KEYTYPE_NEXT:
                nc.post(name: Notification.Name(rawValue: "next"), object: self)
                break
            case NX_KEYTYPE_PREVIOUS:
                nc.post(name: Notification.Name(rawValue: "prev"), object: self)
                break
            default:
                break
            }
        }
    }
}

