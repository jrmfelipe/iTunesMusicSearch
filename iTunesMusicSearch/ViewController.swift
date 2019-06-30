//
//  ViewController.swift
//  iTunesMusicSearch
//
//  Created by Rey Felipe on 6/28/19.
//  Copyright © 2019 Rey Felipe. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let session = URLSession.shared
    var searchOffset = 0
    let searchLimit = 25  // lower the value to test "load more result"
    var endOfSearchResult = false
    var fetchingMore = false
    
    var model = [iTunesMusicInfo]() //Initialising Model Array

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    //MARK: - Error Handling
    func handleError(_ error: Error) {
        //handle client errors here
        guard let musicHTTPError = error as? MusicHTTPError else {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        switch musicHTTPError {
        case .noResponse:
            let errorMessage = "Looks like the server is taking to long to respond, this can be caused by either poor connectivity or an error with our servers. Please try again in a while"
            let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            break
        case .unsuccesfulStatusCode(let code):
            let errorMessage = "\(code): Looks like something went wrong on our end."
            let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            break
        }
    }
    
    //MARK: - Actions
    @IBAction func searchButtonTapped() {
        searchTextField.resignFirstResponder()
        
        // start a new search request, remove previous content
        
        self.endOfSearchResult = false
        self.searchOffset = 0
        self.model.removeAll()
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        fetchData()
    }
    
    //MARK: - fetch Data
    private func fetchData() {
        var offset =  searchOffset
        if self.endOfSearchResult {
            // No need to send another request we have reached the end of the search result
            return
        }
        guard let searchTerm = searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !searchTerm.isEmpty else {
            return
        }
        let escapedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        if offset != 0 {
            offset += 1
            // load only when fetching a new batch of search result
            self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
            print("fethcing more result for \"\(searchTerm)\" at offset \(offset)")
            
        } else {
            
            print("fetching for the 1st time")
        }
        
        DispatchQueue.main.async(execute: {
            //&media=music might be a required param since we are searching music
            let url = URL(string: "https://itunes.apple.com/search?term=\(escapedSearchTerm!)&offset=\(offset)&limit=\(self.searchLimit)")
            MusicHTTP.execute(request: url!, completion: { result in
                guard case .success(let resultInfo2) = result else {
                    guard case .failure(let error) = result else {
                        self.fetchingMore = false
                        return
                    }
                    self.handleError(error)
                    self.fetchingMore = false
                    return
                }
                if let resultCount = resultInfo2!["resultCount"] as? Int {
                    if  resultCount > 0 {
                        if let results = resultInfo2!["results"] as? [[String: Any]] {
                            for resultDetail in results {
                                // iterate here
                                let result = iTunesMusicInfo(resultDetail)
                                if !self.model.contains(result) {
                                     self.model.append(result) // adding now value in Model array
                                } else {
                                    print("Search result \(result) already in the list")
                                }
                            }
                            if resultCount < self.searchLimit {
                                self.endOfSearchResult = true
                            }
                            self.searchOffset += resultCount
                        }
                    }
                }
                DispatchQueue.main.async {
                    UIView.performWithoutAnimation {
                        let contentOffset = self.tableView.contentOffset
                        self.tableView.reloadData()
                        self.tableView.layoutIfNeeded()
                        self.tableView.setContentOffset(contentOffset, animated: false)
                    }
                    self.fetchingMore = false
                }
            })
        })
    }
    
    //MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return model.count
        } else if section == 1 && fetchingMore {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: iTunesMusicInfoCell.cellIdentifier, for: indexPath) as! iTunesMusicInfoCell
            
            // Configure the cell’s contents.
            cell.musicTitleLabel.text = model[indexPath.row].musicTitle
            cell.artistNameLabel.text = model[indexPath.row].artistName
            cell.albumNameLabel.text = model[indexPath.row].albumName
            cell.fetchArtworkImageFromURL(model[indexPath.row].artworkUrl)
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: LoadingCell.cellIdentifier, for: indexPath) as! LoadingCell
            cell.spinner.startAnimating()
            return cell
        }
        
        
    }
    
    //MARK: - UIScrollViewDelagate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //If we reach the end of the table.
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
            //request for the next page, result will be added
            if !fetchingMore {
                fetchingMore = true
                fetchData()
            }
        }
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    //MARK: - UITextFieldDelegate
    func textField(_ textFieldToChange: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        searchButton.isEnabled = !textFieldToChange.text!.isEmpty
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if !textField.text!.isEmpty {
            searchButtonTapped()
            return true
        }
        return false
    }
}
