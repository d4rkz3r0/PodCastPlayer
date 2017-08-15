//
//  EpisodeCell.swift
//  PodCastPlayer
//
//  Created by Steve Kerney on 8/15/17.
//  Copyright © 2017 d4rkz3r0. All rights reserved.
//

import Cocoa
import WebKit

class EpisodeCell: NSTableCellView
{
    //MARK: IBOutlets
    
    @IBOutlet weak var episodeTitle: NSTextField!
    @IBOutlet weak var episodeDate: NSTextField!
    @IBOutlet weak var episodeDescWebView: WKWebView!
    
    override func draw(_ dirtyRect: NSRect)
    {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
