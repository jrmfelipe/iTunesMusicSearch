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
    var searchString = ""
    
    var reloadTableViewClosure: (()->())?
    var showAlertClosure: (()->())?
    var updateLoadingStatus: (()->())?
    
    init( apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }
    
    func initFetch(search: String) {
        self.isLoading = true
        apiService.fetchMusic(term: search, offset: 0, limit: searchLimit) { [weak self] (success, musics, error) in
            self?.isLoading = false
            if let error = error {
                self?.alertMessage = error.localizedDescription
                
                guard let musicHTTPError = error as? MusicHTTPError else {
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
            } else {
                self?.processFetchedPhoto(musics: musics)
            }
        }
    }
    
    func getCellViewModel(at indexPath: IndexPath ) -> MusicListCellViewModel {
        return cellViewModels[indexPath.row]
    }
    
    func createCellViewModel(music: Music ) -> MusicListCellViewModel {
        
        return MusicListCellViewModel( musicTitleText: "",
                                       artistNameText: "",
                                       albumNameText: "",
                                       artworkUrl: "",
                                       musicPreviewUrl: "")
    }
    
    private func processFetchedPhoto(musics: [Music] ) {
        self.musics = musics // Cache
        var vms = [MusicListCellViewModel]()
        for music in musics {
            vms.append( createCellViewModel(music: music) )
        }
        self.cellViewModels = vms
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
    let artworkUrl: String
    let musicPreviewUrl: String
}
