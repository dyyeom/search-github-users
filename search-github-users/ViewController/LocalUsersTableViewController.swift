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
import RxCocoa
import RxSwift
import RxDataSources

class LocalUsersTableViewController: UIViewController, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var refreshControl: UIRefreshControl!
    
    var disposeBag = DisposeBag()
    
    var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, GithubUser>>!
    var sections = BehaviorRelay(value: [SectionModel<String, GithubUser>]())
    var searchText: String?
    var realm: Realm!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            realm = try Realm()
        } catch {
            print("\(error)")
        }
        
        tableView.register(UINib(nibName: "GithubUserTableViewCell", bundle: nil), forCellReuseIdentifier: "GithubUserTableViewCell")
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        tableView.addSubview(self.refreshControl)
        
        self.dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, GithubUser>>(
            configureCell: { (_, tv, indexPath, element) in
                let cell = tv.dequeueReusableCell(withIdentifier: "GithubUserTableViewCell") as! GithubUserTableViewCell
                cell.setItem(item: element)
                cell.favoriteButton.isHighlighted = self.realm.object(ofType: GithubUser.self, forPrimaryKey: element.id) != nil
                return cell
        },
            titleForHeaderInSection: { dataSource, sectionIndex in
                return self.dataSource[sectionIndex].model
        })
        
        self.sections.asObservable()
            .bind(to: self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx
            .itemSelected
            .map { indexPath in
                return (indexPath, self.dataSource[indexPath])
            }
            .subscribe(onNext: { pair in
                let item = self.sections.value[pair.0.section].items[pair.0.row]
                try! self.realm.write {
                    if let user = self.realm.object(ofType: GithubUser.self, forPrimaryKey: item.id) {
                        self.realm.delete(user)
                    } else {
                        self.realm.add(item.copy())
                    }
                }
                self.loadSections()
            })
            .disposed(by: disposeBag)
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadSections()
    }
    
    func loadSections() {
        let users: [GithubUser]
        if let searchText = searchText, searchText.count > 0 {
            users = Array(realm.objects(GithubUser.self).filter("login contains '\(searchText)'"))
        } else {
            users = Array(realm.objects(GithubUser.self))
        }
        let sortedUsers = users.sorted {
            return $0.login?.localizedCaseInsensitiveCompare($1.login ?? "") == .orderedAscending
        }
        
        var models: [SectionModel<String, GithubUser>] = []
        for section in Array(Set(users.map { String($0.login?.capitalized.first ?? "#") })).sorted() {
            models.append(SectionModel(model: section, items: sortedUsers.filter { String($0.login?.capitalized.first ?? "#") == section }))
        }
        
        self.sections.accept(models)
        
        self.refreshControl?.endRefreshing()
    }
    
    @objc func refreshTableView() {
        loadSections()
    }
}

extension LocalUsersTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        self.loadSections()
    }
}
