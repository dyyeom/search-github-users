//
//  GithubUser.swift
//  search-github-users
//
//  Created by Doyeong Yeom on 01/12/2018.
//  Copyright © 2018 blueprog. All rights reserved.
//

struct GithubUser: Codable {
    var login: String?
    var id: Int?
    var avatarUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case login
        case id
        case avatarUrl = "avatar_url"
    }
}
