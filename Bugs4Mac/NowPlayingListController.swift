//
//  NowPlayingListController.swift
//  Music
//
//  Created by sykimy on 2016. 8. 2..
//  Copyright © 2016년 sykimy. All rights reserved.
//

import Cocoa

class NowPlayingListController: NSObject {
    
    @IBOutlet var webPlayer: WebPlayerController!
    @IBOutlet var nowPlayingList: NowPlayingList!
    
    var dataArray: NSMutableArray! = NSMutableArray()
    
    let nc = NotificationCenter.default
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nc.addObserver(self, selector: #selector(NowPlayingListController.rightClickedRow), name: NSNotification.Name(rawValue: "nowPlayingListRightClickedRow"), object: nil)
        
        /* Drag&Drop */
        nowPlayingList.register(forDraggedTypes: ["dragNDrop", NSFilenamesPboardType])
    }
    
    /* 플레이 리스트를 불러오는 함수 */
    func getPlayList() {
        let numOfSong = webPlayer.getNumOfSong()
        
        self.dataArray.removeAllObjects()
        
        for i:Int in 0..<numOfSong {
            let song = webPlayer.getPlayListSong(i)
            dataArray.add(song)
        }
        
        self.nowPlayingList.reloadData()
    }
    
    /* 자료의 수를 테이블뷰에 전달한다. */
    func numberOfRowsInTableView(_ tableView: NSTableView) -> Int {
        return self.dataArray.count
    }
    
    /* 테이블뷰를 갱신한다. */
    func tableView(_ tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard (dataArray?[row]) != nil else {
            return nil
        }
        
        if tableColumn == nowPlayingList.tableColumns[0] {
            let cellNum = nowPlayingList.make(withIdentifier: "now", owner: self) as! NSTableCellView
            if (self.dataArray.object(at: row) as! Song).getNow() {
                cellNum.textField!.stringValue = "✔"
            }
            else {
                cellNum.textField!.stringValue = ""
            }
            return cellNum
        }
        else if tableColumn == nowPlayingList.tableColumns[1] {
            let cellNum = nowPlayingList.make(withIdentifier: "num", owner: self) as! NSTableCellView
            cellNum.textField!.integerValue = (self.dataArray.object(at: row) as! Song).getNum()
            return cellNum
        }
        else if tableColumn == nowPlayingList.tableColumns[2] {
            let cellName = nowPlayingList.make(withIdentifier: "name", owner: self) as! NSTableCellView
            cellName.textField!.stringValue = (self.dataArray.object(at: row) as! Song).getName()
            return cellName
        }
        else if tableColumn == nowPlayingList.tableColumns[3] {
            let cellArtist = nowPlayingList.make(withIdentifier: "artist", owner: self) as! NSTableCellView
            cellArtist.textField!.stringValue = (self.dataArray.object(at: row) as! Song).getArtist()
            return cellArtist
        }
        
        return nil
    }
    
    @IBAction func doubleAction(_ sender: AnyObject) {
        webPlayer.playSelectedSong(i: (self.dataArray.object(at: self.nowPlayingList.selectedRow) as AnyObject).getNum()-1)
    }
    
    var isOnlyRightClick = false
    var rightSelectedRow = -1
    var selectedRows = [Int]()
    
    func rightClickedRow(_ note: Notification) {
        let rowInfo : NSDictionary = (note as NSNotification).userInfo as NSDictionary!
        rightSelectedRow = rowInfo.object(forKey: "row") as! Int
        
        for i in 0..<selectedRows.count {
            if rightSelectedRow == selectedRows[i] {
                isOnlyRightClick = false
                return
            }
        }
        isOnlyRightClick = true
    }
    
    /* 다중 선택을 받아오는 함수 */
    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = notification.object as! NSTableView
        
        selectedRows.removeAll()
        
        // In this example, the TableView allows multiple selection
        let indexes = myTableViewFromNotification.selectedRowIndexes
        
        var index = indexes.first
        while index != nil {
            selectedRows.append(index!)
            index = indexes.integerGreaterThan(index!)
        }
    }
}

/* Drag&Drop구현 */
extension NowPlayingListController {
    /* Drag & Drop */
    func tableView(_ tableView: NSTableView, writeRowsWithIndexes: IndexSet, toPasteboard: NSPasteboard) -> Bool {
        let data = NSKeyedArchiver.archivedData(withRootObject: [writeRowsWithIndexes])
        toPasteboard.declareTypes(["dragNDrop"], owner:self)
        toPasteboard.setData(data, forType:"dragNDrop")
        
        return true
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        tableView.setDropRow(row, dropOperation: NSTableViewDropOperation.above)
        return NSDragOperation.move
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        let pasteboard = info.draggingPasteboard()
        let rowData = pasteboard.data(forType: "dragNDrop")
        
        for i in 0..<selectedRows.count {
            webPlayer.selectSong(selectedRows[i])
        }
        
        if(rowData != nil) {
            var _dataArray = NSKeyedUnarchiver.unarchiveObject(with: rowData!) as! Array<IndexSet>,
            indexSet = _dataArray[0]
            
            /* 이동한 칸수 */
            let moveUp = indexSet.first! - row - 1
            let moveDown = -(indexSet.last! - row + 2)
            
            if moveUp >= 0 {
                for _ in 0...moveUp {
                    webPlayer.moveUp()
                }
            }
            else {
                for _ in 0...moveDown {
                    webPlayer.moveDown()
                }
            }
            
            /* 선택 초기화 */
            if selectedRows.count == webPlayer.getNumOfSong() {
                webPlayer.selectAllSong()
            }
            else {
                webPlayer.selectAllSong()
                webPlayer.selectAllSong()
            }
            
            getPlayList()
            
            return true
        }
        else {
            return false
        }
    }
}

/* 메뉴 함수 모음 */
extension NowPlayingListController {
    @IBAction func menuDeleteAll(_ sender: AnyObject) {
        webPlayer.deletePlayList()
    }
    
    @IBAction func menuGetTop100(_ sender: AnyObject) {
        webPlayer.getTop100()
    }
    
    @IBAction func menuDeleteNGetTop100(_ sender: AnyObject) {
        webPlayer.deleteNGetTop100()
        getPlayList()
    }
    
    @IBAction func menuDelete(_ sender: AnyObject) {
        /* 우클릭된 음악이 단독일 경우 */
        if isOnlyRightClick || selectedRows.count == 1 {
            webPlayer.selectSong(rightSelectedRow)
            webPlayer.deleteSelectSong()
            selectedRows.removeAll()
        }
            /* 우클릭된 음악이 단독이 아닐 경우 */
        else {
            for i in 0..<selectedRows.count {
                webPlayer.selectSong(selectedRows[i])
            }
            webPlayer.deleteSelectSong()
        }
    }
    
    @IBAction func menuKeyDelete(_ sender: AnyObject) {
        /* 우클릭된 음악이 단독일 경우 */
        if selectedRows.count == 1 {
            webPlayer.selectSong(selectedRows[0])
            webPlayer.deleteSelectSong()
            selectedRows.removeAll()
        }
            /* 우클릭된 음악이 단독이 아닐 경우 */
        else {
            for i in 0..<selectedRows.count {
                webPlayer.selectSong(selectedRows[i])
            }
            webPlayer.deleteSelectSong()
        }
    }
}

