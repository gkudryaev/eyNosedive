//
//  SearchTVC.swift
//  eyNosedive
//
//  Created by Grisha on 6/6/17.
//  Copyright © 2017 EY. All rights reserved.
//

import UIKit

class SearchTVC: UITableViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    let userList: [User] = User.initList()
    var filteredUserList: [User] = []
    var selectedIndex: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
//        searchController.searchBar.barTintColor = AppModule.defaultColor
        searchController.searchBar.isOpaque = true
        searchController.searchBar.isTranslucent = false
        
        searchController.delegate = self
        searchController.searchBar.delegate = self
        
        tableView.tableHeaderView = searchController.searchBar

        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredUserList.count
        } else {
            return userList.count
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let user: User
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filteredUserList[indexPath.row]
        } else {
            user = userList[indexPath.row]
        }
        cell.textLabel?.text = user.fullName
        cell.detailTextLabel?.text = user.email
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath
        performSegue(withIdentifier: "searchItem", sender: nil)
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        
        let tokens = searchText.lowercased().components(separatedBy: " ").filter{i in
            return i.characters.count > 0
        }
        
        filteredUserList = userList.filter{
            s in
            for token in tokens {
                if !s.searchName.contains(token) {
                    return false
                }
            }
            return true
        }
        
        tableView.reloadData()
    }

}

extension SearchTVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension SearchTVC: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
        
    }
}

extension SearchTVC: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        performSegue(withIdentifier: "cancelSearch", sender: nil)
        
    }
}
