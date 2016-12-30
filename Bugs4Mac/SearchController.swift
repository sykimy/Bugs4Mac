//
//  SearchController.swift
//  Music
//
//  Created by sykimy on 2016. 8. 5..
//  Copyright © 2016년 sykimy. All rights reserved.
//


import Cocoa

class SearchController: NSObject {
    
    @IBOutlet var searchField: NSSearchField!   //검색어 필드
    @IBOutlet var mainWebViewController: MainWebViewController! //메인웹뷰
    @IBOutlet var tabView: NSTabView!   //텝뷰
    @IBOutlet var player: PlayerController! //플레이어
    
    let nc = NotificationCenter.default
    
    var mouse = false
    var playNow = false
    
    @IBOutlet var appDelegate: AppDelegate!
    
    let sharedUserDefaults = UserDefaults.init(suiteName: "group.bugs4mac.sykimy")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        sharedUserDefaults?.addObserver(self, forKeyPath: "search", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    //마우스의 In/Out 여부 확인
    //검색 활성화 버튼으로 마우스 In/Out효과를 주기위해 받아온다.
    func mouseIn() {
        mouse = true
    }
    
    func mouseOut() {
        mouse = false
    }
    
    //검색필드의 투명도 조절
    func alphaValue(value:CGFloat) {
        searchField.alphaValue = value
    }
    
    //검색할시 마우스가 나가있으면 마우스가 나간 효과를 준다.
    @IBAction func search(_ sender: AnyObject) {
        if searchField.stringValue != "" {
            search(value: searchField.stringValue)
            
            if !mouse {
                player.mouseOut()
            }
        }
    }
    
    //단축키로 인한 검색 활성화 및 비활성화
    @IBAction func keySearch(_ sender: AnyObject) {
        //이미 검색창이 활성화 되있을시
        if searchField.window?.firstResponder is NSTextView {
            //마우스가 플레이어 밖에있다면 mouseOut효과를 준다.
            if !mouse { player.mouseOut() }
            //검색창 하이라이트 취소
            searchField.window?.makeFirstResponder(nil)
        }
        else {
            //검색창 하이라이트
            searchField.window?.makeFirstResponder(searchField)
            //마우스가 플레이어밖에있다면 mouseIn효과를 준다.
            if !mouse { player.mouseIn() }
        }
    }
    
    func search(value: String) {
        // ':'로 시작할시 바로 음악 재생
        if value.characters.first == ":" {
            var str = value
            str.remove(at: value.startIndex)    //":"삭제
            self.mainWebViewController.openSearch(str)  //검색시작
            playNow = true  //바로 실행상태
        }
        else {
            self.tabView.selectTabViewItem(at: 1)   //검색창을 띄운다.
            self.mainWebViewController.openSearch(value)    //검색시작
            self.appDelegate.reopen(self)   //창을 연다
            playNow = false //바로 실행아님
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "search" {
            search(value: sharedUserDefaults?.object(forKey: "search") as! String)
        }
    }
    
}
