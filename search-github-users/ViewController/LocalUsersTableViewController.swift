//
//  LocalUsersTableViewController.swift
//  search-github-users
//
//  Created by Doyeong Yeom on 01/12/2018.
//  Copyright © 2018 blueprog. All rights reserved.
//

import SDWebImage
import UIKit

class LocalUsersTableViewController: UITableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    var tableData: [GithubUser]?
    var keyword: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "GithubUserTableViewCell", bundle: nil), forCellReuseIdentifier: "GithubUserTableViewCell")
        
        refreshControl = UIRefreshControl()
        guard let refreshControl = self.refreshControl else { return }
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GithubUserTableViewCell", for: indexPath) as! GithubUserTableViewCell
        if let item = self.tableData?[indexPath.row] {
            cell.setItem(item: item)
        }
        return cell
    }
    
    func requestGithubUser(keyword: String) {
       
    }
    
    @objc func refreshTableView() {
        requestGithubUser(keyword: self.keyword ?? "")
    }
}

extension LocalUsersTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text else { return }
        self.keyword = keyword
        self.requestGithubUser(keyword: keyword)
    }
}
