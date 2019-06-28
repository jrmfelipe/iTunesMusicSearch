//
//  iTunesMusicInfo.swift
//  iTunesMusicSearch
//
//  Created by Rey Felipe on 6/28/19.
//  Copyright © 2019 Rey Felipe. All rights reserved.
//

import Foundation

struct iTunesMusicInfo {
    var musicTitle: String // JSON equivalent trackName
    var artistName: String // JSON equivalent artistName
    var albumName: String // JSON equivalent collectionName
    var artworkUrl: URL? // JSON equivalent trackName artworkUrl100 > artworkUrl60 > artworkUrl30
    
    init(_ dictionary: [String: Any]) {
        self.musicTitle = dictionary["trackName"] as? String ?? ""
        self.artistName = dictionary["artistName"] as? String ?? ""
        self.albumName = dictionary["collectionName"] as? String ?? ""
        self.artworkUrl = dictionary["artworkUrl100"] as? URL ?? dictionary["artworkUrl60"] as? URL ?? dictionary["artworkUrl30"] as? URL ?? nil
    }
}
