//
//  PodCastDetailVC.swift
//  PodCastPlayer
//
//  Created by Steve Kerney on 7/25/17.
//  Copyright © 2017 d4rkz3r0. All rights reserved.
//

import Cocoa

class PodCastDetailVC: NSViewController
{

    //MARK: IBOutlets
    
    @IBOutlet weak var podCastTitle: NSTextField!
    @IBOutlet weak var podCastImageView: NSImageView!
    @IBOutlet weak var mediaControlButton: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    
    //MARK: Data
    var selectedPodcast:PodCastEntity? = nil;
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
       
    }
    
    //MARK: Private Helpers
    func updateUI()
    {
        guard let vSelectedPodcast = selectedPodcast else { print("Podcast is nil"); return; }
        
        //Title
        guard let vPodcastTitle = vSelectedPodcast.title else { print("Podcast title is nil"); return; }
        podCastTitle.stringValue = vPodcastTitle;
        
        //Image
        guard let vPodcastImageURL = vSelectedPodcast.imageURL else { print("Podcast ImgURL is nil"); return; }
        guard let vImageURL = URL(string: vPodcastImageURL) else { print("Unable to create Podcast ImgURL"); return; }
        let podcastImage = NSImage(byReferencing: vImageURL);
        podCastImageView.image = podcastImage;
        
        
        
    }
    
    //MARK: IBActions
    
    @IBAction func deleteButtonPressed(_ sender: Any)
    {
        
    }
    
    @IBAction func mediaControlButtonPressed(_ sender: Any)
    {
        
    }
    
}
