//
//  LoadViewController.swift
//  Music
//
//  Created by sykimy on 2016. 9. 17..
//  Copyright © 2016년 sykimy. All rights reserved.
//

import Cocoa

//아이콘 등록
class LoadViewController: NSViewController {
    
    @IBOutlet var loadIcon: NSImageCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        loadIcon.image = NSImage(named: "load.png")
        
    }
    
}
