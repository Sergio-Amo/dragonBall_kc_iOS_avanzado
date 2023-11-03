//
//  LoginViewController.swift
//  Practica_iOSAvanzado
//
//  Created by Sergio Amo on 25/10/23.
//

import UIKit

// MARK: - View Protocol -
protocol LoginViewControllerDelegate {
    var viewState: ((LoginViewState) -> Void)? { get set }
    func onLoginPressed(email: String?, password: String?)
    var heroesViewModel: HeroesViewControllerDelegate { get }
}

// MARK: - View State -
enum LoginViewState {
    case loading(_ isLoading: Bool)
    case showErrorEmail(_ error: String?)
    case showErrorPassword(_ error: String?)
    case navigateToNext
    case showToast(_ data: (image: String, text: String))
}

final class LoginViewController: UIViewController {
    // MARK: - IBOutlet -
    // User
    @IBOutlet weak var userField: UITextField!
    @IBOutlet weak var userFieldError: UILabel!
    // Password
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordFieldError: UILabel!
    // Activity monitor view
    @IBOutlet weak var loadingView: UIView!
    // User/Password StackView
    @IBOutlet weak var filedsStackView: UIStackView!
    // Info Toast
    @IBOutlet weak var infoToastView: UIStackView!
    @IBOutlet weak var infoToastLabel: UILabel!
    @IBOutlet weak var infoToastImage: UIImageView!
    @IBOutlet weak var infoToastBottomConstraint: NSLayoutConstraint!
    
    // MARK: - IBAction -
    @IBAction func onLoginPressed() {
        viewModel?.onLoginPressed(
            email: userField.text,
            password: passwordField.text
        )
    }
    // Hide error message when fields changes
    @IBAction func userFieldChanged(_ sender: Any) {
        hideErrorLabel(userFieldError)
        hideToast()
    }
    @IBAction func passwordFieldChanged(_ sender: Any) {
        hideErrorLabel(passwordFieldError)
        hideToast()
    }

    // MARK: - Public Properties -
    var viewModel: LoginViewControllerDelegate?
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Remove back button
        self.navigationItem.setHidesBackButton(true, animated: false)
        initViews()
        setObservers()
        
        userFieldError.layer.cornerRadius = 4
        userFieldError.layer.masksToBounds = false
        userFieldError.clipsToBounds = true
        
        passwordFieldError.layer.cornerRadius = 4
        passwordFieldError.layer.masksToBounds = false
        passwordFieldError.clipsToBounds = true
        
        infoToastView.layer.cornerRadius = 12
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LOGIN_TO_HEROES",
           let heroesViewController = segue.destination as? HeroesViewController {
            heroesViewController.viewModel = viewModel?.heroesViewModel
        }
    }
    
    // MARK: - Private functions -
    private func initViews() {
        view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(onUiTapped)
            )
        )
    }

    @objc func onUiTapped() {
        // Dismiss keyboard
        view.endEditing(true)
        // Dismiss toast
        hideToast()
    }
    // TODO: include function to animate and show/hide labels
    private func hideErrorLabel(_ label: UILabel) {
        if label.isHidden { return }
        label.isHidden = true
        animateFieldsStack()
    }
    
    private func setObservers() {
        viewModel?.viewState = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                    case .loading(let isLoading):
                        self?.loadingView.isHidden = !isLoading
                        
                    case .showErrorEmail(let error):
                        self?.userFieldError.text = error
                        self?.userFieldError.isHidden = (error == nil || error?.isEmpty == true)
                        self?.animateFieldsStack()
                        
                    case .showErrorPassword(let error):
                        self?.passwordFieldError.text = error
                        self?.passwordFieldError.isHidden = (error == nil || error?.isEmpty == true)
                        self?.animateFieldsStack()
                        
                    case .showToast(let data):
                        self?.showToast(data)
                        
                    case .navigateToNext:
                        self?.performSegue(withIdentifier: "LOGIN_TO_HEROES",
                                           sender: nil)
                }
            }
        }
    }
    
    private func animateFieldsStack () {
        self.filedsStackView.setNeedsLayout()
        UIView.animate(
            withDuration:0.5,
            delay: 0.0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0.5
        ) { [weak self] in
            self?.filedsStackView.layoutIfNeeded()
        }
    }
    
    private func showToast(_ data: (image: String, text: String)) {
        infoToastLabel.text = data.text
        infoToastImage.image = UIImage(systemName: data.image)
        infoToastBottomConstraint.constant = 64
        UIView.animate(
            withDuration: 0.8,
            delay: 0.0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5
        ) { [weak self] in
            self?.infoToastView.alpha = 1.0
            self?.view.layoutIfNeeded()
        }
    }
    
    private func hideToast() {
        // Move down
        infoToastBottomConstraint.constant = -108
        UIView.animate(withDuration: 0.6) { [weak self] in
            // Make transparent
            self?.infoToastView.alpha = 0.0
            self?.view.layoutIfNeeded()
        } completion: { [weak self] _ in
            // Reset fields for reuse
            self?.infoToastLabel.text = ""
            self?.infoToastImage.image = UIImage(systemName: "")
        }
    }
}
