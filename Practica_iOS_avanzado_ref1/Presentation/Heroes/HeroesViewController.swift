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
    func onViewAppear()
    func heroAt(index: Int) -> Hero?
    func heroDetailViewModel(for index: Int) -> HeroDetailViewControllerDelegate?
}

class HeroesViewController: UIViewController {
    // MARK: - Constants -
    private let estimatedHeight: CGFloat = 256
    // MARK: - IBOutlets -
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: UIView!

    // MARK: - Public Properties -
    var viewModel: HeroesViewControllerDelegate?

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        
        // Image only
        /*navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "rectangle.portrait.and.arrow.right"),
            style: .plain, 
            target: self,
            action: #selector(resetTapped)
        )*/
        
        // Text only
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Map", style: .plain, target: self, action: #selector(mapTapped))
        
        // Custom Image + title
        let customMapButton: UIButton = UIButton(type: .system)
        customMapButton.setImage(UIImage(systemName: "map"), for: .normal)
        customMapButton.setTitle(" Mapa", for: .normal)
        customMapButton.sizeToFit()
        customMapButton.addTarget(self, action: #selector(mapTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: customMapButton)
        
        let customLogoutButton: UIButton = UIButton(type: .system)
        customLogoutButton.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.right"), for: .normal)
        customLogoutButton.setTitle(" Salir", for: .normal)
        customLogoutButton.sizeToFit()
        customLogoutButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customLogoutButton)
        
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
    @objc private func resetTapped() {
        viewModel?.onResetPressed()
    }
    // Since there is no more logic to this I've decided not to send this through the viewModel
    @objc private func mapTapped() {
        /*performSegue(
            withIdentifier: "HEROES_TO_MAP",
            sender: nil
        )*/
    }
    
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(
            withIdentifier: "HEROES_TO_HERODETAIL",
            sender: indexPath.row
        )
    }
}
