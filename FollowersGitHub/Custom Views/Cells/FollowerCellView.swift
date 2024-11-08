//
//  FollowerCellView.swift
//  FollowersGitHub
//
//  Created by Alan Modesto on 08/11/24.
//

import SwiftUI

struct FollowerCellView: View {
    var follower: Follower
    
    var body: some View {
        //VStack o que é?
        VStack{
            AsyncImage(url: URL(string: follower.avatarUrl)) {
                image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                (Image(.avatarPlaceholder))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .clipShape(Circle())
            
            Text(follower.login)
                .bold()
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
    }
}

#Preview {
    FollowerCellView(follower: Follower(login: "AlanAndCode", avatarUrl: ""))
}
