//
//  NowPlatingListPreference.swift
//  Bugs
//
//  Created by sykimy on 2017. 2. 26..
//  Copyright © 2016년 sykimy. All rights reserved.
//

import Cocoa

class NowPlayingListPreference:NSObject {
    
    @IBOutlet var removeDuplicateSongButton: NSButton!
    @IBOutlet var addTopButton: NSButton!
    @IBOutlet var addBottomButton: NSButton!
    @IBOutlet var addNextButton: NSButton!
    
    
    let defaults = UserDefaults.standard
    
    @IBOutlet var nowPlayingList:NowPlayingListController!
    
    override func awakeFromNib() {
        getUserSetting()
    }
    
    func getUserSetting() {
        if defaults.object(forKey: "removeDuplicateSong") != nil {
            if defaults.bool(forKey: "removeDuplicateSong") {
                removeDuplicateSongButton.state = 1
                nowPlayingList.deleteDuplicateSong = true
            }
            else {
                removeDuplicateSongButton.state = 0
                nowPlayingList.deleteDuplicateSong = false
            }
        }
        else {
            removeDuplicateSongButton.state = 1
            nowPlayingList.deleteDuplicateSong = true
        }
        
        if defaults.object(forKey: "addPosition") != nil {
            if defaults.integer(forKey: "addPosition") == 0 {
                addTopButton.state = 1
                addBottomButton.state = 0
                addNextButton.state = 0
                nowPlayingList.addPosition = 0
            }
            else if defaults.integer(forKey: "addPosition") == 1 {
                addTopButton.state = 0
                addBottomButton.state = 1
                addNextButton.state = 0
                nowPlayingList.addPosition = 1
            }
            else {
                addTopButton.state = 0
                addBottomButton.state = 0
                addNextButton.state = 1
                nowPlayingList.addPosition = 2
            }
        }
        else {
            addTopButton.state = 0
            addBottomButton.state = 0
            addNextButton.state = 1
            nowPlayingList.addPosition = 2
        }
    }
    
    @IBAction func removeDuplicateSong(_ sender: AnyObject) {
        if removeDuplicateSongButton.state == 1 {
            nowPlayingList.deleteDuplicateSong = true
            defaults.set(true, forKey: "removeDuplicateSong")
        }
        else {
            nowPlayingList.deleteDuplicateSong = false
            defaults.set(false, forKey: "removeDuplicateSong")
        }
    }
    
    @IBAction func addTop(_ sender: AnyObject) {
        if addTopButton.state == 1 {
            nowPlayingList.addPosition = 0
            defaults.set(0, forKey: "addPosition")
            addTopButton.isEnabled = false
            addBottomButton.isEnabled = true
            addNextButton.isEnabled = true
        }
    }
    
    @IBAction func addBottom(_ sender: Any) {
        if addTopButton.state == 1 {
            nowPlayingList.addPosition = 1
            defaults.set(1, forKey: "addPosition")
            addTopButton.isEnabled = true
            addBottomButton.isEnabled = false
            addNextButton.isEnabled = true
        }
    }

    
    @IBAction func addNext(_ sender: Any) {
        if addTopButton.state == 1 {
            nowPlayingList.addPosition = 2
            defaults.set(2, forKey: "addPosition")
            addTopButton.isEnabled = true
            addBottomButton.isEnabled = true
            addNextButton.isEnabled = false
        }
    }
}
