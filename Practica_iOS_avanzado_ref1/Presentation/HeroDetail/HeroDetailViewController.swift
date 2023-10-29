//
//  HeroDetailViewController.swift
//  Practica_iOS_avanzado_ref1
//
//  Created by Sergio Amo on 29/10/23.
//

import UIKit
import MapKit
import Kingfisher

enum HeroDetailViewState {
    case loading(_ isLoading: Bool)
    case update(hero: Hero?, locations: [String])
}

protocol HeroDetailViewControllerDelegate {
    var viewState: ((HeroDetailViewState) -> Void)? { get set }
    func onViewAppear()
}

final class HeroDetailViewController: UIViewController {
    
    //MARK: - IBOutlets -
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var mapOutlet: MKMapView!
    @IBOutlet weak var tittleOutlet: UILabel!
    @IBOutlet weak var descriptionOutlet: UITextView!
    
    var viewModel: HeroDetailViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        setObservers()
        viewModel?.onViewAppear()
        makeImageRound()
    }
    
    private func initViews() {
        
    }
    private func setObservers() {
        viewModel?.viewState = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                    case .loading(let isLoading):
                        break
                    case .update(let hero, let locations):
                        self?.updateViews(hero: hero)
                        break
                }
            }
        }
    }
    
    private func updateViews(hero: Hero?) {
        update(title: hero?.name)
        update(description: hero?.description)
        update(photo: hero?.photo)
    }
    
    private func update(title: String? = nil) {
        tittleOutlet.text = title
    }
    private func update(description: String? = nil) {
        descriptionOutlet.text = description
    }
    private func update(photo: URL? = nil) {
        guard let photo else { return }
        let finalUrl = photo.scheme == "http" ? photo.upgradeUrlScheme(photo) : photo
        imageOutlet.kf.setImage(with: finalUrl)
    }
    
    private func makeImageRound() {
        imageOutlet.layer.cornerRadius = imageOutlet.frame.width / 2
        imageOutlet.clipsToBounds = true
        
        imageOutlet.layer.borderWidth = 3
        imageOutlet.layer.borderColor = UIColor.systemBackground.cgColor
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
