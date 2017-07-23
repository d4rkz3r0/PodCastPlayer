//
//  PodCastListVC.swift
//  PodCastPlayer
//
//  Created by Steve Kerney on 7/23/17.
//  Copyright © 2017 d4rkz3r0. All rights reserved.
//

import Cocoa

class PodCastListVC: NSViewController
{

    //MARK: IBOutlets
    @IBOutlet weak var podcastURLTextField: NSTextField!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

    }
    
    //MARK: IBActions
    @IBAction func addPodcastButtonPressed(_ sender: Any)
    {
        guard !podcastURLTextField.stringValue.isEmpty else { print("PodCast URL Empty"); return; }
        
        if let podcastURL = URL(string: podcastURLTextField.stringValue)
        {
            URLSession.shared.dataTask(with: podcastURL) { (data:Data?, response:URLResponse?, error:Error?) in
                
                guard error == nil else { print("Unable to retrieve PodCast Info \(error.debugDescription)"); return; }
                
                guard let vData = data else { print("no data"); return; }
                
                let parser = Parser();
                print(parser.getPodcastTitleAndImageURL(data: vData));
                
            }.resume();
        }
        clearUI();
    }
    
    //MARK: Helper Functions
    func clearUI()
    {
        podcastURLTextField.stringValue = "";
    }
    
    //MARK: Core Data Wrappers
    func savePodCastToCoreData(podCastTitle: String, podCastImageURL: String, podCastRSSURL: String)
    {
        guard let managedContext = (NSApplication.shared().delegate as? AppDelegate)?.persistentContainer.viewContext else { print("No Context") return; }
        
        let podCastItem = PodCastEntity(context: managedContext);
        podCastItem.title = podCastTitle;
        podCastItem.title = podCastTitle;
        podCastItem.title = podCastTitle;
        
        
    }
}
