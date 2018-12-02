//
//  GithubUserTableViewCell.swift
//  search-github-users
//
//  Created by Doyeong Yeom on 01/12/2018.
//  Copyright © 2018 blueprog. All rights reserved.
//

import RealmSwift

class GithubUserTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        favoriteButton.setImage(UIImage(named: "fav_icon_on"), for: .highlighted)
        favoriteButton.setImage(UIImage(named: "fav_icon_off"), for: .normal)
    }
    
    func setItem(item: GithubUser) {
        avatarImageView.sd_setImage(with: URL(string: item.avatarUrl ?? ""))
        nameLabel.text = item.login
    }
}
