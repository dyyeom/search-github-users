//
//  APIUsersTableViewController.swift
//  search-github-users
//
//  Created by Doyeong Yeom on 01/12/2018.
//  Copyright © 2018 blueprog. All rights reserved.
//

import SDWebImage
import UIKit
import RealmSwift

class APIUsersTableViewController: UITableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    var sections: [Character] = []
    var tableData: [GithubUser] = []
    var users: GithubUsers?
    var keyword: String?
    var page: Int = 1
    var realm: Realm!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        do {
            realm = try Realm()
        } catch {
            print("\(error)")
        }
        
        tableView.register(UINib(nibName: "GithubUserTableViewCell", bundle: nil), forCellReuseIdentifier: "GithubUserTableViewCell")
        
        refreshControl = UIRefreshControl()
        guard let refreshControl = self.refreshControl else { return }
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.filter { $0.login?.capitalized.first! == self.sections[section] }.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GithubUserTableViewCell", for: indexPath) as! GithubUserTableViewCell
        
        let item = self.tableData.filter { $0.login?.capitalized.first ?? "#" == self.sections[indexPath.section] }[indexPath.row]
        cell.setItem(item: item)
        cell.favoriteButton.isHighlighted = realm.object(ofType: GithubUser.self, forPrimaryKey: item.id) != nil
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(self.sections[section])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.tableData.filter { $0.login?.capitalized.first ?? "#" == self.sections[indexPath.section] }[indexPath.row]
        let cell = self.tableView.cellForRow(at: indexPath) as! GithubUserTableViewCell
        var isFavorited = false
        try! realm.write {
            if let user = realm.object(ofType: GithubUser.self, forPrimaryKey: item.id) {
                realm.delete(user)
            } else {
                realm.add(item)
                isFavorited = true
            }
        }
        cell.favoriteButton.isHighlighted = isFavorited
    }
    
    func requestGithubUser(keyword: String) {
        APIService.searchGithubUsers(keyword: keyword, page: self.page).responseJSON { r in
            let jsonDecoder = JSONDecoder()
            if let jsonData = r.data {
                do {
                    let users = try jsonDecoder.decode(GithubUsers.self, from: jsonData)
                    if self.page == 1 {
                        self.users = users
                    } else {
                        self.users?.items?.append(contentsOf: users.items ?? [])
                        self.users?.totalCount = users.totalCount
                        self.users?.incompleteResults = users.incompleteResults
                    }
                    self.page += 1
                    if let items = self.users?.items {
                        self.sections = Array(Set(items.map { $0.login?.capitalized.first ?? "#" })).sorted()
                        
                        self.tableData = items.sorted {
                            let name1 = $0.login ?? ""
                            let name2 = $1.login ?? ""
                            return name1.localizedCaseInsensitiveCompare(name2) == .orderedAscending
                        }
                    }
                    self.tableView.reloadData()
                } catch let error{
                    print(error.localizedDescription)
                }
            }
            guard let refreshControl = self.refreshControl else { return }
            refreshControl.endRefreshing()
        }
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == tableView, ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
            requestGithubUser(keyword: self.keyword ?? "")
        }
    }
    
    @objc func refreshTableView() {
        requestGithubUser(keyword: self.keyword ?? "")
    }
}

extension APIUsersTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text else { return }
        self.users = nil
        self.keyword = keyword
        self.page = 1
        self.requestGithubUser(keyword: keyword)
    }
}
