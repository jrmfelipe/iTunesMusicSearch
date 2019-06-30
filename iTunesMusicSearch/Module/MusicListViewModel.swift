//
//  MusicListViewModel.swift
//  iTunesMusicSearch
//
//  Created by Rey Felipe on 6/30/19.
//  Copyright © 2019 Rey Felipe. All rights reserved.
//

import Foundation

class MusicListViewModel {
    
    let apiService: APIServiceProtocol
    
    private var musics: [Music] = [Music]()
    
    private var cellViewModels: [MusicListCellViewModel] = [MusicListCellViewModel]() {
        didSet {
            self.reloadTableViewClosure?()
        }
    }
    
    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatus?()
        }
    }
    
    var alertMessage: String? {
        didSet {
            self.showAlertClosure?()
        }
    }
    
    var numberOfCells: Int {
        return cellViewModels.count
    }
    
    var selectedMusic: Music?
    
    var searchOffset = 0
    let searchLimit = 25  // lower the value to test "load more result"
    var endOfSearchResult = false
    var fetchingMore = false
    
    var reloadTableViewClosure: (()->())?
    var showAlertClosure: (()->())?
    var updateLoadingStatus: (()->())?
    
    init( apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }
    
    func fetchData(_ search: String, initialFetch: Bool) {
        var offset = searchOffset
        if initialFetch == true {
            self.isLoading = true
        } else {
            self.fetchingMore = true
            offset += 1
        }
        if self.endOfSearchResult {
            // No need to send another request we have reached the end of the search result
            return
        }
        apiService.fetchMusic(term: search, offset: offset, limit: searchLimit) { [weak self] (success, musics, error) in
            if initialFetch == true {
                self?.isLoading = false
            }
            if let error = error {
                guard let musicHTTPError = error as? MusicHTTPError else {
                    self?.fetchingMore = false
                    self?.alertMessage = error.localizedDescription
                    return
                }
                switch musicHTTPError {
                case .noResponse:
                    self?.alertMessage = "Looks like the server is taking to long to respond, this can be caused by either poor connectivity or an error with our servers. Please try again in a while"
                    break
                case .unsuccesfulStatusCode(let code):
                    self?.alertMessage = "\(code): Looks like something went wrong on our end."
                    break
                }
                self?.fetchingMore = false
            } else {
                if musics.isEmpty {
                    self?.alertMessage = "Sorry, we couldn't find any match"
                    return
                }
                self!.searchOffset += musics.count
                if musics.count < self!.searchLimit {
                    self?.endOfSearchResult = true
                }
                self?.processFetchedMusic(musics: musics)
            }
        }
    }
    
    func removeAll() {
        self.endOfSearchResult = false
        self.searchOffset = 0
        self.musics.removeAll()
        self.cellViewModels.removeAll()
    }
    
    func getCellViewModel(at indexPath: IndexPath ) -> MusicListCellViewModel {
        return cellViewModels[indexPath.row]
    }
    
    func createCellViewModel(music: Music ) -> MusicListCellViewModel {
        
        let artistName = "by: \(music.artistName)"
        
        return MusicListCellViewModel( musicTitleText: music.musicTitle,
                                       artistNameText: artistName,
                                       albumNameText: music.albumName,
                                       artworkUrl: music.artworkUrl,
                                       musicPreviewUrl: music.previewUrl)
    }
    
    private func processFetchedMusic(musics: [Music] ) {
        self.musics = musics // Cache
        var vms = [MusicListCellViewModel]()
        for music in musics {
            
            let cellViewModel = createCellViewModel(music: music)
            // Need to test duplicate here
            if !self.cellViewModels.contains(cellViewModel) {
                vms.append(cellViewModel)
            } else {
                // we have a duplicate result
            }
        }
        self.cellViewModels.append(contentsOf: vms)
    }
    
}

extension MusicListViewModel {
    func userPressed(at indexPath: IndexPath ){
        //let music = self.musics[indexPath.row]
        // TODO: handle music preview playback here
    }
}

struct MusicListCellViewModel {
    let musicTitleText: String
    let artistNameText: String
    let albumNameText: String
    let artworkUrl: String?
    let musicPreviewUrl: String?
}

extension MusicListCellViewModel: Equatable {
    static func == (lhs: MusicListCellViewModel, rhs: MusicListCellViewModel) -> Bool {
        return lhs.musicTitleText == rhs.musicTitleText &&
            lhs.artistNameText == rhs.artistNameText &&
            lhs.albumNameText == rhs.albumNameText
    }
}
