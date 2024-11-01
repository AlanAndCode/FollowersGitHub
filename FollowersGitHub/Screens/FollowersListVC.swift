//
//  FollowersListVC.swift
//  FollowersGitHub
//
//  Created by Alan Modesto on 21/10/24.
//

import UIKit


protocol FollowerListVCDelegate: AnyObject {
    
    func didRequestFollowers(for username: String)
        
    
    
}

class FollowersListVC: UIViewController {
    protocol FollowerListVCDelegate: AnyObject {
    func didRequestFollowers(for username: String)
    }
    
    enum Section {
        case main
    }
    
    var page = 2
    var username: String!
    var followers: [Follower] = []
    var hasMoreFollowers = true
    var filteredFollowers: [Follower] = []
    var isSearching = false
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Follower>!
    //inicializa com configuracoes iniciais baseadas no que quero carregar o app
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureSearchController()
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
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    //o que é uma collection view? modo de exibicao por colecao ideal para quando temos celulas lado a lado
    func configureCollectionView(){
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: view))
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(FollowerCell.self, forCellWithReuseIdentifier: FollowerCell.reuseID)
    }
    
    func configureSearchController() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search for a username"
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true // Garantir que a barra de busca apareça corretamente
    }
    
    // consumindo os seguidores
    func getFollowers(username: String, page: Int){
        showLoadingView()
        NetworkManager.shared.getFollowers(for: username, page: page) { [weak self] result in
            guard let self = self else { return }
            self.dismissLoadingView()
            switch result {
            case.success(let followers):
                if followers.count < 100 {
                    self.hasMoreFollowers = false }
                self.followers.append(contentsOf: followers)
                
                if self.followers.isEmpty {
                    let message = "This user doesn't have any followers. Go follow them"
                    DispatchQueue.main.async {
                        self.showEmptyStateView(with: message, in: self.view)
                    }
                    return
                }
                
                self.updateData(on: self.followers)
                
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
    
    
    func updateData(on followers: [Follower]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Follower>()
        snapshot.appendSections([.main])
        snapshot.appendItems(followers)
        DispatchQueue.main.async{ self.dataSource.apply(snapshot, animatingDifferences: true)}
        
    }
    
}

// MARK: - delegate
extension FollowersListVC: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        // Verifica se chegou ao fim e se não estamos carregando seguidores
        if offsetY > contentHeight - height {
            guard hasMoreFollowers else { return }
            page += 1
            getFollowers(username: username, page: page)
            
        }
    }
    
    func collectionView( _ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let activeArray = isSearching ? filteredFollowers : followers
        let follower = activeArray[indexPath.item]
        
        let destVC = UserInfoVC()
        destVC.username = follower.login
        destVC.delegate = self
        let navController = UINavigationController(rootViewController: destVC)
        present(navController, animated: true)
    }
    
}

extension FollowersListVC: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {return}
        isSearching = true
        filteredFollowers = followers.filter { $0.login.lowercased().contains(filter.lowercased()) }
        updateData(on: filteredFollowers)
        
    }
    func
    searchBarCancelButtonClicked(_
    searchBar: UISearchBar) {
        isSearching = false
        updateData(on: followers)
    }
}

extension FollowersListVC: FollowerListVCDelegate{
    
    
    func didRequestFollowers(for username: String) {
        self.username = username
        title = username
        page = 1
        followers.removeAll()
        filteredFollowers.removeAll()
        collectionView.setContentOffset(.zero, animated: true)
        getFollowers(username: username, page: page)
    }
    
    
}
