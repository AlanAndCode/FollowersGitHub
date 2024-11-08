//
//  FollowersListVC.swift
//  FollowersGitHub
//
//  Created by Alan Modesto on 21/10/24.
//

import UIKit



class FollowersListVC: GFDataLoadingVC {
    
    
    enum Section {
        case main
    }
    
    var page = 1
    var username: String!
    var followers: [Follower] = []
    var hasMoreFollowers = true
    var filteredFollowers: [Follower] = []
    var isSearching = false
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Follower>!
    var isLoadingMoreFollowers = false
    
    init(username: String){
        super.init(nibName: nil, bundle: nil)
        self.username = username
        title = username
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
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
        let searchController                  = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search for a username"
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController       = searchController
        definesPresentationContext            = true // Garantir que a barra de busca apareça corretamente
    }
    
    // consumindo os seguidores
    func getFollowers(username: String, page: Int){
        showLoadingView()
        isLoadingMoreFollowers = true
        NetworkManager.shared.getFollowers(for: username, page: page) { [weak self] result in
            guard let self = self else { return }
            self.dismissLoadingView()
            switch result {
            case.success(let followers):
                self.updateUI(with: followers)
              
                
            case .failure(let error):
                self.presentGFAlertOnMainThread(title: "Bad Stuff Happend", message: error.rawValue, buttonTitle: "Ok")
            }
            
            self.isLoadingMoreFollowers = false
        }
    }
    
    func updateUI(with: [Follower]){
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
    }
    
    
    //de onde virao as informacoes a serem puxadas
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Follower>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, follower) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FollowerCell.reuseID, for: indexPath) as! FollowerCell
            cell.set(follower: follower)
            return cell
        })
    }
    
    //
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
            guard hasMoreFollowers, !isLoadingMoreFollowers else { return }
            page =  page + 1
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
    
    @objc func addButtonTapped(){
        showLoadingView()
        
        NetworkManager.shared.getUserInfo(for: username) { [weak self] result in
            guard let self = self else { return }
            self.dismissLoadingView()
            
            
            switch result {
                case .success(let user):
                let favorite = Follower(login: user.login, avatarUrl: user.avatarUrl)
                
               
                PersitenceManager.updatewWith(favorite: favorite, actionType: .add) { [weak self] error in
                    guard let self = self else { return }
                    guard let error = error else {
                        self.presentGFAlertOnMainThread(title: "Sucess", message: "you have sucefully favortied this user", buttonTitle: "Hooray")
                        return
                    }
                    self.presentGFAlertOnMainThread(title: "Something went wrong", message: error.rawValue, buttonTitle: "ök")

                }
                
                
            case .failure(let error):
                self.presentGFAlertOnMainThread(title: "Something went wrong", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }
}

extension FollowersListVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let filter  = searchController.searchBar.text, !filter.isEmpty else {
            filteredFollowers.removeAll()
            updateData(on: followers)
            isSearching = false
            return
        }
        
        isSearching       = true
        filteredFollowers = followers.filter { $0.login.lowercased().contains(filter.lowercased()) }
        updateData(on: filteredFollowers)

    }
}

extension FollowersListVC: UserInfoVCDelegate{
    
    
    func didRequestFollowers(for username: String) {
        self.username = username
        title = username
        page  = 1
        followers.removeAll()
        filteredFollowers.removeAll()
        collectionView.setContentOffset(.zero, animated: true)
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        getFollowers(username: username, page: page)
    }
    
    
}
