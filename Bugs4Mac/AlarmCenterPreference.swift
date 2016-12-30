//
//  PreferenceAlarmCenter.swift
//  Bugs
//
//  Created by sykimy on 2016. 9. 25..
//  Copyright © 2016년 sykimy. All rights reserved.
//

import Cocoa

class AlarmCenterPreference:NSObject {
    @IBOutlet var notificationButton: NSButton!
    @IBOutlet var funcKeyButton: NSButton!
    
    let defaults = UserDefaults.standard
    
    @IBOutlet var playerController: PlayerController!
    
    override func awakeFromNib() {
        if !defaults.bool(forKey: "notificationInit") {
            defaults.set(true, forKey: "notificationInit")
        }
        else {
            getUserSetting()
        }
    }
    
    func getUserSetting() {
        if defaults.object(forKey: "notification") != nil {
            if defaults.bool(forKey: "notification") {
                notificationButton.state = 1
                playerController.alarmCenter = true
            }
            else {
                notificationButton.state = 0
                playerController.alarmCenter = false
            }
        }
        else {
            notificationButton.state = 1
            playerController.alarmCenter = true
        }
        
        if defaults.object(forKey: "funcKey") != nil {
            if defaults.bool(forKey: "funcKey") {
                funcKeyButton.state = 1
                playerController.funcKey = true
            }
            else {
                funcKeyButton.state = 0
                playerController.funcKey = false
            }
        }
    }
    
    @IBAction func notification(_ sender: AnyObject) {
        if notificationButton.state == 1 {
            playerController.alarmCenter = true
            defaults.set(true, forKey: "notification")
        }
        else {
            playerController.alarmCenter = false
            defaults.set(false, forKey: "notification")
        }
    }
    
    @IBAction func funcKey(_ sender: AnyObject) {
        if funcKeyButton.state == 1 {
            playerController.funcKey = true
            defaults.set(true, forKey: "funcKey")
        }
        else {
            playerController.funcKey = false
            defaults.set(false, forKey: "funcKey")
        }
    }
}
