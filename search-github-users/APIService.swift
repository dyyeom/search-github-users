//
//  APIService.swift
//  search-github-users
//
//  Created by Doyeong Yeom on 01/12/2018.
//  Copyright © 2018 blueprog. All rights reserved.
//

import Alamofire

class APIService {
    static var API_HOST = "https://api.github.com"
    
    class func searchGithubUsers(keyword: String, page: Int = 1) -> Alamofire.DataRequest {
        return Alamofire.request(APIService.API_HOST + "/search/users", method: .get, parameters: ["q" : keyword, "page" : page])
    }
}
