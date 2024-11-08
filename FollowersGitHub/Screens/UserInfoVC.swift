//
//  UserInfoVC.swift
//  FollowersGitHub
//
//  Created by Alan Modesto on 30/10/24.
//

import UIKit

protocol UserInfoVCDelegate: AnyObject {
    
    func didRequestFollowers(for username: String)
    
}


class UserInfoVC: GFDataLoadingVC {
    
    let scrollView = UIScrollView()
    
    let headerView = UIView()
    let contentView = UIView()
    let itemViewOne = UIView()
    let itemViewTwo = UIView()
    let dateLabel = GFBodyLabel(textAlignment: .center)
    var itemViews: [UIView] = []
    var username: String!
    //VARIAVEL FRACA
    weak var delegate: UserInfoVCDelegate!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        layoutUI()
        getUserInfo()
        configureScrollView()
    }
    
    
    func getUserInfo(){
        NetworkManager.shared.getUserInfo(for: username){ [weak self] result in
            guard let self = self else {return}
            
            switch result {
            case .success(let user):
                DispatchQueue.main.async{
                    self.configureUIEelements(with: user)
                    
                }
                
                
            case .failure(let error):
                self.presentGFAlertOnMainThread(title: "something wrong", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }
    
    func configureScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.pinToEdges(of: view)
        contentView.pinToEdges(of: scrollView)
        
        NSLayoutConstraint.activate([
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        contentView.heightAnchor.constraint(equalToConstant: 600)
        ])
    }
    // nao entendi
    func configureUIEelements(with user: User){
        self.add(childVC: GFRepoItemVC(user: user, delegate: self), to: self.itemViewOne)
        self.add(childVC: GFFollowerItemVC(user: user, delegate: self), to: self.itemViewTwo)
        self.add(childVC: GFUserInfoHeaderVC(user: user), to: self.headerView)
        self.dateLabel.text = "Github since: \(user.createdAt.convertToMonthYearFormat())"
    }
    
    
    
    func configureViewController(){
        view.backgroundColor = .systemBackground
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action:#selector(dismssVC))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    func layoutUI(){
        let padding: CGFloat = 20
        let itemHeight: CGFloat = 140
        itemViews = [headerView, itemViewOne, itemViewTwo, dateLabel]
        
        for itemView in itemViews{
            contentView.addSubview(itemView)
            itemView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                itemView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
                itemView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
                
                
            ])
        }
        
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 210),
            
            itemViewOne.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: padding),
            itemViewOne.heightAnchor.constraint(equalToConstant: itemHeight),
            
            itemViewTwo.topAnchor.constraint(equalTo: itemViewOne.bottomAnchor, constant: padding),
            
            itemViewTwo.heightAnchor.constraint(equalToConstant: itemHeight),
            
            dateLabel.topAnchor.constraint(equalTo: itemViewTwo.bottomAnchor, constant: padding),
            dateLabel .heightAnchor.constraint(equalToConstant: 50)
            
        ])
    }
    // o que é um childVC?
    func add(childVC: UIViewController, to containerView: UIView){
        addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.view.frame = containerView.bounds
        childVC.didMove(toParent: self)
        
    }
    
    @objc func dismssVC() {
        dismiss (animated: true)
    }
}


extension UserInfoVC: GFRepoItemVCDelegate{
    func didTapGitHubProfile(for user: User) {
        guard let url = URL(string: user.htmlUrl) else {
            presentGFAlertOnMainThread(title: "Invalid URL", message: "The url attached to this user is invalid.”",
                                       buttonTitle: "Ok")
            return
        }
        
        presentSafariVC(with: url)
    }
}
    
    
    
   

extension UserInfoVC: GFFollowerItemVCDelegate{
    func didTapGetFollowers(for user: User) {
        guard user.followers != 0 else {
        presentGFAlertOnMainThread(title: "No followers", message:
                                    "This user has no followers. What a shame",
                                   buttonTitle: "so sad")
        return
    }
        
        delegate.didRequestFollowers(for: user.login)
        dismssVC()
    }
}
