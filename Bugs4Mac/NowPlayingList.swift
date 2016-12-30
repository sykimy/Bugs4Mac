//
//  NowPlayingList.swift
//  Music
//
//  Created by sykimy on 2016. 8. 2..
//  Copyright © 2016년 sykimy. All rights reserved.
//

import Cocoa

class NowPlayingList: NSTableView {
    
    let nc = NotificationCenter.default
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }
    
    //우클릭된 열을 반환.
    override func menu(for theEvent: NSEvent)->NSMenu {
        super.menu(for: theEvent)
        let mousePoint = self.convert(theEvent.locationInWindow, to: nil)
        let row = self.row(at: mousePoint)
        
        var rowInfo = [AnyHashable: Any]()  //Notification을 이용해 데이터 전송을 위한 딕셔너리
        rowInfo["row"] = row
        
        //delegate로 할까하다가 그냥 notificaion으로 함.
        nc.post(name: Notification.Name(rawValue: "nowPlayingListRightClickedRow"), object: self, userInfo: rowInfo)
        
        return self.menu!
    }
    
    
}

