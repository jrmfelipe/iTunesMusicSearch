//
//  iTunesMusicInfoCell.swift
//  iTunesMusicSearch
//
//  Created by Rey Felipe on 6/28/19.
//  Copyright © 2019 Rey Felipe. All rights reserved.
//

import UIKit
import Foundation

class iTunesMusicInfoCell: UITableViewCell {
    @IBOutlet weak var musicTitleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var loadingActivityIndicatorView: UIActivityIndicatorView!
    
    static let cellIdentifier = "musicInfoCellIdentifier"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        artworkImageView.layer.cornerRadius = 10
    }
    
    func fetchArtworkImageFromURL(_ urlString: String?) {
        //lazy loading implement here.
        DispatchQueue.main.async {
            self.updatingArtworkView(true)
        }
        let task =  URLSession.shared.dataTask(with: URL(string:urlString!)!, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                
                self.updatingArtworkView(false)
                guard let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode), error == nil else {
                        self.artworkImageView.image = UIImage(named: "music-app-icon-ios")
                        return
                }
                if let data = data {
                    self.artworkImageView.image = UIImage(data: data)
                } else {
                    // something went wrong, use a place holder image
                    self.artworkImageView.image = UIImage(named: "music-app-icon-ios")
                }
            }
        })
        task.resume()
    }
    
    private func updatingArtworkView(_ loading: Bool) {
        // Hide/Show activity indicator and artwork image view
        self.loadingActivityIndicatorView.isHidden = !loading
        self.artworkImageView.isHidden = loading
    }
}
