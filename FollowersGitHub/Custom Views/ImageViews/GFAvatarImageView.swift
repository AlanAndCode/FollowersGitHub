//
//  GFAvatarImageView.swift
//  FollowersGitHub
//
//  Created by Alan Modesto on 23/10/24.
//

import UIKit

class GFAvatarImageView: UIImageView {
    let cache = NetworkManager.shared.cache
    let placeholderImage = images.placeHolder
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    required init?(coder: NSCoder){
        fatalError("init(coder: ) has not been implemented")
    }
    
    
    private func configure() {
        
        
        layer.cornerRadius = 10
        clipsToBounds = true
        contentMode = .scaleAspectFit
        translatesAutoresizingMaskIntoConstraints = false
        
        if let image = placeholderImage {
            self.image = image
        } else {
            print("Placeholder image not found, using default color.")
            self.image = UIImage()
            self.backgroundColor = .lightGray
        }
    }
    
    func downloadImage(fromURL url: String){
        NetworkManager.shared.downloadImage(from: url){ [weak self] image in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.image = image }
        }
    }
    
}
