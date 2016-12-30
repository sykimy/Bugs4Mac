//
//  PreferenceWallPaper.swift
//  Bugs
//
//  Created by sykimy on 2016. 9. 23..
//  Copyright © 2016년 sykimy. All rights reserved.
//

import Cocoa

class WallPaperPlayerPreference:NSObject {
    //let defaults = UserDefaults.standard
    
    @IBOutlet var defaults: UserDefaultsController!
    @IBOutlet var wallPaperPlayer: WallpaperPlayer!
    
    /* 환경설정 페널의 버튼들 */
    @IBOutlet var moveButton: NSButton!
    @IBOutlet var mainButton: NSButton!
    
    @IBOutlet var imageOnOffButton: NSButton!
    @IBOutlet var titleOnOffButton: NSButton!
    @IBOutlet var albumOnOffButton: NSButton!
    @IBOutlet var artistOnOffButton: NSButton!
    @IBOutlet var lyricOnOffButton: NSButton!
    
    @IBOutlet var titleBorderButton: NSColorWell!
    @IBOutlet var albumBorderButton: NSColorWell!
    @IBOutlet var artistBorderButton: NSColorWell!
    @IBOutlet var lyricBorderButton: NSColorWell!
    
    @IBOutlet var titleColorButton: NSColorWell!
    @IBOutlet var albumColorButton: NSColorWell!
    @IBOutlet var artistColorButton: NSColorWell!
    @IBOutlet var lyricColorButton: NSColorWell!
    
    @IBOutlet var autoTitleColorButton: NSButton!
    @IBOutlet var autoAlbumColorButton: NSButton!
    @IBOutlet var autoArtistColorButton: NSButton!
    @IBOutlet var autoLyricColorButton: NSButton!
    
    @IBOutlet var resetButton: NSButton!
    
    @IBOutlet var imageAlwaysTopButton: NSButton!
    @IBOutlet var titleAlwaysTopButton: NSButton!
    @IBOutlet var artistAlwaysTopButton: NSButton!
    @IBOutlet var albumAlwaysTopButton: NSButton!
    @IBOutlet var lyricAlwaysTopButton: NSButton!
    
    @IBOutlet var realTimeLyricButton: NSButton!
    @IBOutlet var oneLineLyricButton: NSButton!
    
    @IBOutlet var titleAlignmentButton: NSPopUpButton!
    @IBOutlet var artistAlignmentButton: NSPopUpButton!
    @IBOutlet var albumAlignmentButton: NSPopUpButton!
    @IBOutlet var lyricAlignmentButton: NSPopUpButton!
    
    var fontWindow = -1
    
    override func awakeFromNib() {
        mainButton.isEnabled = true
        getUserSetting()
    }
    
    /* 유저의 세팅을 가져온다. */
    func getUserSetting() {
        wallPaperPlayer.changeTitleTextColor(NSColor.black, border: NSColor.black)
        wallPaperPlayer.changeArtistTextColor(NSColor.black, border: NSColor.black)
        wallPaperPlayer.changeAlbumTextColor(NSColor.black, border: NSColor.black)
        wallPaperPlayer.changeLyricTextColor(NSColor.black, border: NSColor.black)
        
        /* 월페이퍼기능이 켜져있는지 체크 */
        getOnOffDefault()
        
        getColorDefault()
        
        /* 항상 위인지 체크 */
        getWindowTopDefault()
        
        getTextAlignmentDefault()
        
        getFontDefault()
        
        getRealTimeDefault()
        
        getOneLineDefault()
    }
    
    func getOnOffDefault() {
        if defaults.be(forKey: "wallPaperOnOff") {
            /* 바탕화면 보기가 켜져있으면 */
            if defaults.bool(forKey: "wallPaperOnOff") {
                mainButton.stringValue = "켜짐"
                setAllButtonsOn()
                /* 월페이퍼를 실행한다. */
                wallPaperPlayer.openAllState = true
                //openAll("" as AnyObject)
                /* 부분적으로 꺼져있는 설정은 꺼준다. */
                if defaults.bool(forKey: "imageState") {
                    wallPaperPlayer.openImageWindow()
                    imageOnOffButton.title = "켜짐"
                }
                else {
                    wallPaperPlayer.offImage()
                    imageOnOffButton.title = "꺼짐"
                }
                
                if defaults.bool(forKey: "titleState") {
                    wallPaperPlayer.onTitle()
                    titleOnOffButton.title = "켜짐"
                }
                else {
                    wallPaperPlayer.offTitle()
                    titleOnOffButton.title = "꺼짐"
                }
                
                if defaults.bool(forKey: "albumState") {
                    wallPaperPlayer.onAlbum()
                    albumOnOffButton.title = "켜짐"
                }
                else {
                    wallPaperPlayer.offAlbum()
                    albumOnOffButton.title = "꺼짐"
                }
                
                if defaults.bool(forKey: "artistState") {
                    wallPaperPlayer.onArtist()
                    artistOnOffButton.title = "켜짐"
                }
                else {
                    wallPaperPlayer.offArtist()
                    artistOnOffButton.title = "꺼짐"
                }
                
                if defaults.bool(forKey: "lyricState") {
                    wallPaperPlayer.onLyric()
                    lyricOnOffButton.title = "켜짐"
                }
                else {
                    wallPaperPlayer.offLyric()
                    lyricOnOffButton.title = "꺼짐"
                }
            }
            else {
                setAllButtonsOff()
                wallPaperPlayer.offWallpaper()
            }
        }
        else {
            setAllButtonsOff()
            wallPaperPlayer.offWallpaper()
        }
    }
    
    func getColorDefault() {
        /* 자동 색 기능이 켜져있는지 체크 */
        if defaults.bool(forKey: "autoTitleColor") {
            wallPaperPlayer.onTitleAutoTextColor()
            autoTitleColorButton.state = 1
        }
            /* 자동색이 꺼져있으면 색의 값을 받아온다. */
        else {
            titleColorButton.color = defaults.color(type: "title")
            titleBorderButton.color = defaults.color(type: "titleBorder")
            
            wallPaperPlayer.changeTitleTextColor(titleColorButton.color, border: titleBorderButton.color)
        }
        
        if defaults.bool(forKey: "autoArtistColor") {
            wallPaperPlayer.onArtistAutoTextColor()
            autoArtistColorButton.state = 1
        }
        else {
            artistColorButton.color = defaults.color(type: "artist")
            artistBorderButton.color = defaults.color(type: "artistBorder")
            
            wallPaperPlayer.changeArtistTextColor(artistColorButton.color, border: artistBorderButton.color)
        }
        
        if defaults.bool(forKey: "autoAlbumColor") {
            wallPaperPlayer.onAlbumAutoTextColor()
            autoAlbumColorButton.state = 1
        }
        else {
            albumColorButton.color = defaults.color(type: "album")
            albumBorderButton.color = defaults.color(type: "albumBorder")
            
            wallPaperPlayer.changeAlbumTextColor(albumColorButton.color, border: albumBorderButton.color)
        }
        
        if defaults.bool(forKey: "autoLyricColor") {
            wallPaperPlayer.onLyricAutoTextColor()
            autoLyricColorButton.state = 1
        }
        else {
            lyricColorButton.color = defaults.color(type: "lyric")
            lyricBorderButton.color = defaults.color(type: "lyricBorder")
            
            wallPaperPlayer.changeLyricTextColor(lyricColorButton.color, border: lyricBorderButton.color)
        }
    }
    
    func getWindowTopDefault() {
        if defaults.be(forKey: "imageTop") {
            if defaults.bool(forKey: "imageTop") {
                wallPaperPlayer.setImageWindowLevel(level: Int(CGWindowLevelForKey(.floatingWindow)))
                imageAlwaysTopButton.state = 1
            }
        }
        
        if defaults.be(forKey: "titleTop") {
            if defaults.bool(forKey: "titleTop") {
                wallPaperPlayer.setTitleWindowLevel(level: Int(CGWindowLevelForKey(.floatingWindow)))
                titleAlwaysTopButton.state = 1
            }
        }
        
        if defaults.be(forKey: "artistTop") {
            if defaults.bool(forKey: "artistTop") {
                wallPaperPlayer.setArtistWindowLevel(level: Int(CGWindowLevelForKey(.floatingWindow)))
                artistAlwaysTopButton.state = 1
            }
        }
        
        if defaults.be(forKey: "albumTop") {
            if defaults.bool(forKey: "albumTop") {
                wallPaperPlayer.setAlbumWindowLevel(level: Int(CGWindowLevelForKey(.floatingWindow)))
                albumAlwaysTopButton.state = 1
            }
        }
        
        if defaults.be(forKey: "lyricTop") {
            if defaults.bool(forKey: "lyricTop") {
                wallPaperPlayer.setLyricWindowLevel(level: Int(CGWindowLevelForKey(.floatingWindow)))
                lyricAlwaysTopButton.state = 1
            }
        }
    }
    
    func getTextAlignmentDefault() {
        defaults.set(true, forKey: "checkAlighnment")
        if defaults.be(forKey: "titleAlignment") {
            
            let alignment = defaults.defaults.object(forKey: "titleAlignment") as! Int
            wallPaperPlayer.changeTitleAlignment(alignment)
            
            titleAlignmentButton.selectItem(at: alignment+1)
        }
        else {
            wallPaperPlayer.changeTitleAlignment(-1)
        }
        
        if defaults.be(forKey: "artistAlignment") {
            let alignment = defaults.defaults.object(forKey: "artistAlignment") as! Int
            wallPaperPlayer.changeArtistAlignment(alignment)
            
            artistAlignmentButton.selectItem(at: alignment+1)
        }
        else {
            wallPaperPlayer.changeArtistAlignment(-1)
        }
        
        if defaults.be(forKey: "albumAlignment") {
            let alignment = defaults.defaults.object(forKey: "albumAlignment") as! Int
            wallPaperPlayer.changeAlbumAlignment(alignment)
            
            albumAlignmentButton.selectItem(at: alignment+1)
        }
        else {
            wallPaperPlayer.changeAlbumAlignment(-1)
        }
        
        if defaults.be(forKey: "lyricAlignment") {
            let alignment = defaults.defaults.object(forKey: "lyricAlignment") as! Int
            wallPaperPlayer.changeLyricAlignment(alignment)
            
            lyricAlignmentButton.selectItem(at: alignment+1)
        }
        else {
            wallPaperPlayer.changeLyricAlignment(-1)
        }
    }
    
    func getFontDefault() {
        defaults.set(true, forKey: "checkFont")
        if defaults.be(forKey: "titleFont") {
            let font = NSFont(name: defaults.defaults.object(forKey: "titleFont") as! String, size: CGFloat(defaults.defaults.float(forKey: "titleFontSize")))
            wallPaperPlayer.changeTitleTextFont(font: font!)
        }
        else {
            let font = NSFont.systemFont(ofSize: 36)
            wallPaperPlayer.changeTitleTextFont(font: font)
        }
        
        if defaults.be(forKey: "artistFont") {
            let font = NSFont(name: defaults.defaults.object(forKey: "artistFont") as! String, size: CGFloat(defaults.defaults.float(forKey: "artistFontSize")))
            wallPaperPlayer.changeArtistTextFont(font: font!)
        }
        else {
            let font = NSFont.systemFont(ofSize: 24)
            wallPaperPlayer.changeArtistTextFont(font: font)
        }
        
        if defaults.be(forKey: "albumFont") {
            let font = NSFont(name: defaults.defaults.object(forKey: "albumFont") as! String, size: CGFloat(defaults.defaults.float(forKey: "albumFontSize")))
            wallPaperPlayer.changeAlbumTextFont(font: font!)
        }
        else {
            let font = NSFont.systemFont(ofSize: 20)
            wallPaperPlayer.changeAlbumTextFont(font: font)
        }
        
        if defaults.be(forKey: "lyricFont") {
            let font = NSFont(name: defaults.defaults.object(forKey: "lyricFont") as! String, size: CGFloat(defaults.defaults.float(forKey: "lyricFontSize")))
            wallPaperPlayer.changeLyricTextFont(font: font!)
        }
    }
    
    func getRealTimeDefault() {
        defaults.set(true, forKey: "checkRealTime")
        if defaults.be(forKey: "realTime") {
            if defaults.bool(forKey: "realTime") {
                wallPaperPlayer.setRealTime(bool: true)
                realTimeLyricButton.state = 1
                oneLineLyricButton.isEnabled = false
            }
            else {
                wallPaperPlayer.setRealTime(bool: false)
                realTimeLyricButton.state = 0
            }
        }
        else {
            wallPaperPlayer.setRealTime(bool: false)
            realTimeLyricButton.state = 0
        }
    }
    
    func getOneLineDefault() {
        defaults.set(true, forKey: "checkOneLine")
        if defaults.be(forKey: "oneLine") {
            if defaults.bool(forKey: "oneLine") {
                wallPaperPlayer.setOneLine(bool: true)
                oneLineLyricButton.state = 1
                realTimeLyricButton.isEnabled = false
            }
            else {
                wallPaperPlayer.setOneLine(bool: false)
                oneLineLyricButton.state = 0
            }
        }
        else {
            wallPaperPlayer.setOneLine(bool: false)
            oneLineLyricButton.state = 0
        }
    }
    
    func getNowValue() {
        /* 현재의 색으로 색상바 변경 */
        if wallPaperPlayer.titleWindow != nil {
            titleColorButton.color = wallPaperPlayer.titleWindow.getInnerColor()
            titleBorderButton.color = wallPaperPlayer.titleWindow.getOuterColor()
        }
        if wallPaperPlayer.artistWindow != nil {
            artistColorButton.color = wallPaperPlayer.artistWindow.getInnerColor()
            artistBorderButton.color = wallPaperPlayer.artistWindow.getOuterColor()
            
        }
        if wallPaperPlayer.albumWindow != nil {
            albumColorButton.color = wallPaperPlayer.albumWindow.getInnerColor()
            albumBorderButton.color = wallPaperPlayer.albumWindow.getOuterColor()
            
        }
        if wallPaperPlayer.lyricWindow != nil {
            lyricColorButton.color = wallPaperPlayer.lyricWindow.getInnerColor()
            lyricBorderButton.color = wallPaperPlayer.lyricWindow.getOuterColor()
        }
    }
    
    /* 바탕화면에서 플레이어 보기 */
    func setAllButtonsOn() {
        moveButton.isEnabled = true
        imageOnOffButton.isEnabled = true
        titleOnOffButton.isEnabled = true
        albumOnOffButton.isEnabled = true
        artistOnOffButton.isEnabled = true
        lyricOnOffButton.isEnabled = true
        
        titleBorderButton.isEnabled = true
        albumBorderButton.isEnabled = true
        artistBorderButton.isEnabled = true
        lyricBorderButton.isEnabled = true
        
        titleColorButton.isEnabled = true
        albumColorButton.isEnabled = true
        artistColorButton.isEnabled = true
        lyricColorButton.isEnabled = true
        
        autoTitleColorButton.isEnabled = true
        autoAlbumColorButton.isEnabled = true
        autoArtistColorButton.isEnabled = true
        autoLyricColorButton.isEnabled = true
        
        mainButton.title = "켜짐"
        imageOnOffButton.title = "켜짐"
        titleOnOffButton.title = "켜짐"
        albumOnOffButton.title = "켜짐"
        artistOnOffButton.title = "켜짐"
        lyricOnOffButton.title = "켜짐"
        
    }
    
    func setAllButtonsOff() {
        moveButton.isEnabled = false
        imageOnOffButton.isEnabled = false
        titleOnOffButton.isEnabled = false
        albumOnOffButton.isEnabled = false
        artistOnOffButton.isEnabled = false
        lyricOnOffButton.isEnabled = false
        
        titleBorderButton.isEnabled = false
        albumBorderButton.isEnabled = false
        artistBorderButton.isEnabled = false
        lyricBorderButton.isEnabled = false
        
        titleColorButton.isEnabled = false
        albumColorButton.isEnabled = false
        artistColorButton.isEnabled = false
        lyricColorButton.isEnabled = false
        
        autoTitleColorButton.isEnabled = false
        autoAlbumColorButton.isEnabled = false
        autoArtistColorButton.isEnabled = false
        autoLyricColorButton.isEnabled = false
        
        mainButton.title = "꺼짐"
        imageOnOffButton.title = "꺼짐"
        titleOnOffButton.title = "꺼짐"
        albumOnOffButton.title = "꺼짐"
        artistOnOffButton.title = "꺼짐"
        lyricOnOffButton.title = "꺼짐"
    }
    
    /* 바탕화면에서 플레이어 보기 */
    @IBAction func openAll(_ sender: AnyObject) {
        if mainButton.title == "켜짐" {
            /* 모든 버튼 비활성화 */
            setAllButtonsOff()
            
            wallPaperPlayer.offWallpaper()
            
            defaults.set(false, forKey: "wallPaperOnOff")
            defaults.set(false, forKey: "imageState")
            defaults.set(false, forKey: "titleState")
            defaults.set(false, forKey: "artistState")
            defaults.set(false, forKey: "albumState")
            defaults.set(false, forKey: "lyricState")
        }
        else {
            setAllButtonsOn()
            
            wallPaperPlayer.onWallpaper()
            
            defaults.set(true, forKey: "wallPaperOnOff")
            defaults.set(true, forKey: "imageState")
            defaults.set(true, forKey: "titleState")
            defaults.set(true, forKey: "artistState")
            defaults.set(true, forKey: "albumState")
            defaults.set(true, forKey: "lyricState")
            
            /* 항상 위인지 체크 */
            if defaults.be(forKey: "imageTop") {
                if defaults.bool(forKey: "imageTop") {
                    wallPaperPlayer.setImageWindowLevel(level: Int(CGWindowLevelForKey(.floatingWindow)))
                    imageAlwaysTopButton.state = 1
                }
            }
            
            if defaults.be(forKey: "titleTop") {
                if defaults.bool(forKey: "titleTop") {
                    wallPaperPlayer.setTitleWindowLevel(level: Int(CGWindowLevelForKey(.floatingWindow)))
                    titleAlwaysTopButton.state = 1
                }
            }
            
            if defaults.be(forKey: "artistTop") {
                if defaults.bool(forKey: "artistTop") {
                    wallPaperPlayer.setArtistWindowLevel(level: Int(CGWindowLevelForKey(.floatingWindow)))
                    artistAlwaysTopButton.state = 1
                }
            }
            
            if defaults.be(forKey: "albumTop") {
                if defaults.bool(forKey: "albumTop") {
                    wallPaperPlayer.setAlbumWindowLevel(level: Int(CGWindowLevelForKey(.floatingWindow)))
                    albumAlwaysTopButton.state = 1
                }
            }
            
            if defaults.be(forKey: "lyricTop") {
                if defaults.bool(forKey: "lyricTop") {
                    wallPaperPlayer.setLyricWindowLevel(level: Int(CGWindowLevelForKey(.floatingWindow)))
                    lyricAlwaysTopButton.state = 1
                }
            }
            
        }
    }
    
    /* 앨범커버 켜기/끄기 */
    @IBAction func imageOnOff(_ sender: AnyObject) {
        if imageOnOffButton.title == "꺼짐" {
            wallPaperPlayer.openImageWindow()
            imageOnOffButton.title = "켜짐"
            defaults.set(true, forKey: "imageState")
        }
        else {
            print("off")
            wallPaperPlayer.offImage()
            imageOnOffButton.title = "꺼짐"
            
            defaults.set(false, forKey: "imageState")
            
        }
    }
    
    /* 노래제목 켜기/끄기 */
    @IBAction func titleOnOff(_ sender: AnyObject) {
        if titleOnOffButton.title == "꺼짐" {
            wallPaperPlayer.onTitle()
            titleOnOffButton.title = "켜짐"
            defaults.set(true, forKey: "titleState")
        }
        else {
            wallPaperPlayer.offTitle()
            titleOnOffButton.title = "꺼짐"
            defaults.set(false, forKey: "titleState")
            
        }
    }
    
    /* 앨범제목 켜기/끄기 */
    @IBAction func albumOnOff(_ sender: AnyObject) {
        if albumOnOffButton.title == "꺼짐" {
            wallPaperPlayer.onAlbum()
            albumOnOffButton.title = "켜짐"
            defaults.set(true, forKey: "albumState")
        }
        else {
            wallPaperPlayer.offAlbum()
            albumOnOffButton.title = "꺼짐"
            defaults.set(false, forKey: "albumState")
        }
    }
    
    /* 아티스트 켜기/끄기 */
    @IBAction func artistOnOff(_ sender: AnyObject) {
        if artistOnOffButton.title == "꺼짐" {
            wallPaperPlayer.onArtist()
            artistOnOffButton.title = "켜짐"
            defaults.set(true, forKey: "artistState")
        }
        else {
            wallPaperPlayer.offArtist()
            artistOnOffButton.title = "꺼짐"
            defaults.set(false, forKey: "artistState")
        }
    }
    
    /* 가사보기 켜기/끄기 */
    @IBAction func lyricOnOff(_ sender: AnyObject) {
        if lyricOnOffButton.title == "꺼짐" {
            wallPaperPlayer.onLyric()
            lyricOnOffButton.title = "켜짐"
            defaults.set(true, forKey: "lyricState")
        }
        else {
            wallPaperPlayer.offLyric()
            lyricOnOffButton.title = "꺼짐"
            defaults.set(false, forKey: "lyricState")
        }
    }
    
    /* 초기설정으로 되돌리기 버튼 */
    @IBAction func resetPreferences(_ sender: AnyObject) {
        /* 창크기및 위치 조정 */
        wallPaperPlayer.initWindowFrame()
        
        /* 색 조정 */
        wallPaperPlayer.initTextColor()
        
        /* 자동 글자 색상 설정(끔) */
        wallPaperPlayer.initAutoTextColor()
        defaults.set(false, forKey: "autoTitleColor")
        defaults.set(false, forKey: "autoArtistColor")
        defaults.set(false, forKey: "autoAlbumColor")
        defaults.set(false, forKey: "autoLyricColor")
    }
    
    /*.이동, 크기조정 활성화 */
    @IBAction func fixWindow(_ sender: AnyObject) {
        if moveButton.title == "꺼짐" {
            moveButton.title = "켜짐"
            wallPaperPlayer.unfixWindow()
            
        }
        else {
            moveButton.title = "꺼짐"
            wallPaperPlayer.fixWindow()
            
            if defaults.be(forKey: "imageTop") {
                if defaults.bool(forKey: "imageTop") {
                    wallPaperPlayer.setImageWindowLevel(level: Int(CGWindowLevelForKey(.floatingWindow)))
                    imageAlwaysTopButton.state = 1
                }
            }
            
            if defaults.be(forKey: "titleTop") {
                if defaults.bool(forKey: "titleTop") {
                    wallPaperPlayer.setTitleWindowLevel(level: Int(CGWindowLevelForKey(.floatingWindow)))
                    titleAlwaysTopButton.state = 1
                }
            }
            
            if defaults.be(forKey: "artistTop") {
                if defaults.bool(forKey: "artistTop") {
                    wallPaperPlayer.setArtistWindowLevel(level: Int(CGWindowLevelForKey(.floatingWindow)))
                    artistAlwaysTopButton.state = 1
                }
            }
            
            if defaults.be(forKey: "albumTop") {
                if defaults.bool(forKey: "albumTop") {
                    wallPaperPlayer.setAlbumWindowLevel(level: Int(CGWindowLevelForKey(.floatingWindow)))
                    albumAlwaysTopButton.state = 1
                }
            }
            
            if defaults.be(forKey: "lyricTop") {
                if defaults.bool(forKey: "lyricTop") {
                    wallPaperPlayer.setLyricWindowLevel(level: Int(CGWindowLevelForKey(.floatingWindow)))
                    lyricAlwaysTopButton.state = 1
                }
            }
            
        }
    }
}

/* 글자색을 변경하는 버튼 함수 모음 */
extension WallPaperPlayerPreference {
    @IBAction func getTitleColor(_ sender: AnyObject) {
        wallPaperPlayer.changeTitleTextColor(titleColorButton.color, border:titleBorderButton.color)
        
        defaults.setTextColor(type: "title", color:titleColorButton.color)
        defaults.setTextColor(type: "titleBorder", color:titleBorderButton.color)
    }
    
    @IBAction func getAlbumColor(_ sender: AnyObject) {
        wallPaperPlayer.changeAlbumTextColor(albumColorButton.color, border:albumBorderButton.color)
        
        defaults.setTextColor(type: "album", color:albumColorButton.color)
        defaults.setTextColor(type: "albumBorder", color:albumBorderButton.color)
    }
    
    @IBAction func getArtistBorderColor(_ sender: AnyObject) {
        wallPaperPlayer.changeArtistTextColor(artistColorButton.color, border:artistBorderButton.color)
        
        defaults.setTextColor(type: "artist", color:artistColorButton.color)
        defaults.setTextColor(type: "artistBorder", color:artistBorderButton.color)
    }
    
    @IBAction func getLyricBorderColor(_ sender: AnyObject) {
        wallPaperPlayer.changeLyricTextColor(lyricColorButton.color, border:lyricBorderButton.color)
        
        defaults.setTextColor(type: "lyric", color:lyricColorButton.color)
        defaults.setTextColor(type: "lyricBorder", color:lyricBorderButton.color)
    }
}

extension WallPaperPlayerPreference {
    @IBAction func titleColor(_ sender: AnyObject) {
        if autoTitleColorButton.state == 1 {
            wallPaperPlayer.onTitleAutoTextColor()
            defaults.set(true, forKey: "autoTitleColor")
        }
        else {
            wallPaperPlayer.offTitleAutoTextColor()
            defaults.set(false, forKey: "autoTitleColor")
        }
    }
    
    @IBAction func albumColor(_ sender: AnyObject) {
        if autoAlbumColorButton.state == 1 {
            wallPaperPlayer.onAlbumAutoTextColor()
            defaults.set(true, forKey: "autoAlbumColor")
        }
        else {
            wallPaperPlayer.offAlbumAutoTextColor()
            defaults.set(false, forKey: "autoAlbumColor")
        }
    }
    
    @IBAction func artistColor(_ sender: AnyObject) {
        if autoArtistColorButton.state == 1 {
            wallPaperPlayer.onArtistAutoTextColor()
            defaults.set(true, forKey: "autoArtistColor")
        }
        else {
            wallPaperPlayer.offArtistAutoTextColor()
            defaults.set(false, forKey: "autoArtistColor")
        }
    }
    
    @IBAction func lyricColor(_ sender: AnyObject) {
        if autoLyricColorButton.state == 1 {
            wallPaperPlayer.onLyricAutoTextColor()
            defaults.set(true, forKey: "autoLyricColor")
        }
        else {
            wallPaperPlayer.offLyricAutoTextColor()
            defaults.set(false, forKey: "autoLyricColor")
        }
    }
    
    @IBAction func imageAlwaysTop(_ sender: AnyObject) {
        if imageAlwaysTopButton.state == 1 {
            wallPaperPlayer.setImageWindowLevel(level: Int(CGWindowLevelForKey(.floatingWindow)))
            defaults.set(true, forKey: "imageTop")
        }
        else {
            wallPaperPlayer.setImageWindowLevel(level: Int(CGWindowLevelForKey(.desktopWindow)))
            defaults.set(false, forKey: "imageTop")
        }
    }
    
    @IBAction func titleAlwaysTop(_ sender: AnyObject) {
        if titleAlwaysTopButton.state == 1 {
            wallPaperPlayer.setTitleWindowLevel(level: Int(CGWindowLevelForKey(.floatingWindow)))
            defaults.set(true, forKey: "titleTop")
        }
        else {
            wallPaperPlayer.setTitleWindowLevel(level: Int(CGWindowLevelForKey(.desktopWindow)))
            defaults.set(false, forKey: "titleTop")
        }
    }
    
    @IBAction func artistAlwaysTop(_ sender: AnyObject) {
        if artistAlwaysTopButton.state == 1 {
            wallPaperPlayer.setArtistWindowLevel(level: Int(CGWindowLevelForKey(.floatingWindow)))
            defaults.set(true, forKey: "artistTop")
        }
        else {
            wallPaperPlayer.setArtistWindowLevel(level: Int(CGWindowLevelForKey(.desktopWindow)))
            defaults.set(false, forKey: "artistTop")
        }
    }
    
    @IBAction func albumAlwaysTop(_ sender: AnyObject) {
        if albumAlwaysTopButton.state == 1 {
            wallPaperPlayer.setAlbumWindowLevel(level: Int(CGWindowLevelForKey(.floatingWindow)))
            defaults.set(true, forKey: "albumTop")
        }
        else {
            wallPaperPlayer.setAlbumWindowLevel(level: Int(CGWindowLevelForKey(.desktopWindow)))
            defaults.set(false, forKey: "albumTop")
        }
    }
    
    @IBAction func lyricAlwaysTop(_ sender: AnyObject) {
        if lyricAlwaysTopButton.state == 1 {
            wallPaperPlayer.setLyricWindowLevel(level: Int(CGWindowLevelForKey(.floatingWindow)))
            defaults.set(true, forKey: "lyricTop")
        }
        else {
            wallPaperPlayer.setLyricWindowLevel(level: Int(CGWindowLevelForKey(.desktopWindow)))
            defaults.set(false, forKey: "lyricTop")
        }
    }
    
    @IBAction func titlFont(_ sender: AnyObject) {
        let fontManager = NSFontManager()
        fontManager.target = self
        fontManager.orderFrontFontPanel(self)
        
        fontWindow = 0
    }
    
    @IBAction func artistFont(_ sender: AnyObject) {
        let fontManager = NSFontManager()
        fontManager.target = self
        fontManager.orderFrontFontPanel(self)
        
        fontWindow = 1
    }
    
    @IBAction func albumFont(_ sender: AnyObject) {
        let fontManager = NSFontManager()
        fontManager.target = self
        fontManager.orderFrontFontPanel(self)
        
        fontWindow = 2
    }
    
    @IBAction func lyricFont(_ sender: AnyObject) {
        let fontManager = NSFontManager()
        fontManager.target = self
        fontManager.orderFrontFontPanel(self)
        
        fontWindow = 3
    }
    
    override func changeFont(_ sender: Any?) {
        let fontManager = sender as! NSFontManager
        let oldFont = NSFont.systemFont(ofSize: 10)
        let newFont = fontManager.convert(oldFont)
        if fontWindow == 0 {
            wallPaperPlayer.changeTitleTextFont(font: newFont)
            defaults.defaults.set(newFont.fontName, forKey: "titleFont")
            defaults.defaults.set(newFont.pointSize, forKey: "titleFontSize")
        }
        else if fontWindow == 1 {
            wallPaperPlayer.changeArtistTextFont(font: newFont)
            defaults.defaults.set(newFont.fontName, forKey: "artistFont")
            defaults.defaults.set(newFont.pointSize, forKey: "artistFontSize")
        }
        else if fontWindow == 2 {
            wallPaperPlayer.changeAlbumTextFont(font: newFont)
            defaults.defaults.set(newFont.fontName, forKey: "albumFont")
            defaults.defaults.set(newFont.pointSize, forKey: "albumFontSize")
        }
        else if fontWindow == 3 {
            wallPaperPlayer.changeLyricTextFont(font: newFont)
            defaults.defaults.set(newFont.fontName, forKey: "lyricFont")
            defaults.defaults.set(newFont.pointSize, forKey: "lyricFontSize")
        }
    }
    
    @IBAction func realTimeLyric(_ sneder:AnyObject) {
        if realTimeLyricButton.state == 1 {
            wallPaperPlayer.setRealTime(bool: true)
            defaults.set(true, forKey: "realTime")
            oneLineLyricButton.isEnabled = false
        }
        else {
            wallPaperPlayer.setRealTime(bool: false)
            defaults.set(false, forKey: "realTime")
            oneLineLyricButton.isEnabled = true
        }
    }
    
    @IBAction func oneLineLyric(_ sneder:AnyObject) {
        if oneLineLyricButton.state == 1 {
            wallPaperPlayer.setOneLine(bool: true)
            defaults.set(true, forKey: "oneLine")
            realTimeLyricButton.isEnabled = false
        }
        else {
            wallPaperPlayer.setOneLine(bool: false)
            defaults.set(false, forKey: "oneLine")
            realTimeLyricButton.isEnabled = true
        }
    }
    
    @IBAction func titleAlignment(_ sneder:AnyObject) {
        if titleAlignmentButton.selectedItem?.title == "좌로정렬" {
            wallPaperPlayer.changeTitleAlignment(-1)
            defaults.set(alignment: -1, forKey: "titleAlignment")
        }
        else if titleAlignmentButton.selectedItem?.title == "우로정렬" {
            wallPaperPlayer.changeTitleAlignment(1)
            defaults.set(alignment: 1, forKey: "titleAlignment")
        }
        else {
            wallPaperPlayer.changeTitleAlignment(0)
            defaults.set(alignment: 0, forKey: "titleAlignment")
        }
    }
    
    @IBAction func artistAlignment(_ sneder:AnyObject) {
        if artistAlignmentButton.selectedItem?.title == "좌로정렬" {
            wallPaperPlayer.changeArtistAlignment(-1)
            defaults.set(alignment: -1, forKey: "artistAlignment")
        }
        else if artistAlignmentButton.selectedItem?.title == "우로정렬" {
            wallPaperPlayer.changeArtistAlignment(1)
            defaults.set(alignment: 1, forKey: "artistAlignment")
        }
        else {
            wallPaperPlayer.changeArtistAlignment(0)
            defaults.set(alignment: 0, forKey: "artistAlignment")
        }
    }
    
    @IBAction func albumAlignment(_ sneder:AnyObject) {
        if albumAlignmentButton.selectedItem?.title == "좌로정렬" {
            wallPaperPlayer.changeAlbumAlignment(-1)
            defaults.set(alignment: -1, forKey: "albumAlignment")
        }
        else if albumAlignmentButton.selectedItem?.title == "우로정렬" {
            wallPaperPlayer.changeAlbumAlignment(1)
            defaults.set(alignment: 1, forKey: "albumAlignment")
        }
        else {
            wallPaperPlayer.changeAlbumAlignment(0)
            defaults.set(alignment: 0, forKey: "albumAlignment")
        }
    }
    
    @IBAction func lyricAlignment(_ sneder:AnyObject) {
        if lyricAlignmentButton.selectedItem?.title == "좌로정렬" {
            wallPaperPlayer.changeLyricAlignment(-1)
            defaults.set(alignment: -1, forKey: "lyricAlignment")
        }
        else if lyricAlignmentButton.selectedItem?.title == "우로정렬" {
            wallPaperPlayer.changeLyricAlignment(1)
            defaults.set(alignment: 1, forKey: "lyricAlignment")
        }
        else {
            wallPaperPlayer.changeLyricAlignment(0)
            defaults.set(alignment: 0, forKey: "lyricAlignment")
        }
    }
}
