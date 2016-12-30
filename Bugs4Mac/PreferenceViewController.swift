//
//  PreferenceView.swift
//  Bugs
//
//  Created by sykimy on 2016. 9. 23..
//  Copyright © 2016년 sykimy. All rights reserved.
//

import Cocoa

class PreferenceViewController:NSViewController {
    
    @IBOutlet var wallPaperPreference: WallPaperPlayerPreference!
    
    /* 설정창 WallpaperPlayer로부터 독립적으로 나가야 할 부분이지만, 차후 수정 예정. */
    let prefernecesWindow = NSWindow(contentRect: NSMakeRect(500, 500, 100, 100),
                                     styleMask: [NSWindowStyleMask.titled, NSWindowStyleMask.closable],
                                     backing: NSBackingStoreType.buffered, defer: true)
    var controller:NSWindowController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prefernecesWindow.setFrame(NSRect(origin: CGPoint.init(x: 50, y: NSScreen.main()!.visibleFrame.size.height-50) , size: CGSize(width: view.frame.width, height: view.frame.height+20)), display: true)
        prefernecesWindow.contentView = view
        controller = NSWindowController(window: prefernecesWindow)
    }
    
    @IBAction func openPreferences(_ sender: AnyObject) {
        controller.showWindow(self)
        
        wallPaperPreference.getNowValue()
    }
    
}
