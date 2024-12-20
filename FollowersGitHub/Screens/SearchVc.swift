//
//  SearchVc.swift
//  FollowersGitHub
//
//  Created by Alan Modesto on 18/10/24.
//

import UIKit

class SearchVc: UIViewController {
    
    
    let logoImageView = UIImageView()
    let usernameTextField = GFTextField()
    let callToActionButton = GFButton(backgroundColor: .systemGreen, title: "Get Followers")
    

    
    var isUsernameEntered: Bool { return !usernameTextField.text!.isEmpty }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubviews(logoImageView, usernameTextField, callToActionButton)
        configureLogoImageView()
        configureTextField()
        configureCallButton()
        createDismissKeyboardTapGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        usernameTextField.text = ""
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    
    
    func createDismissKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    @objc func PushFollowersListVC(){
        
        guard isUsernameEntered else{
            presentGFAlertOnMainThread(title: "empty username", message: " Please enter a username. we need to know who to look for.", buttonTitle: "ok")
            return
        }
        
        usernameTextField.resignFirstResponder()
    
        let followerListVC = FollowersListVC(username: usernameTextField.text!)
        
        navigationController?.pushViewController(followerListVC, animated: true)
    }
    
    
    func configureLogoImageView() {
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.image = images.ghLogo
        let topConstraintConstant = DeviceTypes.isiPhoneSE || DeviceTypes.isiPhone8Zoomed ? 20 : 80
        
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
            constant: CGFloat(topConstraintConstant)),
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 200),
            logoImageView.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    func configureTextField() {

        usernameTextField.delegate = self
        
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
    
        
        NSLayoutConstraint.activate([
            usernameTextField.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 48),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            usernameTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func configureCallButton(){
        callToActionButton.addTarget(self, action: #selector(PushFollowersListVC), for: .touchUpInside)
            NSLayoutConstraint.activate([
                callToActionButton.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 16),
                callToActionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
                callToActionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
                callToActionButton.heightAnchor.constraint(equalToConstant: 50)
            ])
        }

    
}

extension SearchVc: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        PushFollowersListVC()
        return true
    }
}
