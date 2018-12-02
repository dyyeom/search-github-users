//
//  GithubUserViewModel.swift
//  search-github-users
//
//  Created by Doyeong Yeom on 02/12/2018.
//  Copyright © 2018 blueprog. All rights reserved.
//

struct GithubUserViewModel {
    var login: String?
    var id: Int?
    var avatarUrl: String?
    var isFavorite: Bool?
    
    public init(item: GithubUser) {
        login = item.login
        id = item.id
        avatarUrl = item.avatarUrl
//        isFavorite은 sqlite에 있는지 확인해야 한다. 으어어...
    }
}
