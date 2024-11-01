//
//  GFFollowerItemVC.swift
//  FollowersGitHub
//
//  Created by Alan Modesto on 31/10/24.
//

import UIKit


class GFFollowerItemVC: GFItemInfoVc {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureItems()
        
    }
    
    private func configureItems() {
        itemInfoViewOne.set(itemInfoType: .followers, withCount: user.followers)
        itemInfoViewTwo.set(itemInfoType: .following, withCount: user.following)
        actionButton.set(backgroundColor: .systemGreen, title: "Get Followers")
    }
    
    override func actionButtonTapped() {
    delegate.didTapGetFollowers(for: user)
    }
}
