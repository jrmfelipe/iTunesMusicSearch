//
//  ViewController.swift
//  iTunesMusicSearch
//
//  Created by Rey Felipe on 6/28/19.
//  Copyright © 2019 Rey Felipe. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    lazy var viewModel: MusicListViewModel = {
        return MusicListViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Init the static view
        initView()
        
        // init view model
        initVM()
    }
    
    func initView() {
        self.navigationItem.title = "Music Search"
    }
    
    //MARK: MVVM methods
    func initVM() {
        
        // Naive binding
        viewModel.showAlertClosure = { [weak self] () in
            DispatchQueue.main.async {
                if let message = self?.viewModel.alertMessage {
                    self?.showAlert( message )
                }
            }
        }
        
        viewModel.updateLoadingStatus = { [weak self] () in
            DispatchQueue.main.async {
                let isLoading = self?.viewModel.isLoading ?? false
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.tableView.alpha = 0.0
                        self?.tableView.isHidden = true
                    })
                }else {
                    self?.activityIndicator.stopAnimating()
                    self?.tableView.isHidden = false
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.tableView.alpha = 1.0
                    })
                }
            }
        }
        
        viewModel.reloadTableViewClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                if (self?.viewModel.fetchingMore)! {
                    self?.viewModel.fetchingMore = false
                }
            }
        }
    }
    
    func showAlert( _ message: String ) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Actions
    @IBAction func searchButtonTapped() {
        searchTextField.resignFirstResponder()
        
        // start a new search request, remove previous content
        viewModel.removeAll()
        
        guard let searchTerm = searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !searchTerm.isEmpty else {
            
            self.showAlert( "Search field is empty." )
            return
        }
        let escapedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)

        viewModel.fetchData(escapedSearchTerm!, initialFetch: true)
    }

    //MARK: - UIScrollViewDelagate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard let searchTerm = searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !searchTerm.isEmpty else {
            return
        }
        
        //If we reach the end of the table.
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
            //request for the next page, result will be added
            if !viewModel.fetchingMore {
                viewModel.fetchData(searchTerm, initialFetch: false)
            }
        }
    }
}

//MARK: - UITextFieldDelegate
extension ViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if !textField.text!.isEmpty {
            searchButtonTapped()
            return true
        }
        return false
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: iTunesMusicInfoCell.cellIdentifier, for: indexPath) as? iTunesMusicInfoCell else {
                fatalError("Cell not exists in storyboard")
            }
            
            let cellVM = viewModel.getCellViewModel( at: indexPath )
            cell.musicListCellViewModel = cellVM
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: LoadingCell.cellIdentifier, for: indexPath) as! LoadingCell
            cell.spinner.startAnimating()
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return viewModel.numberOfCells
        } else if section == 1 && viewModel.fetchingMore && !viewModel.endOfSearchResult {
            return 1
        }
        return 0
    }
}
