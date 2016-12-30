//
//  WallPaperPlayer.swift
//  Music
//
//  Created by sykimy on 2016. 8. 2..
//  Copyright © 2016년 sykimy. All rights reserved.
//

import Cocoa
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


class WallpaperPlayer:NSObject {
    /* 월페이퍼에 쓰일 창들 */
    /* 각자 위치를 변경 할 수 있게끔 따로따로 생성한다. */
    /*
     let lyricWindow = NSWindow(contentRect: NSMakeRect(115, NSScreen.main()!.visibleFrame.size.height-53, 1000, 30),
     styleMask: NSWindowStyleMask.borderless,
     backing: NSBackingStoreType.buffered, defer: true)*/
    
    @IBOutlet var preference: WallPaperPlayerPreference!
    
    
    var titleWindow:WallpaperText! = nil
    var artistWindow:WallpaperText! = nil
    var albumWindow:WallpaperText! = nil
    var imageWindow:WallpaperImage! = nil
    
    var lyricWindow:WallpaperLyric! = nil
    
    /* 이미지 컨트로러 */
    var lyricController:NSWindowController!
    
    /* 가사를 불러올 타이머 (가사의 경우 웹플레이어에서 곡의 변경과 함께 즉각적으로 업데이트 되지 않기 때문에 타이머를 이용하였다. */
    var lyricTimer:Timer!
    
    //let defaults = UserDefaults.standard
    
    @IBOutlet var defaults: UserDefaultsController!
    
    let nc = NotificationCenter.default
    
    @IBOutlet var webPlayer: WebPlayerController!
    
    @IBOutlet var radio: RadioController!
    /* 자동 글자색 여부 저장 변수 */
    var autoTitleColor = false
    var autoArtistColor = false
    var autoAlbumColor = false
    var autoLyricColor = false
    
    /* 글자색 저장 변수 */
    var titleColor = NSColor.black
    var titleBorderColor = NSColor.black
    var albumColor = NSColor.black
    var albumBorderColor = NSColor.black
    var artistColor = NSColor.black
    var artistBorderColor = NSColor.black
    var lyricColor = NSColor.black
    var lyricBorderColor = NSColor.black
    
    /* 정렬 변수 */
    var titleAlignment = -1
    var albumAlignment = -1
    var artistAlignment = -1
    var lyricAlignment = -1
    
    /* 앨범이미지 뷰 */
    var imageView:NSImageView!
    
    /* 각종 정보의 텍스트필드 */
    var lyricLabel = NSTextField()
    
    /* 가사의 스크롤 뷰 */
    var lyricScrollView = NSScrollView()
    
    /* 각 정보의 글자크기 저장 변수 */
    var pointOfLyric:CGFloat = 15
    
    /* 각 창의 ON/OFF여부 저장 변수 */
    var openAllState = false
    var imageState = false
    var titleState = false
    var albumState = false
    var artistState = false
    var lyricState = false
    
    var isRadio = false
    
    private var realTime = false
    private var oneLine = false
    
    /* 설정창 뷰 */
    @IBOutlet var preferencesView: NSView!
    
    //  내부 색상을 반영한다. (색상에따라 약간 어둡게 만들거나 밝게 만든다.)
    func getInnerColor(_ color:NSColor)->NSColor {
        var innerColor:NSColor!
        
        if color.redComponent + color.blueComponent + color.greenComponent > 1.0 {
            innerColor = color.blended(withFraction: 0.1, of: NSColor.black)
        }
        else {
            innerColor = color.blended(withFraction: 0.1, of: NSColor.white)
        }
        
        return innerColor
    }
    
    //  외부 색상을 반영한다. (지금은 위와 같다.)
    func getOuterColor(_ color:NSColor)->NSColor {
        var outerColor:NSColor!
        
        if color.redComponent + color.blueComponent + color.greenComponent > 1.0 {
            outerColor = color.blended(withFraction: 0.1, of: NSColor.black)
        }
        else {
            outerColor = color.blended(withFraction: 0.1, of: NSColor.white)
        }
        
        return outerColor
    }
    
    //  실시간 가사 표시 여부 설정
    func setRealTime(bool:Bool) {
        realTime = bool
    }
    
    //  한줄 표시 여부 설정
    func setOneLine(bool:Bool) {
        oneLine = bool
    }
    
    //  타이틀, 아티스트, 앨범, 이미지, 가사, 색상을 조정한다.
    func set(title:String, artist:String, album:String, image:NSImage, lyric:Lyrics, color:NSColor) {
        /* 바탕화면 보기가 켜져있으면 실행 */
        if openAllState {
            /* 이미지윈도우가 켜져있으면 실행 */
            if imageWindow != nil {
                imageWindow.set(image: image)
            }
            
            /* 타이틀윈도우가 켜져있으면 실행 */
            if titleWindow != nil {
                /* 자동 색상이 켜져있으면 색상을 동기화한다. */
                if autoTitleColor { syncColor(window: titleWindow, color: color) }
                
                /* 곡 정보를 입력한다. */
                titleWindow.setText(string: title)
            }
            
            /* 아티스트윈도우가 켜져있으면 실행 */
            if artistWindow != nil {
                /* 자동 색상이 켜져있으면 색상을 동기화한다. */
                if autoArtistColor { syncColor(window: artistWindow, color: color) }
                
                /* 곡 정보를 입력한다. */
                artistWindow.setText(string: artist)
            }
            
            /* 아티스트윈도우가 켜져있으면 실행 */
            if albumWindow != nil {
                /* 자동 색상이 켜져있으면 색상을 동기화한다. */
                if autoAlbumColor {
                    syncColor(window: albumWindow, color: color)
                }
                
                /* 곡 정보를 입력한다. */
                albumWindow.setText(string: album)
            }
            
            /* 아티스트윈도우가 켜져있으면 실행 */
            if lyricWindow != nil {
                /* 자동 색상이 켜져있으면 색상을 동기화한다. */
                if autoLyricColor {
                    lyricWindow.setInnerColor(color: getInnerColor(color))
                    lyricWindow.setOuterColor(color: getOuterColor(color))
                }
                
                /* 곡 정보를 입력한다. */
                lyricWindow.setText(lyric: lyric)
                
                if oneLine {
                    lyricWindow.refreshOneLine(numOflyric: 0)
                }
                else {
                    lyricWindow.refresh(numOflyric: 0)
                }
                
            }
        }
    }
    
    func refreshLyric(_ i:Int) {
        if lyricWindow != nil {
            if realTime {
                if !lyricWindow.isEmpty() {
                    lyricWindow.refresh(numOflyric: i)
                }
            }
            else if oneLine {
                if !lyricWindow.isEmpty() {
                    lyricWindow.refreshOneLine(numOflyric: i)
                }
            }
        }
    }
    
    func syncColor(window:WallpaperText, color:NSColor) {
        let innerColor = getInnerColor(color)
        let outerColor = getOuterColor(color)
        
        window.setInnerColor(color: innerColor)
        window.setOuterColor(color: outerColor)
    }
    
    func setImageWindowLevel(level:Int) {
        if imageWindow != nil {
            imageWindow.setLevel(level: level)
        }
    }
    
    func setTitleWindowLevel(level:Int) {
        if titleWindow != nil {
            titleWindow.setLevel(level: level)
        }
    }
    
    func setArtistWindowLevel(level:Int) {
        if artistWindow != nil {
            artistWindow.setLevel(level: level)
        }
    }
    
    func setAlbumWindowLevel(level:Int) {
        if albumWindow != nil {
            albumWindow.setLevel(level: level)
        }
    }
    
    func setLyricWindowLevel(level:Int) {
        if lyricWindow != nil {
            lyricWindow.setLevel(level: level)
        }
    }
    
    func offWallpaper() {
        openAllState = false
        if titleWindow != nil {
            offTitle()
        }
        if artistWindow != nil {
            offArtist()
        }
        if albumWindow != nil {
            offAlbum()
        }
        if imageWindow != nil {
            offImage()
        }
        if lyricWindow != nil {
            offLyric()
        }
    }
    
    func onWallpaper() {
        openAllState = true
        
        openImageWindow()
        openTitleWindow()
        openAlbumWindow()
        openArtistWindow()
        openLyricWindow()
    }
}

/* 각 창을 키고 끄는 버튼 함수 모음 */
extension WallpaperPlayer {
    func offImage() {
        imageWindow = nil
    }
    
    func onTitle() {
        openTitleWindow()
    }
    
    func offTitle() {
        titleWindow = nil
    }
    
    func onAlbum() {
        openAlbumWindow()
    }
    
    func offAlbum() {
        albumWindow = nil
    }
    
    func onArtist() {
        openArtistWindow()
    }
    
    func offArtist() {
        artistWindow = nil
    }
    
    func onLyric() {
        openLyricWindow()
    }
    
    func offLyric() {
        lyricWindow = nil
    }
}

/* 글자색을 변경하는 버튼 함수 모음 */
extension WallpaperPlayer {
    /* 텍스트 색상 설정 */
    func initTextColor() {
        if titleWindow != nil {
            titleWindow.setInnerColor(color: NSColor.black)
            titleWindow.setOuterColor(color: NSColor.black)
        }
        
        if artistWindow != nil {
            artistWindow.setInnerColor(color: NSColor.black)
            artistWindow.setOuterColor(color: NSColor.black)
        }
        
        if albumWindow != nil {
            albumWindow.setInnerColor(color: NSColor.black)
            albumWindow.setOuterColor(color: NSColor.black)
        }
        
        if lyricWindow != nil {
            changeLyricTextColor(NSColor.gray, border: NSColor.gray)
        }
    }
    
    func changeTitleTextColor(_ inside:NSColor, border:NSColor) {
        if titleWindow == nil {
            return
        }
        else {
            titleWindow.setInnerColor(color: inside)
            titleWindow.setOuterColor(color: border)
        }
    }
    
    func changeArtistTextColor(_ inside:NSColor, border:NSColor) {
        if artistWindow == nil {
            return
        }
        else {
            artistWindow.setInnerColor(color: inside)
            artistWindow.setOuterColor(color: border)
        }
    }
    
    func changeAlbumTextColor(_ inside:NSColor, border:NSColor) {
        if albumWindow == nil {
            return
        }
        else {
            albumWindow.setInnerColor(color: inside)
            albumWindow.setOuterColor(color: border)
        }
    }
    
    func changeLyricTextColor(_ inside:NSColor, border:NSColor) {
        if lyricWindow == nil {
            return
        }
        else {
            lyricWindow.setInnerColor(color: inside)
            lyricWindow.setOuterColor(color: border)
        }
    }
    
    func changeTitleTextFont(font:NSFont) {
        if titleWindow == nil {
            return
        }
        
        titleWindow.setFont(font: font)
        if titleWindow.string == nil { return }
        titleWindow.setText(string: titleWindow.string)
    }
    
    func changeArtistTextFont(font:NSFont) {
        if artistWindow == nil { return }
        artistWindow.setFont(font: font)
        if artistWindow.string == nil { return }
        artistWindow.setText(string: artistWindow.string)
    }
    
    func changeAlbumTextFont(font:NSFont) {
        if albumWindow == nil { return }
        albumWindow.setFont(font: font)
        if albumWindow.string == nil { return }
        albumWindow.setText(string: albumWindow.string)
    }
    
    func changeLyricTextFont(font:NSFont) {
        if lyricWindow == nil { return }
        lyricWindow.setFont(font: font)
    }
    
    func changeTitleAlignment(_ alignment:Int) {
        if titleWindow == nil {
            return
        }
        
        titleWindow.setAlignment(alignment)
        if titleWindow.string == nil { return }
        titleWindow.setText(string: titleWindow.string)
    }
    
    func changeArtistAlignment(_ alignment:Int) {
        if artistWindow == nil {
            return
        }
        
        artistWindow.setAlignment(alignment)
        if artistWindow.string == nil { return }
        artistWindow.setText(string: artistWindow.string)
    }
    
    func changeAlbumAlignment(_ alignment:Int) {
        if albumWindow == nil {
            return
        }
        
        albumWindow.setAlignment(alignment)
        if albumWindow.string == nil { return }
        albumWindow.setText(string: albumWindow.string)
    }
    
    func changeLyricAlignment(_ alignment:Int) {
        if lyricWindow == nil { return }
        lyricWindow.setAlignment(alignment)
    }
}

/* 처음 윈도우를 생성하는 함수 모음 */
extension WallpaperPlayer {
    func openImageWindow() {
        if imageWindow == nil {
            let frame = defaults.frame(type: "image")
            if frame != NSRect.null {
                imageWindow = WallpaperImage(rect: frame)
            }
            else {
                imageWindow = WallpaperImage(rect: NSMakeRect(7, NSScreen.main()!.visibleFrame.size.height-30, 103, 103))
            }
        }
    }
    
    func openTitleWindow() {
        if titleWindow == nil {
            let frame = defaults.frame(type: "title")
            if frame != NSRect.null {
                titleWindow = WallpaperText(rect: frame)
            }
            else {
                titleWindow = WallpaperText(rect: NSMakeRect(115, NSScreen.main()!.visibleFrame.size.height+30, 1000, 50))
            }
            
            titleWindow.setInnerColor(color: preference.titleColorButton.color)
            titleWindow.setOuterColor(color: preference.titleBorderButton.color)
            
            let font = NSFont.systemFont(ofSize: 36)
            changeTitleTextFont(font: font)
        }
    }
    
    func openArtistWindow() {
        if artistWindow == nil {
            let frame = defaults.frame(type: "artist")
            if frame != NSRect.null {
                artistWindow = WallpaperText(rect: frame)
            }
            else {
                artistWindow = WallpaperText(rect: NSMakeRect(116, NSScreen.main()!.visibleFrame.size.height+3, 1000, 30))
            }
        }
        
        artistWindow.setInnerColor(color: preference.artistColorButton.color)
        artistWindow.setOuterColor(color: preference.artistBorderButton.color)
        
        let font = NSFont.systemFont(ofSize: 24)
        changeArtistTextFont(font: font)
    }
    
    func openAlbumWindow() {
        if albumWindow == nil {
            let frame = defaults.frame(type: "album")
            if frame != NSRect.null {
                albumWindow = WallpaperText(rect: frame)
            }
            else {
                albumWindow = WallpaperText(rect: NSMakeRect(116, NSScreen.main()!.visibleFrame.size.height-27, 1000, 25))
            }
        }
        
        albumWindow.setInnerColor(color: preference.albumColorButton.color)
        albumWindow.setOuterColor(color: preference.albumBorderButton.color)
        
        let font = NSFont.systemFont(ofSize: 20)
        changeAlbumTextFont(font: font)
    }
    
    func openLyricWindow() {
        if lyricWindow == nil {
            let frame = defaults.frame(type: "lyric")
            if frame != NSRect.null {
                lyricWindow = WallpaperLyric(rect: frame)
            }
            else {
                lyricWindow = WallpaperLyric(rect: NSMakeRect(7, NSScreen.main()!.visibleFrame.size.height-545, 500, 500))
            }
            
            lyricWindow.setInnerColor(color: preference.lyricColorButton.color)
            lyricWindow.setOuterColor(color: preference.lyricBorderButton.color)
        }
    }
}

/* 설정 관련 함수 모음 */
extension WallpaperPlayer {
    /* AutoColor 여부 설정 */
    func initAutoTextColor() {
        offTitleAutoTextColor()
        offArtistAutoTextColor()
        offAlbumAutoTextColor()
        offLyricAutoTextColor()
        
        
    }
    
    func onTitleAutoTextColor() {
        autoTitleColor = true
    }
    
    func offTitleAutoTextColor() {
        autoTitleColor = false
    }
    
    func onArtistAutoTextColor() {
        autoArtistColor = true
    }
    
    func offArtistAutoTextColor() {
        autoArtistColor = false
    }
    
    func onAlbumAutoTextColor() {
        autoAlbumColor = true
    }
    
    func offAlbumAutoTextColor() {
        autoAlbumColor = false
    }
    
    func onLyricAutoTextColor() {
        autoLyricColor = true
    }
    
    func offLyricAutoTextColor() {
        autoLyricColor = false
    }
    
    /* 윈도우 프레임을 기본 설정으로 초기화 */
    func initWindowFrame() {
        /* 타이틀 윈도우가 존재하면 크기를 조정한다. */
        if titleWindow != nil {
            titleWindow.setFrame(rect: NSMakeRect(NSScreen.main()!.visibleFrame.size.width/2, NSScreen.main()!.visibleFrame.size.height/2-50, 1000, 50))
            defaults.set(rect: titleWindow.frame(), type: "title")
        }
        if artistWindow != nil {
            artistWindow.setFrame(rect: NSMakeRect(NSScreen.main()!.visibleFrame.size.width/2, NSScreen.main()!.visibleFrame.size.height/2-80, 1000, 30))
            defaults.set(rect: artistWindow.frame(), type: "artist")
        }
        if albumWindow != nil {
            albumWindow.setFrame(rect: NSMakeRect(NSScreen.main()!.visibleFrame.size.width/2, NSScreen.main()!.visibleFrame.size.height/2-103, 1000, 25))
            defaults.set(rect: albumWindow.frame(), type: "album")
        }
        if imageWindow != nil {
            imageWindow = WallpaperImage(rect: NSMakeRect(NSScreen.main()!.visibleFrame.size.width/2-103, NSScreen.main()!.visibleFrame.size.height/2-103, 103, 103))
            defaults.set(rect: imageWindow.frame(), type: "image")
        }
        if lyricWindow != nil {
            lyricWindow = WallpaperLyric(rect: NSMakeRect(NSScreen.main()!.visibleFrame.size.width/2, NSScreen.main()!.visibleFrame.size.height/2, 500, 500))
            defaults.set(rect: lyricWindow.frame(), type: "lyric")
        }
    }
    
    func fixWindow() {
        if imageWindow != nil {
            imageWindow.fix()
            defaults.set(rect: imageWindow.frame(), type: "image")
            imageWindow.setLevel(level: Int(CGWindowLevelForKey(.desktopWindow)))
        }
        
        if titleWindow != nil {
            titleWindow.fix()
            defaults.set(rect: titleWindow.frame(), type: "title")
            titleWindow.setLevel(level: Int(CGWindowLevelForKey(.desktopWindow)))
        }
        
        if artistWindow != nil {
            artistWindow.fix()
            defaults.set(rect: artistWindow.frame(), type: "artist")
            artistWindow.setLevel(level: Int(CGWindowLevelForKey(.desktopWindow)))
        }
        
        if albumWindow != nil {
            albumWindow.fix()
            defaults.set(rect: albumWindow.frame(), type: "album")
            albumWindow.setLevel(level: Int(CGWindowLevelForKey(.desktopWindow)))
        }
        
        if lyricWindow != nil {
            lyricWindow.fix()
            defaults.set(rect: lyricWindow.frame(), type: "lyric")
            lyricWindow.setLevel(level: Int(CGWindowLevelForKey(.desktopWindow)))
        }
    }
    
    func unfixWindow() {
        
        if imageWindow != nil {
            imageWindow.unfix()
            imageWindow.setLevel(level: Int(CGWindowLevelForKey(.normalWindow)))
        }
        if titleWindow != nil {
            titleWindow.unfix()
            titleWindow.setLevel(level: Int(CGWindowLevelForKey(.normalWindow)))
        }
        if artistWindow != nil {
            artistWindow.unfix()
            artistWindow.setLevel(level: Int(CGWindowLevelForKey(.normalWindow)))
        }
        if albumWindow != nil {
            albumWindow.unfix()
            albumWindow.setLevel(level: Int(CGWindowLevelForKey(.normalWindow)))
        }
        if lyricWindow != nil {
            lyricWindow.unfix()
            lyricWindow.setLevel(level: Int(CGWindowLevelForKey(.normalWindow)))
        }
    }
}
