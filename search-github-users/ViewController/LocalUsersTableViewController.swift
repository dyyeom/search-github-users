//
//  LocalUsersTableViewController.swift
//  search-github-users
//
//  Created by Doyeong Yeom on 01/12/2018.
//  Copyright © 2018 blueprog. All rights reserved.
//

import SDWebImage
import UIKit
import RealmSwift

class LocalUsersTableViewController: UITableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    var sections: [Character] = []
    var tableData: [GithubUser] = []
    var keyword: String?
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
        
        requestGithubUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        requestGithubUser()
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
        try! realm.write {
            if let user = realm.object(ofType: GithubUser.self, forPrimaryKey: item.id) {
                realm.delete(user)
            } else {
                realm.add(item.copy())
            }
        }
    }

    
    func requestGithubUser(keyword: String = "") {
        self.keyword = keyword
        
        let users: [GithubUser]
        if keyword.count > 0 {
            users = Array(realm.objects(GithubUser.self).filter("login contains '\(keyword)'"))
        } else {
            users = Array(realm.objects(GithubUser.self))
        }
        
        self.sections = Array(Set(users.map { $0.login?.capitalized.first ?? "#" })).sorted()
        
        self.tableData = [GithubUser](users.sorted {
            let name1 = $0.login ?? ""
            let name2 = $1.login ?? ""
            return name1.localizedCaseInsensitiveCompare(name2) == .orderedAscending
        })
        tableView.reloadData()
        
        guard let refreshControl = self.refreshControl else { return }
        refreshControl.endRefreshing()
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
