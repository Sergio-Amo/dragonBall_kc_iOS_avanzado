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
}

// MARK: - View State -
enum LoginViewState {
    case loading(_ isLoading: Bool)
    case showErrorEmail(_ error: String?)
    case showErrorPassword(_ error: String?)
    case navigateToNext
}

class LoginViewController: UIViewController {
    // MARK: - IBOutlet -
    @IBOutlet weak var userField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var userFieldError: UILabel!
    @IBOutlet weak var passwordFieldError: UILabel!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var filedsStackView: UIStackView!
    
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
    }
    @IBAction func passwordFieldChanged(_ sender: Any) {
        hideErrorLabel(passwordFieldError)
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
    }
    
    // MARK: - Private functions -
    private func initViews() {
        view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(dismissKeyboard)
            )
        )
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
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
}
