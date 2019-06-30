//
//  Music.swift
//  iTunesMusicSearch
//
//  Created by Rey Felipe on 6/30/19.
//  Copyright © 2019 Rey Felipe. All rights reserved.
//

import Foundation

struct Musics: Codable {
    var music: [Music]
}

struct Music: Codable {
    let musicTitle: String // JSON equivalent trackName
    let artistName: String // JSON equivalent artistName
    let albumName: String // JSON equivalent collectionName
    let artworkUrl: String? // JSON equivalent artworkUrl100 > artworkUrl60 > artworkUrl30
    let previewUrl: String? // JSON equivalent previewUrl
    
    init(_ dictionary: [String: Any]) {
        self.musicTitle = dictionary["trackName"] as? String ?? ""
        self.artistName = dictionary["artistName"] as? String ?? ""
        self.albumName = dictionary["collectionName"] as? String ?? ""
        self.artworkUrl = dictionary["artworkUrl100"] as? String ?? dictionary["artworkUrl60"] as? String ?? dictionary["artworkUrl30"] as? String ?? nil
        self.previewUrl = dictionary["artworkUrl100"] as? String ?? nil
    }
}

extension Music: Equatable {
    static func == (lhs: Music, rhs: Music) -> Bool {
        return lhs.musicTitle == rhs.musicTitle &&
            lhs.artistName == rhs.artistName &&
            lhs.albumName == rhs.albumName
    }
}
