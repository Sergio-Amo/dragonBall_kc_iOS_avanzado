//
//  HeroesViewController.swift
//  Practica_iOS_avanzado_ref1
//
//  Created by Sergio Amo on 28/10/23.
//

import UIKit

// MARK: - View State -
enum HeroesViewState {
    case loading(_ isLoading: Bool)
    case updateData
}

// MARK: - View Protocol -
protocol HeroesViewControllerDelegate {
    var viewState: ((HeroesViewState) -> Void)? { get set }
    var heroesCount: Int { get }
    
    func onResetPressed()
    func filterHeroes(currentFilter: String)
    func onViewAppear()
    func heroAt(index: Int) -> Hero?
    func heroDetailViewModel(for index: Int) -> HeroDetailViewControllerDelegate?
}

class HeroesViewController: UIViewController {
    // MARK: - Constants -
    private let estimatedHeight: CGFloat = 256
    
    // MARK: - Private vars -
    private var searchIsHidden = true
    
    // MARK: - IBOutlets -
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: UIView!
    // I discovered there's a built in searchbar way before implementing my own using a filter field
    //          ¯\_(ツ)_/¯
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterField: UITextField!
    
    // MARK: - Public Properties -
    var viewModel: HeroesViewControllerDelegate?

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        
        // Custom Image + title UIBarButtonItem
        // Exit button
        let customLogoutButton: UIButton = UIButton(type: .system)
        customLogoutButton.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.right"), for: .normal)
        customLogoutButton.setTitle(" Salir", for: .normal)
        customLogoutButton.sizeToFit()
        customLogoutButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customLogoutButton)
        
        // Map button
        let customMapButton: UIButton = UIButton(type: .system)
        customMapButton.setImage(UIImage(systemName: "map"), for: .normal)
        customMapButton.setTitle(" Mapa", for: .normal)
        customMapButton.sizeToFit()
        customMapButton.addTarget(self, action: #selector(mapTapped), for: .touchUpInside)
        //navigationItem.rightBarButtonItem = UIBarButtonItem(customView: customMapButton)
        let mapButton = UIBarButtonItem(customView: customMapButton)
        
        // Search button
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchTapped))
        
        // Add the buttons
        navigationItem.rightBarButtonItems = [searchButton, mapButton]
        
        initViews()
        setObservers()
        viewModel?.onViewAppear()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "HEROES_TO_HERODETAIL",
              let index = sender as? Int,
              let heroeDetailViewController = segue.destination as? HeroDetailViewController,
              let heroDetailViewModel = self.viewModel?.heroDetailViewModel(for: index) else {
            return
        }
        heroeDetailViewController.viewModel = heroDetailViewModel

    }
    
    // MARK: - Private functions -
    private func initViews() {
        tableView.register(UINib(nibName: HeroesTableViewCell.identifier, bundle: nil),
                           forCellReuseIdentifier: HeroesTableViewCell.identifier)

        tableView.delegate = self
        tableView.dataSource = self
    }

    private func setObservers() {
        viewModel?.viewState = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                    case .loading(let isLoading):
                        self?.loadingView.isHidden = !isLoading

                    case .updateData:
                        self?.tableView.reloadData()
                }
            }
        }
    }
}

// MARK: - Extension TableView -
extension HeroesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.heroesCount ?? 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        self.estimatedHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: HeroesTableViewCell.identifier,
            for: indexPath) as? HeroesTableViewCell else
        {
            return UITableViewCell()
        }
        
        if let hero = viewModel?.heroAt(index: indexPath.row) {
            cell.updateViews(data: hero)
        }
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // My idea was to add this on the cellForRowAt above so it triggers less frequently
        // but filtering also triggers a table update therefore hidding the search bar
        // didScroll also triggers when the table was scrolled down before filtering (jumps up to 0.0)
        // that's why I check for .zero position on Y
        if searchIsHidden || scrollView.contentOffset.y == .zero { return }
        if !searchIsHidden { showSearch(shouldHide: true) }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(
            withIdentifier: "HEROES_TO_HERODETAIL",
            sender: indexPath.row
        )
    }
}

// Actions
extension HeroesViewController {
    // LogOut / Remove data functionality
    @objc private func resetTapped() {
        viewModel?.onResetPressed()
    }
    
    // TODO: Navigate to HeroesMap
    @objc private func mapTapped() {
        performSegue(
            withIdentifier: "HEROES_TO_HEROESMAP",
            sender: nil
        )
    }
    // Show/Hide Search Bar
    @objc private func searchTapped() {
        // Toggle searchBar
        showSearch(shouldHide: !searchIsHidden)
    }
    private func showSearch(shouldHide: Bool) {
        if searchIsHidden == shouldHide { return }
        searchIsHidden = shouldHide
        
        filterView.isHidden = shouldHide
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5
        ) { [weak self] in
            self?.filterView.alpha = shouldHide == true ? 0 : 1
            self?.view.layoutIfNeeded()
        }
        
        _ = !shouldHide ? filterField.becomeFirstResponder() : filterField.resignFirstResponder()
    }
    // OnFilter
    @IBAction func onFilter(_ sender: Any) {
        if let currentFilter = filterField.text {
            viewModel?.filterHeroes(currentFilter: currentFilter)
        }
    }
}
