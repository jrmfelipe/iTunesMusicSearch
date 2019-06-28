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
    let searchLimit = 5  // lower the value to test "load more result"
   
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
        DispatchQueue.main.async {
            self.model.removeAll()
            self.tableView.reloadData()
        }
        //media=music&
        let url = URL(string: "https://itunes.apple.com/search?term=work&offset=\(self.searchOffset)&limit=\(self.searchLimit)")
        
        let task = session.dataTask(with: url!, completionHandler: { data, response, error in
            
            //TODO: show activityview
            if error != nil {
                self.handleClientError(error!)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    self.handleServerError(response!)
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
                                    //TODO: if  resultCount < searchLimit then we got all the search results.
                                    self.searchOffset += resultCount
                                    
                                }
                            }
                        }
                    }
                }
            } catch {
                self.handleClientError(error)
            }
        })
        task.resume()
        
    }
    
    //MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: iTunesMusicInfoCell.cellIdentifier, for: indexPath) as! iTunesMusicInfoCell
        
        // Configure the cell’s contents.
        cell.musicTitleLabel.text = model[indexPath.row].musicTitle
        cell.artistNameLabel.text = model[indexPath.row].artistName
        cell.albumNameLabel.text = model[indexPath.row].albumName
        cell.fetchArtworkImageFromURL(model[indexPath.row].artworkUrl)
        
        return cell
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

