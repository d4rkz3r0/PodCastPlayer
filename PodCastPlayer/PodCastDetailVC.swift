//
//  PodCastDetailVC.swift
//  PodCastPlayer
//
//  Created by Steve Kerney on 7/25/17.
//  Copyright © 2017 d4rkz3r0. All rights reserved.
//

import Cocoa
import AVFoundation

class PodCastDetailVC: NSViewController
{

    //MARK: IBOutlets
    @IBOutlet weak var podCastTitle: NSTextField!
    @IBOutlet weak var podCastImageView: NSImageView!
    @IBOutlet weak var mediaControlButton: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    
    //MARK: Data
    var episodes: [Episode] = [];
    var selectedPodcast: PodCastEntity? = nil;
    
    //VC Refs
    var podcastListVC: PodCastListVC? = nil;
    
    //Player
    var audioPlayer: AVPlayer? = nil;
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
       
    }
    
    //MARK: Private Helpers
    func updateUI()
    {
        //PodCast
        guard let vSelectedPodcast = selectedPodcast else { print("Podcast is nil"); return; }
        
        //Title
        guard let vPodcastTitle = vSelectedPodcast.title else { print("Podcast title is nil"); return; }
        podCastTitle.stringValue = vPodcastTitle;
        
        //Image
        guard let vPodcastImageURL = vSelectedPodcast.imageURL else { print("Podcast ImgURL is nil"); return; }
        guard let vImageURL = URL(string: vPodcastImageURL) else { print("Unable to create Podcast ImgURL"); return; }
        let podcastImage = NSImage(byReferencing: vImageURL);
        podCastImageView.image = podcastImage;
        
        mediaControlButton.isHidden = true;
        
        updateEpisodesList();
    }
    
    private func updateEpisodesList()
    {
        //RSS URL
        guard let vSelectedPodcastRSSFeedURL = selectedPodcast?.rssFeedURL else { print("Podcast RSS URL is nil."); return; }
        guard let podcastURL = URL(string: vSelectedPodcastRSSFeedURL) else { print("URL Creation failed."); return; }
        
        //Request Data
        URLSession.shared.dataTask(with: podcastURL) { (data:Data?, response:URLResponse?, error:Error?) in
            
            guard error == nil else { print("Unable to retrieve PodCast Info \(error.debugDescription)"); return; }
            
            guard let vData = data else { print("no data"); return; }
            
            let parser = Parser();
            self.episodes = parser.getPodcastEpisodes(data: vData);
            
            DispatchQueue.main.async { self.tableView.reloadData(); }
            
            }.resume();
    }
    
    func clearUI()
    {
        selectedPodcast = nil;
        podCastTitle.stringValue = "";
        podCastImageView.image = nil;
        
    }
    
    //MARK: IBActions
    @IBAction func deleteButtonPressed(_ sender: Any)
    {
        //PodCast
        guard let vSelectedPodcast = selectedPodcast else { print("Podcast is nil"); return; }
        
        //Core Data - Delete & Save
        guard let managedContext = (NSApplication.shared().delegate as? AppDelegate)?.persistentContainer.viewContext else { print("No Context"); return; }
        managedContext.delete(vSelectedPodcast);
        (NSApplication.shared().delegate as? AppDelegate)?.saveAction(nil);
        //Update TableView
        podcastListVC?.getPodcastsFromCoreData();
        clearUI();
    }
    
    @IBAction func mediaControlButtonPressed(_ sender: Any)
    {
        
    }
}

//MARK: TableView Delegate Functions
extension PodCastDetailVC: NSTableViewDelegate, NSTableViewDataSource
{
    func numberOfRows(in tableView: NSTableView) -> Int { return episodes.count; }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        let cell = tableView.make(withIdentifier: episodeCellIdentifier, owner: self) as? NSTableCellView;
        
        let episode = episodes[row];
        cell?.textField?.stringValue = episode.title;
        
    
        return cell;
    }
    
    func tableViewSelectionDidChange(_ notification: Notification)
    {
        guard tableView.selectedRow >= 0 else { return; }
        
        let episodeAudioURL_Str = episodes[tableView.selectedRow].audioURL;
        
        guard let vEpisodeAudioURL = URL(string: episodeAudioURL_Str) else { print("URL Creation failed."); return; }
        
        
        //Initialize AVPlayer
        audioPlayer = AVPlayer(url: vEpisodeAudioURL);
        audioPlayer?.play();
        
        
        
    }
    
}
