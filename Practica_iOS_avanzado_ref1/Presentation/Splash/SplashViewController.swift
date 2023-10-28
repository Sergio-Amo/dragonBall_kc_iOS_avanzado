//
//  SplashViewController.swift
//  Practica_iOS_avanzado_ref1
//
//  Created by Sergio Amo on 28/10/23.
//

import UIKit

// MARK: - View State -
enum SplashViewState {
    case loading(_ isLoading: Bool)
    case navigateToLogin
    case navigateToHeroes
}

// MARK: - View Protocol -
protocol SplashViewControllerDelegate {
    var viewState: ((SplashViewState) -> Void)? { get set }
    var loginViewModel: LoginViewControllerDelegate { get }
    //var heroesViewModel: HeroesViewControllerDelegate { get }
    // TODO: remove after implementing HeroesDelegate
    func onViewAppear()
}

final class SplashViewController: UIViewController {
    // MARK: - IBOutlet -
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Public Properties -
    var viewModel: SplashViewControllerDelegate?
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        setObservers()
        viewModel?.onViewAppear()
    }
    // Remove navigation bar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case "SPLASH_TO_LOGIN":
                guard let loginViewController = segue.destination as? LoginViewController else { return }
                loginViewController.viewModel = viewModel?.loginViewModel
                
                /* case "SPLASH_TO_HEROES":
                 guard let heroesViewController = segue.destination as? HeroesViewController else { return }
                 heroesViewController.viewModel = viewModel?.heroesViewModel
                 */
            default:
                break
        }
    }
    
    // MARK: - Private functions -
    private func setObservers() {
        viewModel?.viewState = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                    case .loading(let isLoading):
                        self?.activityIndicator.isHidden = !isLoading
                        
                    case .navigateToLogin:
                        self?.performSegue(withIdentifier: "SPLASH_TO_LOGIN", sender: nil)
                        
                    case .navigateToHeroes:
                        self?.performSegue(withIdentifier: "SPLASH_TO_HEROES", sender: nil)
                }
            }
        }
    }
}
