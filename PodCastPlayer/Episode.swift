//
//  Episode.swift
//  PodCastPlayer
//
//  Created by Steve Kerney on 8/15/17.
//  Copyright © 2017 d4rkz3r0. All rights reserved.
//

import Cocoa

class Episode
{
    var title = "";
    var htmlDescription = "";
    var audioURL = "";
    var publicationDate = Date();
    
    static let formatter: DateFormatter =
    {
        let formatter = DateFormatter();
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz";
        return formatter;
    }();
}
