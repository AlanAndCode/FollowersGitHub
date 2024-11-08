//
//  UITableView+ext.swift
//  FollowersGitHub
//
//  Created by Alan Modesto on 07/11/24.
//

import UIKit
//usado para fazer reload na tabela e remover celular que ja sairam da view
extension UITableView {
    
    func reloadDataOnMainThread () {
        DispatchQueue.main.async {
            self.reloadData()
        }
    }
    
    
func removeExcessCells () {
    tableFooterView = UIView(frame: .zero)
            }
    
}
