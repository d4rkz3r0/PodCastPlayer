//
//  MainSplitVC.swift
//  PodCastPlayer
//
//  Created by Steve Kerney on 7/25/17.
//  Copyright © 2017 d4rkz3r0. All rights reserved.
//

import Cocoa

class MainSplitVC: NSSplitViewController
{

    //MARK: IBOulets
    
    @IBOutlet weak var podcastListItem: NSSplitViewItem!
    @IBOutlet weak var podcastDetailItem: NSSplitViewItem!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        guard let podCastListVC = podcastListItem.viewController as? PodCastListVC else { print("1st Split Item does not have a VC in it."); return; }
        guard let podCastDetailVC = podcastDetailItem.viewController as? PodCastDetailVC else { print("2nd Split Item does not have a VC in it."); return; }
        
        podCastListVC.podcastDetailVC = podCastDetailVC;
        
    }
    
}
