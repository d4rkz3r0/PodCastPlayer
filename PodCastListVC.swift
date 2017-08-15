//
//  PodCastListVC.swift
//  PodCastPlayer
//
//  Created by Steve Kerney on 7/23/17.
//  Copyright © 2017 d4rkz3r0. All rights reserved.
//

import Cocoa

class PodCastListVC: NSViewController, NSTableViewDelegate, NSTableViewDataSource
{

    //MARK: IBOutlets
    @IBOutlet weak var podcastURLTextField: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    
    //MARK: Data
    var podcasts: [PodCastEntity] = [];
    
    //VC Refs
    var podcastDetailVC: PodCastDetailVC? = nil;
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        getPodcastsFromCoreData();

    }
    
    //MARK: IBActions
    @IBAction func addPodcastButtonPressed(_ sender: Any)
    {
        guard !podcastURLTextField.stringValue.isEmpty else { print("PodCast URL Empty"); return; }
        guard let podcastURL = URL(string: podcastURLTextField.stringValue) else { print("URL Creation failed."); return; }
        
        URLSession.shared.dataTask(with: podcastURL) { (data:Data?, response:URLResponse?, error:Error?) in
            
            guard error == nil else { print("Unable to retrieve PodCast Info \(error.debugDescription)"); return; }
            
            guard let vData = data else { print("no data"); return; }
            
            let parser = Parser();
            let podCastInfo = (parser.getPodcastTitleAndImageURL(data: vData));
            self.savePodCastToCoreData(podCastTitle: podCastInfo.title, podCastImageURL: podCastInfo.imageURL, podCastRSSURL: podcastURL.absoluteString);
            
            
            self.getPodcastsFromCoreData();
            
            DispatchQueue.main.async { self.clearUI(); } 

            }.resume();
    }
    
    //MARK: TableView Delegate Functions
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return podcasts.count;
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        let cell = tableView.make(withIdentifier: podCastCellIdentifier, owner: self) as? NSTableCellView
        
        guard let podcastTitle = podcasts[row].title else {print("Unable to pull podcast title"); return nil; }
        cell?.textField?.stringValue = podcastTitle;
        
        return cell;
    }
    
    func tableViewSelectionDidChange(_ notification: Notification)
    {
        guard tableView.selectedRow >= 0 else { return; }
        
        podcastDetailVC?.selectedPodcast = podcasts[tableView.selectedRow];
        
        podcastDetailVC?.updateUI();
    }

    
    //MARK: Core Data Wrappers
    func savePodCastToCoreData(podCastTitle: String, podCastImageURL: String, podCastRSSURL: String)
    {
        guard let managedContext = (NSApplication.shared().delegate as? AppDelegate)?.persistentContainer.viewContext else { print("No Context"); return; }
        
        if (!isPodcastAlreadyAdded(podcastRSSURL: podCastRSSURL))
        {
            let podCastItem = PodCastEntity(context: managedContext);
            podCastItem.title = podCastTitle;
            podCastItem.imageURL = podCastImageURL;
            podCastItem.rssFeedURL = podCastRSSURL;
            
            (NSApplication.shared().delegate as? AppDelegate)?.saveAction(nil);
        }
    }
    
    func getPodcastsFromCoreData()
    {
        guard let managedContext = (NSApplication.shared().delegate as? AppDelegate)?.persistentContainer.viewContext else { print("No Context"); return; }

        let fetchRequest = PodCastEntity.fetchRequest() as NSFetchRequest<PodCastEntity>;
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)];
        
        do
        {
            podcasts = try managedContext.fetch(fetchRequest);
        } catch {}

        DispatchQueue.main.async { self.tableView.reloadData(); }
    }
    
    
    //MARK: Helper Functions
    private func isPodcastAlreadyAdded(podcastRSSURL: String) -> Bool
    {
        guard let managedContext = (NSApplication.shared().delegate as? AppDelegate)?.persistentContainer.viewContext else { print("No Context"); return false; }
        
        let uniqueNamedPodCastFetchRequest = PodCastEntity.fetchRequest() as NSFetchRequest<PodCastEntity>;
        
        //Check against passed in podcastFeedURL
        uniqueNamedPodCastFetchRequest.predicate = NSPredicate(format: "rssFeedURL == %@", podcastRSSURL);
        
        do
        {
            let matchingPodcasts = try managedContext.fetch(uniqueNamedPodCastFetchRequest);
            
            //There's already one with the same name.
            guard matchingPodcasts.count >= 1 else { return false; }
            return true;
            
        } catch {}
        
        
        //This is a unique podcast.
        return false;
    }
    
    private func clearUI()
    {
        podcastURLTextField.stringValue = "";
    }
}
