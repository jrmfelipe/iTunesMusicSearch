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
    let searchLimit = 10  // lower the value to test "load more result"
    var endOfSearchResult = false
    var fetchingMore = false
    
    var model = [iTunesMusicInfo]() //Initialising Model Array

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    //MARK: - Error Handling
    func handleClientError(_ error: Error) {
        
        //TODO: handle client errors here
        print(error)
    }
    
    func handleServerError(_ response: URLResponse) {
        
        //TODO: handle server errors here
        print(response)
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
        //media=music&
        //let url = URL(string: "https://itunes.apple.com/search?term=work&offset=\(self.searchOffset)&limit=\(self.searchLimit)")
        fetchData()
        /*
        //self.showSpinner()
        print("REY 1")
        print(url!)
        let task = session.dataTask(with: url!, completionHandler: { data, response, error in
            
            //TODO: show activityview
            if error != nil {
                self.handleClientError(error!)
                self.fetchingMore = false
                //self.removeSpinner()
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    self.handleServerError(response!)
                    self.fetchingMore = false
                    //self.removeSpinner()
                    return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                // parse JSON here
                if let resultInfo = json as? [String: Any] {
                    if let resultCount = resultInfo["resultCount"] as? Int {
                        if  resultCount > 0 {
                            if let results = resultInfo["results"] as? [[String: Any]] {
                                for result in results {
                                    // iterate here
                                    self.model.append(iTunesMusicInfo(result)) // adding now value in Model array
                                }
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                    //if  resultCount < searchLimit then we got all the search results.
                                    if resultCount < self.searchLimit {
                                        self.endOfSearchResult = true
                                    }
                                    self.searchOffset += resultCount
                                    self.fetchingMore = false
                                    //self.removeSpinner()
                                }
                            }
                        }
                    }
                }
            } catch {
                self.handleClientError(error)
                self.fetchingMore = false
                //self.removeSpinner()
            }
        })
        task.resume()
 */
    }
    
    //MARK: - fetch Data
    private func fetchData() {
        if self.endOfSearchResult {
            // No need to send another request we have reached the end of the search result
            return
        }
        fetchingMore = true
        print("fethcingMore")
        if searchOffset != 0 {
            // load only when fetching a new batch of search result
            tableView.reloadSections(IndexSet(integer: 1), with: .none)
        }
        DispatchQueue.main.async(execute: {
            let url = URL(string: "https://itunes.apple.com/search?term=work&offset=\(self.searchOffset)&limit=\(self.searchLimit)")
            MusicHTTP.execute(request: url!, completion: { result in
                guard case .success(let resultInfo2) = result else {
                    print("not success")
                    guard case .failure(let error) = result else {
                        print("no error")
                        self.fetchingMore = false
                        return
                    }
                    self.handleClientError(error)
                    self.fetchingMore = false
                    return
                }
                if let resultCount = resultInfo2!["resultCount"] as? Int {
                    if  resultCount > 0 {
                        if let results = resultInfo2!["results"] as? [[String: Any]] {
                            for resultDetail in results {
                                // iterate here
                                self.model.append(iTunesMusicInfo(resultDetail)) // adding now value in Model array
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
                fetchData()
            }
        }
    }
    
    //MARK: - UITableViewDelegate

    //MARK: - UITextFieldDelegate
    func textField(_ textFieldToChange: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        searchButton.isEnabled = !string.isEmpty
        
        
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
