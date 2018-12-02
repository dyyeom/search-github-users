//
//  GithubUser.swift
//  search-github-users
//
//  Created by Doyeong Yeom on 01/12/2018.
//  Copyright © 2018 blueprog. All rights reserved.
//

import RealmSwift

class GithubUser: Object, Codable {
    @objc var login: String?
    @objc var id: Int = 0
    @objc var avatarUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case login
        case id
        case avatarUrl = "avatar_url"
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}