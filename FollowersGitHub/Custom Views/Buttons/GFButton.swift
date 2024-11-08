//
//  GFButton.swift
//  FollowersGitHub
//
//  Created by Alan Modesto on 20/10/24.
//

import UIKit

class GFButton: UIButton {

    override init(frame: CGRect) {
           super.init(frame: frame)
           configure()
       }

       required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }

    //convenience init? pra que usar?
    convenience init(color: UIColor, title: String, systemImageName: String) {
        self.init(frame: .zero)
        set(color: color, title: title, systemImageName: systemImageName)
        
    }
    
       private func configure() {
           
           
           configuration                             = .tinted()
            
           configuration?.cornerStyle                = .medium

           translatesAutoresizingMaskIntoConstraints = false
       }
    
    func set (color: UIColor, title: String, systemImageName: String) {
        //configuration? acessa BackGroundColor Apenas se Configuration nao for null
        configuration?.baseBackgroundColor = color
        configuration?.baseForegroundColor = color
        configuration?.title               = title
        
        configuration?.image          = UIImage (systemName: systemImageName)
        configuration?.imagePadding   = 6
        configuration?.imagePlacement = .leading
    }
}

#Preview {
   GFButton(color: .blue, title: "Test Button", systemImageName: "pencil")
}
