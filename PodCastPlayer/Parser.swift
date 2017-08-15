//
//  Parser.swift
//  PodCastPlayer
//
//  Created by Steve Kerney on 7/23/17.
//  Copyright © 2017 d4rkz3r0. All rights reserved.
//

import Foundation

class Parser
{
    func getPodcastTitleAndImageURL(data: Data) -> (title: String, imageURL: String)
    {
        let xmlData = SWXMLHash.parse(data);
        
        var podCastTuple = ("", "");
        
        //Title
        if let vTitle = xmlData["rss"]["channel"]["title"].element?.text
        {
            podCastTuple.0 = vTitle;
        }
        else
        {
            podCastTuple.0 = "Invalid RSS URL, try again.";
        }
        
        //Image URL
        if let vImageURL = xmlData["rss"]["channel"]["itunes:image"].element?.attribute(by: "href")?.text
        {
            podCastTuple.1 = vImageURL;
        }
        else
        {
            podCastTuple.1 = "No Image URL"
        }
        
        return podCastTuple;
    }
    
    func getPodcastEpisodes(data: Data) -> [Episode]
    {
        let xmlData = SWXMLHash.parse(data);
        
        var episodes: [Episode] = [];
        
        for item in xmlData["rss"]["channel"]["item"].all
        {
            let episode = Episode();
            
            //Title
            guard let vEpTitle = item["title"].element?.text else { print("Unable to retrieve episode title."); return []; }
            episode.title = vEpTitle;
            
            //Description
            guard let vEpDescription = item["description"].element?.text else { print("Unable to retrieve episode description."); return []; }
            episode.htmlDescription = vEpDescription;
            
            //Audio URL
            guard let vEpAudioURL = item["enclosure"].element?.attribute(by: "url")?.text else { print("Unable to retrieve episode audio URL."); return []; }
            episode.audioURL = vEpAudioURL;
            
            //Publication Date
            guard let vEpPublishDate = item["pubDate"].element?.text else { print("Unable to retrieve episode publication date."); return []; }
            guard let formattedPublishDate = Episode.formatter.date(from: vEpPublishDate) else { return []; }
            episode.publicationDate = formattedPublishDate;
            
            //Add Episode
            episodes.append(episode);
        }

        return episodes;
    }
}
