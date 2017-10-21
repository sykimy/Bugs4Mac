//
//  preferenceSync.swift
//  Bugs
//
//  Created by 김세윤 on 2016. 10. 30..
//  Copyright © 2016년 sykimy. All rights reserved.
//

import Cocoa

//조건적인 사용자 성농 설정을 가능하게 하는 설정
class SyncPrefernece:NSObject {
    
    //설정창의 슬라이더
    @IBOutlet var slider: NSSlider! //동기화 타이밍
    @IBOutlet var timingSlider: NSSlider!   //Fade In/Out효과 타이밍
    @IBOutlet var timeSlider: NSSlider! //Fade In/Out효과 지속시간
    
    //설정 저장 defaults
    let defaults = UserDefaults.standard
    
    //플레이어
    @IBOutlet var player: PlayerController!
    
    /* 프로그램 시작시 설정 값을 가져온다. */
    override func awakeFromNib() {
        /* 얼마나 자주 벅스 웹 플레이어와 싱크할지 불러온다. */
        if defaults.object(forKey: "sync") != nil {
            let syncTiming = defaults.double(forKey: "sync")
            player.setSyncTiming(syncTiming)
            slider.doubleValue = 1-syncTiming
        }
        else {
            // 기본설정은 0.5초에 한번
            player.setSyncTiming(0.5)
        }
        
        /* 버튼이 사라지고 나타나는 시간 값을 가져온다. */
        if defaults.object(forKey: "time") != nil {
            let syncTiming = defaults.double(forKey: "time")
            player.setFadeInOutTime(syncTiming)
            timeSlider.doubleValue = syncTiming
        }
        else {
            // 기본설정은 0.1초
            player.setFadeInOutTime(0.1)
        }
        
        /* 버튼을 Fade In/Out할때 몇초에 한번씩 반영할지 불러온다. */
        if defaults.object(forKey: "timing") != nil {
            let syncTiming = defaults.double(forKey: "timing")
            player.setFadeInOutTiming(syncTiming)
            timingSlider.doubleValue = 1-syncTiming
        }
        else {
            // 기본설정은 0.01초에 한번
            player.setFadeInOutTiming(0.01)
        }
    }
    
    /* 슬라이더로부터 벅스플레이어와 몇초에 한번 싱크할지 값을 받아온다. */
    @IBAction func setSyncTimer(_ sender: Any) {
        // 오른쪽으로 갈수록 타이밍이 작아지므로
        // 1-슬라이더값을 해준다. (0.1~0.9초)
        let syncTiming = 1-slider.doubleValue
        
        //user defaults를 설정해준다.
        defaults.set(syncTiming, forKey: "sync")
        
        //플레이어에 이를 반영한다.
        player.setSyncTiming(syncTiming)
    }
    
    /* 슬라이더로부터 Fade In/Out이 몇초에 한번씩 반영될지 값을 받아온다. */
    @IBAction func setFadeTiming(_ sender: Any) {
        // 오른쪽으로 갈수록 타이밍이 작아지므로
        // 1-슬라이더값을 해준다. (0.01~1초)
        let fadeTiming = 0.1-timingSlider.doubleValue
        
        //user defaults를 설정해준다.
        defaults.set(fadeTiming, forKey: "timing")
        
        //풀레이어애 이를 반영한다.
        player.setFadeInOutTiming(fadeTiming)
    }
    
    /* 슬라이더로부터 Fade효과의 지속 시간을 받아온다. */
    @IBAction func setFadeTime(_ sender: Any) {
        //슬라이더로부터 값을 받아온다. (0~3초)
        let fadeTime = timeSlider.doubleValue
        
        //user defaults를 설정해준다.
        defaults.set(fadeTime, forKey: "time")
        
        //플레이어에 이를 반영한다.
        player.setFadeInOutTime(fadeTime)
    }
    
    @IBAction func deleteCookie(_ sender: Any) {
        let storage = HTTPCookieStorage.shared
        for cookie in storage.cookies! {
            storage.deleteCookie(cookie)
        }
    }
    
    @IBAction func deleteUserDefaults(_ sender: Any) {
        let appDomain = Bundle.main.bundleIdentifier!
        
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
    }
    
    
    
}

