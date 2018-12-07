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
import RxCocoa
import RxSwift
import RxDataSources

class APIUsersTableViewController: UIViewController, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var refreshControl: UIRefreshControl!
    
    var disposeBag = DisposeBag()
    
    var sections = BehaviorRelay(value: [SectionModel<String, GithubUser>]())
    var searchText: String?
    var realm: Realm!
    var isNextLoading = false
    
    var users: GithubUsers?
    var page: Int = 0
    
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
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, GithubUser>>(
            configureCell: { (_, tv, indexPath, element) in
                let cell = tv.dequeueReusableCell(withIdentifier: "GithubUserTableViewCell") as! GithubUserTableViewCell
                cell.setItem(item: element)
                cell.favoriteButton.isHighlighted = self.realm.object(ofType: GithubUser.self, forPrimaryKey: element.id) != nil
                return cell
        },
            titleForHeaderInSection: { dataSource, sectionIndex in
                return dataSource[sectionIndex].model
        })
        
        self.sections.asObservable()
            .bind(to: self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx
            .itemSelected
            .map { indexPath in
                return (indexPath, dataSource[indexPath])
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
            .contentOffset
            .map { return $0.y }
            .subscribe { event in
                let y = event.element ?? 0.0
                let height = self.tableView.frame.size.height
                let viewHeight = self.tableView.contentSize.height
                
                if y + height > viewHeight, self.sections.value.count > 0, self.isNextLoading == false {
                    self.loadNextSections()
                }
            }
            .disposed(by: disposeBag)
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loadSections()
    }
    
    func loadSections() {
        guard let searchText = self.searchText else { self.refreshControl?.endRefreshing(); return }
        APIService.searchGithubUsers(searchText: searchText, page: 1).responseJSON { r in
            let jsonDecoder = JSONDecoder()
            if let jsonData = r.data {
                do {
                    let users = try jsonDecoder.decode(GithubUsers.self, from: jsonData)
                    self.users = users
                    self.page = 1
                    let sortedUsers = self.users?.items?.sorted {
                        return $0.login?.localizedCaseInsensitiveCompare($1.login ?? "") == .orderedAscending
                    }
                    
                    var models: [SectionModel<String, GithubUser>] = []
                    for section in Array(Set(self.users?.items?.map { String($0.login?.capitalized.first ?? "#") } ?? [])).sorted() {
                        models.append(SectionModel(model: section, items: sortedUsers?.filter { String($0.login?.capitalized.first ?? "#") == section } ?? []))
                    }
                    
                    self.sections.accept(models)
                } catch let error{
                    print(error.localizedDescription)
                }
            }
            self.refreshControl?.endRefreshing()
        }
    }
    
    func loadNextSections() {
        self.isNextLoading = true
        APIService.searchGithubUsers(searchText: self.searchText ?? "", page: self.page + 1).responseJSON { r in
            let jsonDecoder = JSONDecoder()
            if let jsonData = r.data {
                do {
                    let users = try jsonDecoder.decode(GithubUsers.self, from: jsonData)
                    self.users?.items?.append(contentsOf: users.items ?? [])
                    self.users?.totalCount = users.totalCount
                    self.users?.incompleteResults = users.incompleteResults
                    self.page += 1
                    let sortedUsers = self.users?.items?.sorted {
                        return $0.login?.localizedCaseInsensitiveCompare($1.login ?? "") == .orderedAscending
                    }
                    
                    var models: [SectionModel<String, GithubUser>] = []
                    for section in Array(Set(self.users?.items?.map { String($0.login?.capitalized.first ?? "#") } ?? [])).sorted() {
                        models.append(SectionModel(model: section, items: sortedUsers?.filter { String($0.login?.capitalized.first ?? "#") == section } ?? []))
                    }
                    
                    self.sections.accept(models)
                } catch let error{
                    print(error.localizedDescription)
                }
            }
            self.isNextLoading = false
            self.refreshControl?.endRefreshing()
        }
    }
    
    @objc func refreshTableView() {
        loadSections()
    }
}

extension APIUsersTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        self.page = 1
        self.loadSections()
    }
}
