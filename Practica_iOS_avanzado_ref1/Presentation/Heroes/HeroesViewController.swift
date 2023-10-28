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
    
    func onViewAppear()
    func heroAt(index: Int) -> Hero?
    //func heroDetailViewModel(for index: Int) -> HeroDetailViewControllerDelegate?
}

class HeroesViewController: UIViewController {
    // MARK: - Constants -
    private let estimatedHeight: CGFloat = 256
    // MARK: - IBOutlet -
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: UIView!

    // MARK: - Public Properties -
    var viewModel: HeroesViewControllerDelegate?

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true

        initViews()
        setObservers()
        viewModel?.onViewAppear()
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*performSegue(
            withIdentifier: "HEROES_TO_HERO_DETAIL",
            sender: indexPath
        )*/
    }
}
