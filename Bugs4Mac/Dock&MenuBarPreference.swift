//
//  PreferenceDockAndMenuBar.swift
//  Bugs
//
//  Created by sykimy on 2016. 9. 25..
//  Copyright © 2016년 sykimy. All rights reserved.
//

import Cocoa
import AppKit

class DockAndMenuBarPreference:NSObject {
    @IBOutlet var atDockButton: NSButton!
    @IBOutlet var atMenuBarButton: NSButton!
    
    @IBOutlet var cover2DockIconButton: NSButton!
    @IBOutlet var icon2MenuBarButton: NSButton!
    @IBOutlet var cover2MenuBarButton: NSButton!
    @IBOutlet var title2MenuBarButton: NSButton!
    @IBOutlet var titleArtist2MenuBarButton: NSButton!
    @IBOutlet var titleArtistAlbum2MenuBarButton: NSButton!
    @IBOutlet var lyric2MenuBarButton: NSButton!
    
    @IBOutlet var playerController: PlayerController!
    
    let defaults = UserDefaults.standard
    
    override func awakeFromNib() {
        
        if atDockButton.title == "꺼짐" {
            atMenuBarButton.isEnabled = false
        }
        if atMenuBarButton.title == "꺼짐" {
            atDockButton.isEnabled = false
            menuBarButtonOff()
        }
        
        if !defaults.bool(forKey: "DockAndMenuBarInit") {
            defaults.set(true, forKey: "DockAndMenuBarInit")
        }
        else {
            getUserSetting()
        }
    }
    
    func getUserSetting() {
        if defaults.object(forKey: "atDock") != nil {
            if defaults.bool(forKey: "atDock") {
                atDockButton.title = "켜짐"
                atMenuBarButton.isEnabled = true
                NSApp.setActivationPolicy(.regular)
                cover2DockIconButton.isEnabled = true
            }
            else {
                atDockButton.title = "꺼짐"
                atMenuBarButton.isEnabled = false
                NSApp.dockTile.showsApplicationBadge = false
                NSApp.setActivationPolicy(.accessory)
                cover2DockIconButton.isEnabled = false
            }
        }
        else {
            atDockButton.title = "켜짐"
            atMenuBarButton.isEnabled = true
            NSApp.setActivationPolicy(.regular)
            cover2DockIconButton.isEnabled = true
        }
        
        if defaults.object(forKey: "cover2DockIcon") != nil {
            if defaults.bool(forKey: "cover2DockIcon") {
                cover2DockIconButton.state = 1
                playerController.cover2Icon = true
            }
            else {
                cover2DockIconButton.state = 0
                playerController.cover2Icon = false
            }
        }
        else {
            cover2DockIconButton.state = 1
            playerController.cover2Icon = true
        }
        
        if defaults.object(forKey: "atMenuBar") != nil {
            if defaults.bool(forKey: "atMenuBar") {
                atMenuBarButton.title = "켜짐"
                atDockButton.isEnabled = true
                playerController.menuBar = true
                menuBarButtonOn()
            }
            else {
                atMenuBarButton.title = "꺼짐"
                atDockButton.isEnabled = false
                playerController.menuBar = false
                menuBarButtonOff()
            }
        }
        else {
            atMenuBarButton.title = "꺼짐"
            atDockButton.isEnabled = false
            playerController.menuBar = false
            menuBarButtonOff()
        }
        
        if defaults.bool(forKey: "icon2MenuBar") {
            icon2MenuBarButton.state = 1
            cover2MenuBarButton.state = 0
            
            playerController.menuBarImageOption = 0
        }
        else if defaults.bool(forKey: "cover2MenuBar") {
            icon2MenuBarButton.state = 0
            cover2MenuBarButton.state = 1
            
            playerController.menuBarImageOption = 1
        }
        else {
            cover2MenuBarButton.state = 0
            playerController.menuBarImageOption = -1
        }
        
        if defaults.bool(forKey: "title2MenuBar") {
            title2MenuBarButton.state = 1
            titleArtist2MenuBarButton.state = 0
            titleArtistAlbum2MenuBarButton.state = 0
            lyric2MenuBarButton.state = 0
            
            playerController.menuBarOption = 0
        }
        else if defaults.bool(forKey: "titleArtist2MenuBar") {
            title2MenuBarButton.state = 0
            titleArtist2MenuBarButton.state = 1
            titleArtistAlbum2MenuBarButton.state = 0
            lyric2MenuBarButton.state = 0
            
            playerController.menuBarOption = 1
        }
        else if defaults.bool(forKey: "titleArtistAlbum2MenuBar") {
            title2MenuBarButton.state = 0
            titleArtist2MenuBarButton.state = 0
            titleArtistAlbum2MenuBarButton.state = 1
            lyric2MenuBarButton.state = 0
            
            playerController.menuBarOption = 2
        }
        else if defaults.bool(forKey: "lyric2MenuBar") {
            title2MenuBarButton.state = 0
            titleArtist2MenuBarButton.state = 0
            titleArtistAlbum2MenuBarButton.state = 0
            lyric2MenuBarButton.state = 1
            
            playerController.menuBarOption = 3
        }
        else {
            playerController.menuBarOption = -1
        }
    }
    
    @IBAction func atDock(_ sender: AnyObject) {
        if atDockButton.title == "꺼짐" {
            atDockButton.title = "켜짐"
            atMenuBarButton.isEnabled = true
            defaults.set(true, forKey: "atDock")
            NSApp.setActivationPolicy(.regular)
            NSMenu.setMenuBarVisible(false)
            NSMenu.setMenuBarVisible(true)
            cover2DockIconButton.isEnabled = true
        }
        else {
            atDockButton.title = "꺼짐"
            atMenuBarButton.isEnabled = false
            defaults.set(false, forKey: "atDock")
            NSApp.setActivationPolicy(.accessory)
            playerController.offDock()
            cover2DockIconButton.isEnabled = false
        }
    }
    
    @IBAction func cover2DockIcon(_ sender: AnyObject) {
        if cover2DockIconButton.state == 1 {
            playerController.cover2Icon = true
            defaults.set(true, forKey: "cover2DockIcon")
        }
        else {
            playerController.cover2Icon = false
            defaults.set(false, forKey: "cover2DockIcon")
        }
    }
    
    @IBAction func atMenuBar(_ sender: AnyObject) {
        if atMenuBarButton.title == "꺼짐" {
            atMenuBarButton.title = "켜짐"
            atDockButton.isEnabled = true
            playerController.menuBar = true
            menuBarButtonOn()
            defaults.set(true, forKey: "atMenuBar")
        }
        else {
            atMenuBarButton.title = "꺼짐"
            atDockButton.isEnabled = false
            playerController.menuBar = false
            menuBarButtonOff()
            defaults.set(false, forKey: "atMenuBar")
        }
    }
    
    func menuBarButtonOn() {
        icon2MenuBarButton.isEnabled = true
        cover2MenuBarButton.isEnabled = true
        title2MenuBarButton.isEnabled = true
        titleArtist2MenuBarButton.isEnabled = true
        titleArtistAlbum2MenuBarButton.isEnabled = true
        lyric2MenuBarButton.isEnabled = true
        
        playerController.showMenuBar()
    }
    
    func menuBarButtonOff() {
        icon2MenuBarButton.isEnabled = false
        cover2MenuBarButton.isEnabled = false
        title2MenuBarButton.isEnabled = false
        titleArtist2MenuBarButton.isEnabled = false
        titleArtistAlbum2MenuBarButton.isEnabled = false
        lyric2MenuBarButton.isEnabled = false
        
        playerController.hideMenuBar()
    }
    
    @IBAction func icon2MenuBar(_ sender: AnyObject) {
        if icon2MenuBarButton.state == 1 {
            cover2MenuBarButton.state = 0
            
            playerController.menuBarImageOption = 0
            
            defaults.set(true, forKey: "icon2MenuBar")
            defaults.set(false, forKey: "cover2MenuBar")
        }
        else {
            playerController.menuBarImageOption = -1
            defaults.set(false, forKey: "icon2MenuBar")
        }
    }
    
    @IBAction func cover2MenuBar(_ sender: AnyObject) {
        if cover2MenuBarButton.state == 1 {
            icon2MenuBarButton.state = 0
            
            playerController.menuBarImageOption = 1
            
            defaults.set(false, forKey: "icon2MenuBar")
            defaults.set(true, forKey: "cover2MenuBar")
        }
        else {
            playerController.menuBarImageOption = -1
            defaults.set(false, forKey: "cover2MenuBar")
        }
    }
    
    @IBAction func title2MenuBar(_ sender: AnyObject) {
        if title2MenuBarButton.state == 1 {
            titleArtist2MenuBarButton.state = 0
            titleArtistAlbum2MenuBarButton.state = 0
            lyric2MenuBarButton.state = 0
            
            playerController.menuBarOption = 0
            
            defaults.set(true, forKey: "title2MenuBar")
            defaults.set(false, forKey: "titleArtist2MenuBar")
            defaults.set(false, forKey: "titleArtistAlbum2MenuBar")
            defaults.set(false, forKey: "lyric2MenuBar")
        }
        else {
            playerController.menuBarOption = -1
            defaults.set(false, forKey: "title2MenuBar")
        }
    }
    
    @IBAction func titleArtist2MenuBar(_ sender: AnyObject) {
        if titleArtist2MenuBarButton.state == 1 {
            title2MenuBarButton.state = 0
            titleArtistAlbum2MenuBarButton.state = 0
            lyric2MenuBarButton.state = 0
            
            playerController.menuBarOption = 1
            
            defaults.set(false, forKey: "title2MenuBar")
            defaults.set(true, forKey: "titleArtist2MenuBar")
            defaults.set(false, forKey: "titleArtistAlbum2MenuBar")
            defaults.set(false, forKey: "lyric2MenuBar")
        }
        else {
            playerController.menuBarOption = -1
            defaults.set(false, forKey: "titleArtist2MenuBar")
        }
    }
    
    @IBAction func titleArtistAlbum2MenuBar(_ sender: AnyObject) {
        if titleArtistAlbum2MenuBarButton.state == 1 {
            title2MenuBarButton.state = 0
            titleArtist2MenuBarButton.state = 0
            lyric2MenuBarButton.state = 0
            
            playerController.menuBarOption = 2
            
            defaults.set(false, forKey: "title2MenuBar")
            defaults.set(false, forKey: "titleArtist2MenuBar")
            defaults.set(true, forKey: "titleArtistAlbum2MenuBar")
            defaults.set(false, forKey: "lyric2MenuBar")
        }
        else {
            playerController.menuBarOption = -1
            defaults.set(false, forKey: "titleArtistAlbum2MenuBar")
        }
    }
    
    @IBAction func lyric2MenuBar(_ sender: AnyObject) {
        if lyric2MenuBarButton.state == 1 {
            title2MenuBarButton.state = 0
            titleArtist2MenuBarButton.state = 0
            titleArtistAlbum2MenuBarButton.state = 0
            
            playerController.menuBarOption = 3
            
            defaults.set(false, forKey: "title2MenuBar")
            defaults.set(false, forKey: "titleArtist2MenuBar")
            defaults.set(false, forKey: "titleArtistAlbum2MenuBar")
            defaults.set(true, forKey: "lyric2MenuBar")
        }
        else {
            playerController.menuBarOption = -1
            defaults.set(false, forKey: "lyric2MenuBar")
        }
    }
    
    
}
