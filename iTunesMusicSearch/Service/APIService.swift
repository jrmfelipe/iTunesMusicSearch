//
//  APIService.swift
//  iTunesMusicSearch
//
//  Created by Rey Felipe on 6/30/19.
//  Copyright © 2019 Rey Felipe. All rights reserved.
//

import Foundation


protocol APIServiceProtocol {
    func fetchMusic(term: String, offset: Int, limit: Int, complete: @escaping ( _ success: Bool, _ musics: [Music], _ error: Error? )->() )
}

class APIService: APIServiceProtocol {
    
    func fetchMusic(term: String, offset: Int, limit: Int, complete: @escaping ( _ success: Bool, _ musics: [Music], _ error: Error? )->() ) {
        DispatchQueue.main.async(execute: {
            //&media=music might be a required param since we are searching music
            
            let url = URL(string: "https://itunes.apple.com/search?term=\(term)&offset=\(offset)&limit=\(limit)")
            MusicHTTP.execute(request: url!, completion: { result in
                guard case .success(let resultInfo2) = result else {
                    guard case .failure(let error) = result else {
                        return
                    }
                    complete(false, [], error)
                    return
                }
                var musics = [Music]()
                if let resultCount = resultInfo2!["resultCount"] as? Int {
                    if  resultCount > 0 {
                        if let results = resultInfo2!["results"] as? [[String: Any]] {
                            for resultDetail in results {
                                // iterate here
                                let result = Music(resultDetail)
                                musics.append(result)
                            }
                        }
                    }
                }
                complete(true, musics, nil)
            })
        })
        /*
        DispatchQueue.global().async {
            sleep(3)
            let path = Bundle.main.path(forResource: "content", ofType: "json")!
            let data = try! Data(contentsOf: URL(fileURLWithPath: path))
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let photos = try! decoder.decode(Photos.self, from: data)
            complete( true, photos.photos, nil )
        }
         */
    }
    
    
    
}
