//
//  SideListItem.swift
//  Music
//
//  Created by sykimy on 2016. 8. 2..
//  Copyright © 2016년 sykimy. All rights reserved.
//

import Cocoa

class ParentItem: NSObject {
    let name: String
    let isHeader: Bool
    var children = [ChildItem]()
    
    init(name: String, isHeader: Bool) {
        self.name = name
        self.isHeader = isHeader
    }
    
    func appendChild(_ title: String, num: Int, parent: String){
        self.children.append(ChildItem(title: title, num: num, parent: parent, href: ""))
    }
    
    func appendChild(_ title: String, href: String, num: Int, parent: String){
        self.children.append(ChildItem(title: title, num: num, parent: parent, href: href))
    }
}

class ChildItem: NSObject {
    let title: String!
    let num:Int!
    let parent:String!
    let href: String!
    
    init(title: String, num: Int, parent: String, href: String) {
        self.title = title
        self.num = num
        self.parent = parent
        self.href = href
    }
}
