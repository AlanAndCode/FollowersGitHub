//
//  FavoritesListVC.swift
//  FollowersGitHub
//
//  Created by Alan Modesto on 18/10/24.
//

import UIKit

class FavoritesListVC: GFDataLoadingVC {

    let tableView = UITableView()
    var favorites: [Follower] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("favorites loaded")
        configureViewController()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFavorites()
    }
    
    
    func configureViewController(){
        view.backgroundColor = .systemBackground
        title = "faovorites"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func configureTableView(){
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.rowHeight = 80
        tableView.delegate = self
        tableView.dataSource = self
        tableView.removeExcessCells()
        
        tableView.register(FavoritesCell.self, forCellReuseIdentifier: FavoritesCell.reuseID)
    }
    
    func getFavorites(){
        
        PersitenceManager.retrieveFavorites { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let favorites):
                if favorites.isEmpty {
                    self.showEmptyStateView(with: "No Favorites?WnAdd one on the follower screen.", in: self.view)
                } else {
                        self.favorites = favorites
                        self.tableView.reloadDataOnMainThread()
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.view.bringSubviewToFront(self.tableView)
                        }
                    }
                self.favorites = favorites
            case .failure(let error):
                self.presentGFAlertOnMainThread(title: "something wrong", message: error.rawValue , buttonTitle: "OK")
            }
        }
    }
}

extension FavoritesListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoritesCell.reuseID) as! FavoritesCell
        let favorite = favorites[indexPath.row]
        cell.set(favorites: favorite)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favorite = favorites[indexPath.row]
        let destVC = FollowersListVC(username: favorite.login)
        

        navigationController?.pushViewController(destVC, animated: true)

    }
    
    func tableView(_ tableView: UITableView,commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        PersitenceManager.updatewWith(favorite: favorites[indexPath.row], actionType: .remove) { [weak self] error in
            guard let self = self else { return }
            guard let error = error else {
                self.favorites.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
                return}
            self.presentGFAlertOnMainThread(title: "Unable to remove" , message: error.rawValue, buttonTitle:
            "OK")
            
        }
    }
}
