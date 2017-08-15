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
    @IBOutlet weak var deleteButton: NSButton!
    @IBOutlet weak var mediaControlButton: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    
    //MARK: Data
    var episodes: [Episode] = [];
    var selectedPodcast: PodCastEntity? = nil;
    
    //VC Refs
    var podcastListVC: PodCastListVC? = nil;
    
    //Player
    var audioPlayer: AVPlayer? = nil;
    var isAudioPlaying: Bool = false;
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        clearUI();
       
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
        
        //UI Elems
        if selectedPodcast != nil
        {
            tableView.isHidden = false;
            deleteButton.isHidden = false;
        }
        else
        {
            tableView.isHidden = true;
            deleteButton.isHidden = true;
        }
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
        tableView.isHidden = true;
        deleteButton.isHidden = true;
        mediaControlButton.isHidden = true;

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
        
        selectedPodcast = nil;
        clearUI();
    }
    
    @IBAction func mediaControlButtonPressed(_ sender: Any)
    {
        if (isAudioPlaying)
        {
            isAudioPlaying = !isAudioPlaying;
            audioPlayer?.pause();
            mediaControlButton.title = "Play";
            
        }
        else
        {
            isAudioPlaying = !isAudioPlaying;
            audioPlayer?.play();
            mediaControlButton.title = "Pause";
        }
    }
}

//MARK: TableView Delegate Functions
extension PodCastDetailVC: NSTableViewDelegate, NSTableViewDataSource
{
    func numberOfRows(in tableView: NSTableView) -> Int { return episodes.count; }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        let cell = tableView.make(withIdentifier: episodeCellIdentifier, owner: self) as? EpisodeCell;
        
        let episode = episodes[row];
        cell?.episodeTitle.stringValue = episode.title;
        cell?.episodeDate.stringValue = episode.publicationDate.description;
        cell?.episodeDescWebView.loadHTMLString(episode.htmlDescription, baseURL: nil);
        
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "MMM d, yyyy";
        cell?.episodeDate.stringValue = dateFormatter.string(from: episode.publicationDate);
    
        return cell;
    }
    
    func tableViewSelectionDidChange(_ notification: Notification)
    {
        guard tableView.selectedRow >= 0 else { return; }
        
        let episodeAudioURL_Str = episodes[tableView.selectedRow].audioURL;
        guard let vEpisodeAudioURL = URL(string: episodeAudioURL_Str) else { print("URL Creation failed."); return; }
        
        //Previous Audio Stream
        audioPlayer?.pause();
        audioPlayer = nil;
        
        //New Audio Stream
        audioPlayer = AVPlayer(url: vEpisodeAudioURL);
        audioPlayer?.play();
        
        isAudioPlaying = true;
        mediaControlButton.isHidden = false;
        mediaControlButton.title = "Pause";
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat
    {
        return CGFloat(120.0);
    }
}
