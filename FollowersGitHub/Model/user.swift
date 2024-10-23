//
//  user.swift
//  FollowersGitHub
//
//  Created by Alan Modesto on 22/10/24.
//

import Foundation

struct User: Codable {
    
    var login: String
    var avatarurl: String
    var name: String?
    var location: String?
    var bio: String?
    var publicRepos: Int
    var publicGists: Int
    var htmlUrl: String
    var following: Int
    var followers: Int
    var createdAt: String
}
