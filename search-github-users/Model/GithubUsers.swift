//
//  GithubUser.swift
//  search-github-users
//
//  Created by Doyeong Yeom on 01/12/2018.
//  Copyright © 2018 blueprog. All rights reserved.
//

struct GithubUsers: Codable {
    var totalCount: Int?
    var items: [GithubUser]?
    var incompleteResults: Bool?
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
}
