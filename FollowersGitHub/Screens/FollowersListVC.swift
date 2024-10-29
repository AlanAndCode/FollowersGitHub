//
//  FollowersListVC.swift
//  FollowersGitHub
//
//  Created by Alan Modesto on 21/10/24.
//

import UIKit
import Foundation

class FollowersListVC: UIViewController {
    
    
    enum Section {
        case main
    }
    
    var page = 2
    var username: String!
    var followers: [Follower] = []
    var hasMoreFollowers = true
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Follower>!
    //inicializa com configuracoes iniciais baseadas no que quero carregar o app
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureCollectionView()
        getFollowers(username: username, page: page)
        configureDataSource()
        
    }
    //inicializador
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    //configurando o ViewController
    func configureViewController(){
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    //o que é uma collection view? modo de exibicao por colecao ideal para quando temos celulas lado a lado
    func configureCollectionView(){
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: view))
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(FollowerCell.self, forCellWithReuseIdentifier: FollowerCell.reuseID)
    }
    
    
    // consumindo os seguidores
    func getFollowers(username: String, page: Int){
        NetworkManager.shared.getFollowers(for: username, page: page) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case.success(let followers):
                if followers.count < 100 {
                self.hasMoreFollowers = false }
                self.followers.append(contentsOf: followers)
                self.updateData()
                
                
            case .failure(let error):
                self.presentGFAlertOnMainThread(title: "Bad Stuff Happend", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }
    
    //de onde virao as informacoes a serem puxadas
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Follower>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, follower) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FollowerCell.reuseID, for: indexPath) as! FollowerCell
            cell.set(follower: follower)
            return cell
        })
    }
    
    
    func updateData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Follower>()
        snapshot.appendSections([.main])
        snapshot.appendItems(followers)
        DispatchQueue.main.async{ self.dataSource.apply(snapshot, animatingDifferences: true)}
        
    }
    
}


extension FollowersListVC: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        // Verifica se chegou ao fim e se não estamos carregando seguidores
        if offsetY > contentHeight - height - 100 {
            guard hasMoreFollowers else { return }
            page += 1
            getFollowers(username: username, page: page)
            
        }
    }
}
