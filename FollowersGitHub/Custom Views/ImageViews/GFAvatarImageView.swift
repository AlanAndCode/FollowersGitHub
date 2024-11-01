//
//  GFAvatarImageView.swift
//  FollowersGitHub
//
//  Created by Alan Modesto on 23/10/24.
//

import UIKit

class GFAvatarImageView: UIImageView {
    let cache = NetworkManager.shared.cache
    let placeholderImage = UIImage (named: "avatar-placeholder")
    
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
    
    func downloadImage(from urlString: String) {
        //tenho duvida de como funciona o cache
        let cacheKey = NSString(string: urlString)
        
        if let image = cache.object (forKey: cacheKey){
            self.image = image
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else {return}
            if error != nil { return }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {return}
            guard let data = data else {return}
            
            guard let image = UIImage(data: data) else {return }
            self.cache.setObject(image, forKey: cacheKey)
            DispatchQueue.main.async{
            self.image = image
            }
        }
        
        task.resume()
    }
}
