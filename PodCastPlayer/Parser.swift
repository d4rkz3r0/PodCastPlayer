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
            podCastTuple.0 = "No Title Info";
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
}
